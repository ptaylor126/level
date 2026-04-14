import SwiftUI

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
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
      )
      .shadow(
        color: shadowColor,
        radius: shadowRadius,
        x: 0,
        y: shadowY
      )
  }

  private var shadowColor: Color {
    isLuminous ? Color.teaGreen.opacity(0.3) : Color.black.opacity(0.12)
  }

  private var shadowRadius: CGFloat {
    isLuminous ? 30 : 24
  }

  private var shadowY: CGFloat {
    isLuminous ? 10 : 8
  }

  private var isLuminous: Bool {
    background == .teaGreen
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    VStack(spacing: 16) {
      LevelCard(background: .teaGreen) {
        Text("Tea Green card — glows")
          .font(.levelBody)
          .foregroundStyle(Color.vintageGrape)
      }
      LevelCard(background: .cream) {
        Text("Cream card — lifted")
          .font(.levelBody)
          .foregroundStyle(Color.vintageGrape)
      }
      LevelCard(background: .pastelPink) {
        Text("Pink card")
          .font(.levelBody)
          .foregroundStyle(Color.rose)
      }
    }
    .padding(20)
  }
}
