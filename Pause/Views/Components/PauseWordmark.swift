import SwiftUI

struct PauseWordmark: View {
  var size: CGFloat = 28
  var color: Color = .cream

  var body: some View {
    Text("Pause")
      .font(PauseFont.wordmark(size))
      .foregroundStyle(color)
  }
}
