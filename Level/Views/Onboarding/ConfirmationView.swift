import SwiftUI

struct ConfirmationView: View {
  @State private var heartScale: CGFloat = 0.3
  @State private var heartOpacity: Double = 0

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      LevelIconView(icon: .heart, size: 72, color: .teaGreen)
        .scaleEffect(heartScale)
        .opacity(heartOpacity)
        .onAppear {
          withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.05)) {
            heartScale = 1
            heartOpacity = 1
          }
        }
      VStack(alignment: .leading, spacing: 12) {
        Text("Done.")
          .font(LevelFont.bold(32))
          .foregroundStyle(Color.cream)
          .multilineTextAlignment(.leading)
          .staged(0.25)
        Text("Now those apps will make you wait. Good luck.")
          .font(.levelBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .multilineTextAlignment(.leading)
          .lineSpacing(4)
          .staged(0.38)
      }
    }
  }
}
