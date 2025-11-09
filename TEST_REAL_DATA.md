# 🧪 Test Real Data - Step by Step

## 🎯 Amaç
Web scraping yerine **GERÇEKTEN ÇALIŞAN** ücretsiz API'leri test et.

## ✅ Ücretsiz API'ler (Kayıt Gerektirmeyen)

### 1. World Bank API - ✅ HEMEN ÇALIŞİYOR

```bash
# Terminal'de test et:
curl "https://api.worldbank.org/v2/country/USA/indicator/AG.PRD.CROP.XD?format=json&per_page=5"
```

**Sonuç göreceksin:**
```json
[
  {...metadata...},
  [
    {
      "indicator": {
        "id": "AG.PRD.CROP.XD",
        "value": "Crop production index"
      },
      "country": {...},
      "value": 110.5,
      "date": "2023"
    }
  ]
]
```

### 2. Agriculture.com RSS - ✅ HEMEN ÇALIŞİYOR

```bash
curl "https://www.agriculture.com/rss"
```

**Gerçek haberler göreceksin** (XML formatında)

## 🔑 API Key Gerektiren (Ücretsiz Tier)

### 1. Alpha Vantage (Commodities)

#### Kayıt:
1. Git: https://www.alphavantage.co/support/#api-key
2. Email gir
3. Hemen key alırsın (örn: `ABC123XYZ`)

#### Test:
```bash
curl "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=CORN&apikey=YOUR_KEY"
```

**Örnek sonuç:**
```json
{
  "Global Quote": {
    "01. symbol": "CORN",
    "05. price": "450.25",
    "09. change": "5.50",
    "10. change percent": "1.24%"
  }
}
```

**Limitler:** 500 calls/day (ÜCRETSIZ)

### 2. WeatherAPI

#### Kayıt:
1. Git: https://www.weatherapi.com/signup.aspx
2. Email + şifre
3. API key al

#### Test:
```bash
curl "https://api.weatherapi.com/v1/forecast.json?key=YOUR_KEY&q=Chicago&days=7"
```

**Örnek sonuç:**
```json
{
  "location": {
    "name": "Chicago",
    "country": "USA"
  },
  "current": {
    "temp_c": 22.5,
    "condition": {
      "text": "Partly cloudy"
    }
  }
}
```

**Limitler:** 1,000,000 calls/month (ÜCRETSIZ)

### 3. NewsAPI

#### Kayıt:
1. Git: https://newsapi.org/register
2. Email + şifre
3. API key al

#### Test:
```bash
curl "https://newsapi.org/v2/everything?q=agriculture&apiKey=YOUR_KEY"
```

**Limitler:** 100 requests/day (Developer plan - ÜCRETSIZ)

## 🚀 Swift'te Test

### Minimal Test Code

```swift
import Foundation

// TEST 1: World Bank (No key needed!)
func testWorldBank() async {
    let url = URL(string: "https://api.worldbank.org/v2/country/USA/indicator/AG.PRD.CROP.XD?format=json&per_page=5")!

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            print("✅ World Bank Data:", json.count, "arrays")
            if json.count > 1 {
                let dataArray = json[1] as! [[String: Any]]
                print("   Records:", dataArray.count)
                print("   First value:", dataArray.first?["value"] ?? "N/A")
            }
        }
    } catch {
        print("❌ Error:", error)
    }
}

// TEST 2: Alpha Vantage (needs key)
func testAlphaVantage(apiKey: String) async {
    let url = URL(string: "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=CORN&apikey=\(apiKey)")!

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let quote = json["Global Quote"] as? [String: String] {
            print("✅ Alpha Vantage:")
            print("   Symbol:", quote["01. symbol"] ?? "N/A")
            print("   Price:", quote["05. price"] ?? "N/A")
            print("   Change:", quote["09. change"] ?? "N/A")
        }
    } catch {
        print("❌ Error:", error)
    }
}

// RUN TESTS
Task {
    print("🧪 Testing Real APIs...\n")

    await testWorldBank()

    // Uncomment after getting API key:
    // await testAlphaVantage(apiKey: "YOUR_KEY_HERE")

    print("\n✅ Tests complete!")
}
```

## 📱 App'te Kullanım

### DataSyncService'i Güncelle

```swift
// AgriMarket/Services/DataSyncService.swift

func syncCommodities() async throws {
    print("🌾 Syncing commodities...")

    // OPTION 1: Use real data service
    let realData = RealDataService.shared
    let (commodities, _, _) = try await realData.fetchAllRealData()

    print("✅ Fetched \(commodities.count) commodities from real APIs")

    // Save to CoreData
    await persistence.performBackgroundTask { context in
        for scraped in commodities {
            // ... save logic
        }
    }
}
```

## ⚡ Hızlı Başlangıç

### 1. En Kolay (No Keys)

```swift
// Sadece World Bank API kullan
let service = RealDataService.shared
let data = try await service.fetchWorldBankAgriculturalData()
print("✅ Got \(data.count) records")
```

### 2. Orta Seviye (1 Key)

```swift
// Alpha Vantage key al (5 dakika)
let service = RealDataService.shared
service.alphaVantageKey = "YOUR_KEY" // Set this

let quote = try await service.fetchAlphaVantageCommodity(symbol: "CORN")
print("✅ CORN price: $\(quote.price)")
```

### 3. Full Implementation (3 Keys)

```swift
// All APIs configured
let service = RealDataService.shared
service.alphaVantageKey = "..."
service.weatherAPIKey = "..."
service.newsAPIKey = "..."

let (commodities, news, weather) = try await service.fetchAllRealData()
print("✅ Commodities: \(commodities.count)")
print("✅ News: \(news.count)")
print("✅ Weather: \(weather.count)")
```

## 🎯 Gerçeklik Kontrolü

### Terminal'de doğrula:

```bash
# Test 1: World Bank (works immediately)
curl -s "https://api.worldbank.org/v2/country/USA/indicator/AG.PRD.CROP.XD?format=json" | python3 -m json.tool | head -20

# Test 2: RSS Feed (works immediately)
curl -s "https://www.agriculture.com/rss" | grep -o '<title>.*</title>' | head -5

# Test 3: With your Alpha Vantage key
curl "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=IBM&apikey=demo"
```

## ✅ Doğrulama Kriterleri

Başarılı implementation için:

- [ ] World Bank API'den veri çekebiliyor
- [ ] RSS feed'leri parse edebiliyor
- [ ] En az 1 API key'i çalışıyor
- [ ] Veriler CoreData'ya kaydediliyor
- [ ] UI'da görünüyor
- [ ] Offline mode çalışıyor (cache'den)
- [ ] Hata durumunda graceful fallback

## 🚨 Yaygın Hatalar

### 1. "Invalid API Key"
```
✅ Çözüm: API key'i kontrol et, yeniden kayıt ol
```

### 2. "Rate Limit Exceeded"
```
✅ Çözüm: Cache kullan, daha az sıklıkta sync yap
```

### 3. "Network Error"
```
✅ Çözüm: Timeout artır, retry logic ekle
```

### 4. "No Data"
```
✅ Çözüm: API response'u print et, JSON structure kontrol et
```

## 🎁 Bonus: Mock Data Fallback

```swift
func fetchCommoditiesWithFallback() async throws -> [Commodity] {
    do {
        // Try real API
        let real = try await RealDataService.shared.fetchAllRealData()
        if !real.commodities.isEmpty {
            return convertToCommodities(real.commodities)
        }
    } catch {
        print("⚠️ Real API failed, using mock data")
    }

    // Fallback to mock data
    return Commodity.sampleData
}
```

## 📊 Beklenen Sonuçlar

**Başarılı test:**
```
🧪 Testing Real APIs...

✅ World Bank Data: 2 arrays
   Records: 5
   First value: 110.5

✅ Alpha Vantage:
   Symbol: CORN
   Price: 450.25
   Change: 5.50

✅ Tests complete!
```

**App'te:**
- Dashboard'da 3-5 gerçek emtia fiyatı
- 10-20 gerçek haber başlığı
- 3 bölge hava durumu
- Tüm veriler offline erişilebilir

## 🎯 Sonuç

**Mock data** → **Real data** geçişi:
1. ✅ World Bank API (immediate, no key)
2. ✅ RSS feeds (immediate, no key)
3. ⏳ Get 1 API key (5 min) → Basic working app
4. ⏳ Get 3 API keys (15 min) → Full featured app
5. ⏳ Add error handling + caching → Production ready
