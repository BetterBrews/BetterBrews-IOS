import SwiftUI

// Primary Brand Color
let redOrange50 = Color(hex: 0xFEF3_F2FF)
let redOrange100 = Color(hex: 0xFDE4_E3FF)
let redOrange200 = Color(hex: 0xFCCE_CCFF)
let redOrange300 = Color(hex: 0xF9AB_A8FF)
let redOrange400 = Color(hex: 0xF37B_76FF)
let redOrange500 = Color(hex: 0xEB64_5EFF)

// Secondary Brand Color
let blue50 = Color(hex: 0xF2F4_FCFF)

let blue800 = Color(hex: 0x393F_88FF)

let grey100 = Color(hex: 0xF2F0_F0FF)
let grey400 = Color(hex: 0xB8B8_B9FF)

let white = Color(hex: 0xFFFF_FFFF)
let black = Color(hex: 0x2626_26FF)

/*
  Color extension to create colors from hex codes (RGBA)
 */
extension Color {
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 24) & 0xff) / 255,
            green: Double((hex >> 16) & 0xff) / 255,
            blue: Double((hex >> 08) & 0xff) / 255,
            opacity: Double((hex >> 00) & 0xff) / 255
        )
    }
}
