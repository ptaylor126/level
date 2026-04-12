import SwiftUI

/// Reusable card container that enforces the Level design system.
/// Handles background colour, corner radius, inner padding, and the optional
/// Warm Grey border used on Cream-background cards.
struct LevelCard<Content: View>: View {
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
      LevelCard(background: .cream, showBorder: true) {
        Text("Cream card with border")
          .font(.levelBody)
          .foregroundStyle(Color.vintageGrape)
      }
      LevelCard(background: .pastelPink) {
        Text("Pink card, no border")
          .font(.levelBody)
          .foregroundStyle(Color.rose)
      }
    }
    .padding(20)
  }
}
