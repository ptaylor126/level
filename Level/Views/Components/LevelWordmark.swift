import SwiftUI

struct LevelWordmark: View {
  var size: CGFloat = 28
  var color: Color = .cream

  var body: some View {
    Text("Level")
      .font(LevelFont.wordmark(size))
      .foregroundStyle(color)
  }
}
