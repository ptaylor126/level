import SwiftUI

enum ShareProgressHelper {
  /// Renders ShareCardView to a UIImage at 3x scale.
  /// Returns nil if rendering fails (e.g. running on macOS without UIKit).
  @MainActor
  static func renderImage(
    momentum: Int,
    streak: Int,
    xp: Int,
    timeSavedLabel: String
  ) -> UIImage? {
    let card = ShareCardView(
      momentum: momentum,
      streak: streak,
      xp: xp,
      timeSavedLabel: timeSavedLabel
    )

    let renderer = ImageRenderer(content: card)
    renderer.scale = 3.0
    return renderer.uiImage
  }
}
