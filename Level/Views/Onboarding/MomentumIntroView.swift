import SwiftUI

struct MomentumIntroView: View {
  @State private var scoreVisible = false
  @State private var arrowVisible = false

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Meet your\nmomentum score.")
          .font(LevelFont.bold(32))
          .foregroundStyle(Color.cream)
          .staged(0.05)
        Text("Your score starts at 50 out of 100. Good days push it up. Bad days bring it down a little \u{2014} not to zero. It's not about being perfect. It's about the trend.")
          .font(.levelBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .lineSpacing(4)
          .staged(0.15)
      }

      HStack {
        Spacer()
        VStack(spacing: 8) {
          ZStack {
            Text("50")
              .font(.levelDisplay)
              .foregroundStyle(Color.darkGreen)
              .padding(.horizontal, 24)
              .padding(.vertical, 12)
              .background(Color.teaGreen)
              .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
              .scaleEffect(scoreVisible ? 1 : 0.5)
              .opacity(scoreVisible ? 1 : 0)

            Image(systemName: "arrow.up.right")
              .font(.system(size: 28, weight: .bold))
              .foregroundStyle(Color.teaGreen)
              .offset(x: 50, y: -30)
              .scaleEffect(arrowVisible ? 1 : 0)
              .opacity(arrowVisible ? 1 : 0)
          }

          Text("OUT OF 100")
            .font(.levelLabel)
            .tracking(0.5)
            .foregroundStyle(Color.cream.opacity(0.5))
            .opacity(scoreVisible ? 1 : 0)
        }
        .padding(.vertical, 32)
        Spacer()
      }
      .onAppear {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
          scoreVisible = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.65).delay(0.7)) {
          arrowVisible = true
        }
      }
    }
  }
}
