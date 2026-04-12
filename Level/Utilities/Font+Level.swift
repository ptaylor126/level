import SwiftUI

enum LevelFont {
  static let family = "PlusJakartaSans"

  static func regular(_ size: CGFloat) -> Font {
    .custom("\(family)-Regular", size: size)
  }
  static func medium(_ size: CGFloat) -> Font {
    .custom("\(family)-Medium", size: size)
  }
  static func bold(_ size: CGFloat) -> Font {
    .custom("\(family)-Bold", size: size)
  }
  static func extraBold(_ size: CGFloat) -> Font {
    .custom("\(family)-ExtraBold", size: size)
  }
  static func wordmark(_ size: CGFloat = 28) -> Font {
    .custom("Fraunces72pt-Bold", size: size)
  }
}

extension Font {
  static let levelWordmark = LevelFont.wordmark()
  static let levelDisplay = LevelFont.extraBold(36)
  static let levelH1 = LevelFont.bold(20)
  static let levelH2 = LevelFont.bold(17)
  static let levelBody = LevelFont.regular(15)
  static let levelLabel = LevelFont.bold(11)
  static let levelCaption = LevelFont.regular(13)
}
