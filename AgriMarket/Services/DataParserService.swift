//
//  DataParserService.swift
//  AgriMarket
//
//  Advanced parsing service for different data formats
//

import Foundation

class DataParserService {
    static let shared = DataParserService()

    private init() {}

    // MARK: - HTML Parsing

    func parseHTML(_ html: String, using patterns: [HTMLParsePattern]) -> [String: Any] {
        var results: [String: Any] = [:]

        for pattern in patterns {
            if let value = extractValue(from: html, pattern: pattern) {
                results[pattern.key] = value
            }
        }

        return results
    }

    private func extractValue(from html: String, pattern: HTMLParsePattern) -> Any? {
        let regex = try? NSRegularExpression(pattern: pattern.regex, options: [])
        let nsString = html as NSString
        let results = regex?.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))

        guard let match = results?.first, match.numberOfRanges > 1 else {
            return nil
        }

        let range = match.range(at: 1)
        let extractedString = nsString.substring(with: range)

        return convertToType(extractedString, type: pattern.type)
    }

    private func convertToType(_ string: String, type: HTMLValueType) -> Any? {
        let cleaned = string.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "$", with: "")

        switch type {
        case .string:
            return cleaned
        case .double:
            return Double(cleaned)
        case .int:
            return Int(cleaned)
        case .date:
            return parseDate(cleaned)
        case .percentage:
            let percentString = cleaned.replacingOccurrences(of: "%", with: "")
            return Double(percentString)
        }
    }

    // MARK: - JSON Parsing

    func parseJSON<T: Decodable>(_ data: Data, type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customISO8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }

    func parseJSONArray<T: Decodable>(_ data: Data, type: T.Type) throws -> [T] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customISO8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([T].self, from: data)
    }

    // MARK: - CSV Parsing

    func parseCSV(_ csvString: String, headers: [String]? = nil) -> [[String: String]] {
        var results: [[String: String]] = []
        let lines = csvString.components(separatedBy: .newlines).filter { !$0.isEmpty }

        guard !lines.isEmpty else { return [] }

        let headerLine = headers ?? lines[0].components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let dataLines = headers == nil ? Array(lines.dropFirst()) : lines

        for line in dataLines {
            let values = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            var row: [String: String] = [:]

            for (index, header) in headerLine.enumerated() {
                if index < values.count {
                    row[header] = values[index]
                }
            }

            results.append(row)
        }

        return results
    }

    // MARK: - XML/RSS Parsing

    func parseRSS(_ data: Data) throws -> [RSSItem] {
        var items: [RSSItem] = []

        let parser = XMLParser(data: data)
        let delegate = RSSParserDelegate()
        parser.delegate = delegate

        if parser.parse() {
            items = delegate.items
        } else if let error = parser.parserError {
            throw error
        }

        return items
    }

    // MARK: - Commodity-Specific Parsers

    func parseCommodityPrice(from json: [String: Any]) -> ScrapedCommodityData? {
        guard let symbol = json["symbol"] as? String,
              let price = json["price"] as? Double else {
            return nil
        }

        return ScrapedCommodityData(
            source: json["source"] as? String ?? "Unknown",
            symbol: symbol,
            name: json["name"] as? String ?? symbol,
            price: price,
            change: json["change"] as? Double ?? 0,
            changePercent: json["changePercent"] as? Double ?? 0,
            volume: json["volume"] as? Double,
            timestamp: Date(),
            currency: json["currency"] as? String ?? "USD",
            unit: json["unit"] as? String ?? "per unit"
        )
    }

    // MARK: - Table Extraction

    func extractTable(from html: String, tableId: String? = nil) -> [[String]] {
        var rows: [[String]] = []

        // Find table
        let tablePattern = tableId != nil
            ? "<table[^>]*id=\"\(tableId!)\"[^>]*>(.*?)</table>"
            : "<table[^>]*>(.*?)</table>"

        guard let tableRegex = try? NSRegularExpression(pattern: tablePattern, options: .dotMatchesLineSeparators),
              let tableMatch = tableRegex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)) else {
            return []
        }

        let tableContent = String(html[Range(tableMatch.range, in: html)!])

        // Extract rows
        let rowPattern = "<tr[^>]*>(.*?)</tr>"
        guard let rowRegex = try? NSRegularExpression(pattern: rowPattern, options: .dotMatchesLineSeparators) else {
            return []
        }

        let rowMatches = rowRegex.matches(in: tableContent, range: NSRange(tableContent.startIndex..., in: tableContent))

        for rowMatch in rowMatches {
            let rowContent = String(tableContent[Range(rowMatch.range, in: tableContent)!])
            let cells = extractTableCells(from: rowContent)
            if !cells.isEmpty {
                rows.append(cells)
            }
        }

        return rows
    }

    private func extractTableCells(from rowHTML: String) -> [String] {
        var cells: [String] = []

        let cellPattern = "<t[dh][^>]*>(.*?)</t[dh]>"
        guard let cellRegex = try? NSRegularExpression(pattern: cellPattern, options: .dotMatchesLineSeparators) else {
            return []
        }

        let cellMatches = cellRegex.matches(in: rowHTML, range: NSRange(rowHTML.startIndex..., in: rowHTML))

        for cellMatch in cellMatches where cellMatch.numberOfRanges > 1 {
            let range = cellMatch.range(at: 1)
            let cellContent = String(rowHTML[Range(range, in: rowHTML)!])
            let cleanedContent = stripHTMLTags(cellContent)
            cells.append(cleanedContent)
        }

        return cells
    }

    // MARK: - Helper Methods

    private func stripHTMLTags(_ html: String) -> String {
        let pattern = "<[^>]+>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(html.startIndex..., in: html)
        let stripped = regex?.stringByReplacingMatches(in: html, options: [], range: range, withTemplate: "") ?? html

        return stripped
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseDate(_ string: String) -> Date? {
        let formatters = [
            "yyyy-MM-dd",
            "MM/dd/yyyy",
            "dd-MM-yyyy",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss"
        ]

        for format in formatters {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: string) {
                return date
            }
        }

        return nil
    }
}

// MARK: - Supporting Types

struct HTMLParsePattern {
    let key: String
    let regex: String
    let type: HTMLValueType
}

enum HTMLValueType {
    case string
    case double
    case int
    case date
    case percentage
}

struct RSSItem {
    let title: String
    let link: String
    let description: String
    let pubDate: Date?
    let guid: String?
}

// MARK: - RSS Parser Delegate

class RSSParserDelegate: NSObject, XMLParserDelegate {
    var items: [RSSItem] = []

    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentDescription = ""
    private var currentPubDate = ""
    private var currentGuid = ""

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName

        if elementName == "item" {
            currentTitle = ""
            currentLink = ""
            currentDescription = ""
            currentPubDate = ""
            currentGuid = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title":
            currentTitle += string
        case "link":
            currentLink += string
        case "description":
            currentDescription += string
        case "pubDate":
            currentPubDate += string
        case "guid":
            currentGuid += string
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
            let pubDate = dateFormatter.date(from: currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines))

            let item = RSSItem(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
                description: currentDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                pubDate: pubDate,
                guid: currentGuid.trimmingCharacters(in: .whitespacesAndNewlines)
            )

            items.append(item)
        }
    }
}

// MARK: - Date Decoding Strategy Extension

extension JSONDecoder.DateDecodingStrategy {
    static var customISO8601: JSONDecoder.DateDecodingStrategy {
        return .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let formatters = [
                ISO8601DateFormatter(),
                {
                    let f = DateFormatter()
                    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    return f
                }(),
                {
                    let f = DateFormatter()
                    f.dateFormat = "yyyy-MM-dd"
                    return f
                }()
            ]

            for formatter in formatters {
                if let isoFormatter = formatter as? ISO8601DateFormatter,
                   let date = isoFormatter.date(from: dateString) {
                    return date
                } else if let dateFormatter = formatter as? DateFormatter,
                          let date = dateFormatter.date(from: dateString) {
                    return date
                }
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
    }
}
