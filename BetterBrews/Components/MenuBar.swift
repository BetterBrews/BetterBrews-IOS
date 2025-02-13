//
//  File.swift
//  BetterBrews
//
//  Created by Colby Haskell on 11/8/24.
//
import SwiftUI

enum MenuFilter: String, CaseIterable {
    case showAll
    case Favorites
    case Espresso
    case Immersion
    case Pourover
    case Drip
    case Custom
}

struct MenuBar : View {
  @Binding var menuFilter: MenuFilter
  @Binding var isShowingAddBrewView: Bool
  
  @State private var isExpanded = false
  
  func menuButton(text: String, filter: MenuFilter) -> some View {
      RoundedButton(buttonText: text, isSelected: (menuFilter == filter), action: { menuFilter = filter })
  }
  
  var body: some View {
    HStack {
      Menu(content: {
        ForEach(MenuFilter.allCases, id: \.self) { menuCase in
          menuButton(text: menuCase == MenuFilter.showAll ? "Show All" : menuCase.rawValue, filter: menuCase)
        }
      }, label: {
        RoundedButton(buttonText: menuFilter == MenuFilter.showAll ? "Show All" : menuFilter.rawValue, buttonImage: "line.horizontal.3.circle", isSelected: true, action: {})
      })
      Spacer()
      Button(action: { isShowingAddBrewView.toggle() }) {
        Image(systemName: "plus")
          .foregroundColor(.white)
          .font(.subheadline)
          .padding(5)
          .background(Circle().foregroundColor(Color("gold")))
      }
      .sheet(isPresented: $isShowingAddBrewView, content: {
        AddBrewView()
          .environment(\.colorScheme, .dark)
      })
    }
    .padding(.horizontal)
  }
}
