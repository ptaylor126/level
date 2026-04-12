import SwiftUI

struct WelcomeView: View {
  let onContinue: () -> Void

  var body: some View {
    VStack(spacing: 32) {
      Spacer()
      Text("Pause")
        .font(.pauseWordmark)
        .foregroundStyle(Color.cream)
      VStack(spacing: 16) {
        Text("Take back your time.")
          .font(PauseFont.bold(28))
          .foregroundStyle(Color.cream)
          .multilineTextAlignment(.center)
        Text("Pause adds a small moment of friction before the apps that pull you in. No lectures. No guilt. Just a breath.")
          .font(.pauseBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .multilineTextAlignment(.center)
          .lineSpacing(4)
          .padding(.horizontal, 12)
      }
      Spacer()
      PauseButton(title: "Get started", style: .primaryOnDark, action: onContinue)
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    WelcomeView(onContinue: {})
      .padding(20)
  }
}
