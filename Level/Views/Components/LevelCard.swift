import SwiftUI

struct LevelCard<Content: View>: View {
  var background: Color = .cream
  var padding: CGFloat = 16
  var showBorder: Bool = false
  @ViewBuilder var content: () -> Content

  var body: some View {
    content()
      .padding(padding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(background)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .stroke(Color.white.opacity(0.2), lineWidth: 1)
      )
      .shadow(
        color: Color.black.opacity(shadowOpacity),
        radius: 12,
        x: 0,
        y: 6
      )
  }

  private var shadowOpacity: Double {
    if background == .teaGreen || background == .pastelPink {
      return 0.2
    }
    return 0.25
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    VStack(spacing: 20) {
      LevelCard(background: .teaGreen) {
        Text("Tea Green — glows")
          .font(.levelBody)
          .foregroundStyle(Color.vintageGrape)
      }
      LevelCard(background: .cream) {
        Text("Cream — lifted")
          .font(.levelBody)
          .foregroundStyle(Color.vintageGrape)
      }
      LevelCard(background: .pastelPink) {
        Text("Pink — glows")
          .font(.levelBody)
          .foregroundStyle(Color.rose)
      }
    }
    .padding(24)
  }
}
