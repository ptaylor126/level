import SwiftUI

/// Reusable card container that enforces the Pause design system.
/// Handles background colour, corner radius, inner padding, and the optional
/// Warm Grey border used on Cream-background cards.
struct PauseCard<Content: View>: View {
  var background: Color = .cream
  var padding: CGFloat = 16
  var showBorder: Bool = false
  @ViewBuilder var content: () -> Content

  var body: some View {
    content()
      .padding(padding)
      .background(background)
      .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
      .overlay(
        Group {
          if showBorder {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
              .strokeBorder(Color.warmGrey, lineWidth: 0.5)
          }
        }
      )
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    VStack(spacing: 12) {
      PauseCard(background: .cream, showBorder: true) {
        Text("Cream card with border")
          .font(.pauseBody)
          .foregroundStyle(Color.vintageGrape)
      }
      PauseCard(background: .pastelPink) {
        Text("Pink card, no border")
          .font(.pauseBody)
          .foregroundStyle(Color.rose)
      }
    }
    .padding(20)
  }
}
