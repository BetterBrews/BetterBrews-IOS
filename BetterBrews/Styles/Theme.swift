import SwiftUI
import Foundation

// MARK: Sprintly theme colors
//
// - Defaults are specified for the light theme
public struct BBColors {
  public var background = grey100
  public var primary = redOrange500
  public var secondary = blue800
    
  public var textPrimary = black
  public var textAlternate = white

  public var buttonPrimary = redOrange500
  public var buttonTextPrimary = white
    
  public var sheetBackground = white
}

// Define default colors as light theme
private let BBLightColors = BBColors()

// Define dark color scheme overrides as necessary
private let BBDarkColors = BBColors(
  background: black
)

private var _isDarkMode = false

public var isDarkMode: Bool {
    return _isDarkMode
}

// MARK: Sprintly Typography System
public struct BBTypes {
  public var header1 = headerOne
  public var header2 = headerTwo
  public var header3 = headerThree
  public var header4 = headerFour

  public var paragraph = mobileParagraphType
  
  public var textXSmall = mobileTextXSmall
}

// MARK: Sprintly Dimensions
public struct BBDimens {
  public var smallCorner = smallCornerDimen
  public var mediumCorner = mediumCornerDimen
  public var largeCorner = largeCornerDimen
  public var extraLargeCorner = extraLargeCornerDimen
}

// MARK: Theme Root
//
// Used to trigger UI refreshes upon theme state changes
public class ThemeRootObject: ObservableObject {
  @Published var isDarkTheme = false
  func updateView() {
    self.objectWillChange.send()
  }
}

public struct BBThemeRoot<Content>: View where Content: View {
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  @StateObject var object = ThemeRootObject()
  @ViewBuilder var content: () -> Content

  /**
   Initialize to theme content with BetterBrews Theme

   Parameters:
     - content: UI content to be themed
  */
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
    if (colorScheme == .dark) != object.isDarkTheme {
      object.isDarkTheme.toggle()
    }
  }

  @ViewBuilder
  public var body: some View {
    content()
  }
}

// MARK: BetterBrews Theme
public struct BBTheme {
  public static var colors = BBColors()
  public static var types = BBTypes()
  public static var dimens = BBDimens()
}
