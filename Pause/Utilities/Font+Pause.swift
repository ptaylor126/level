import SwiftUI

enum PauseFont {
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
  static let pauseWordmark = PauseFont.wordmark()
  static let pauseDisplay = PauseFont.extraBold(36)
  static let pauseH1 = PauseFont.bold(20)
  static let pauseH2 = PauseFont.bold(17)
  static let pauseBody = PauseFont.regular(15)
  static let pauseLabel = PauseFont.bold(11)
  static let pauseCaption = PauseFont.regular(13)
}
