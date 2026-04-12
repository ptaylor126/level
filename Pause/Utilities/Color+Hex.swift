import SwiftUI

extension Color {
  init(hex: String) {
    let trimmed = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var value: UInt64 = 0
    Scanner(string: trimmed).scanHexInt64(&value)

    let a, r, g, b: UInt64
    switch trimmed.count {
    case 3:
      (a, r, g, b) = (255, (value >> 8) * 17, (value >> 4 & 0xF) * 17, (value & 0xF) * 17)
    case 6:
      (a, r, g, b) = (255, value >> 16, value >> 8 & 0xFF, value & 0xFF)
    case 8:
      (a, r, g, b) = (value >> 24, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF)
    default:
      (a, r, g, b) = (255, 0, 0, 0)
    }

    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }

  static let vintageGrape = Color(hex: "473144")
  static let pastelPink = Color(hex: "FFCAD4")
  static let teaGreen = Color(hex: "DDF4C9")
  static let cream = Color(hex: "FFF8F0")

  static let mutedGrape = Color(hex: "6B5068")
  static let deepGrape = Color(hex: "2E1F2C")
  static let warmGrey = Color(hex: "E8DDD5")
  static let darkGreen = Color(hex: "3A5A28")
  static let rose = Color(hex: "6B3040")
}
