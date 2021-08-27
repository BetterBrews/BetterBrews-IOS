//
//  UtilityViews.swift
//  BetterBrews
//
//  Created by Colby Haskell on 8/20/21.
//

import Foundation
import SwiftUI

struct RoundedButton: View {
    var buttonText: String
    var buttonImage: String?
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            Button(action: { action() }) {
                if(buttonImage != nil) {
                    Image(systemName: buttonImage!)
                }
                Text(buttonText)
                    .foregroundColor(isSelected ? Color(.white) : Color(.white))
            }
        }
        .font(.subheadline)
        .foregroundColor(isSelected ? Color(.white) : Color("black"))
        .padding(.vertical, 5)
        .padding(.horizontal, 12)
        .background(RoundedRectangle(cornerRadius: 20).foregroundColor(isSelected ? Color("gold") : Color("tan")))
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }
}
