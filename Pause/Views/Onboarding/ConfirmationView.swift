import SwiftUI

struct ConfirmationView: View {
  let onFinish: () -> Void

  var body: some View {
    VStack(spacing: 32) {
      Spacer()
      PauseIconView(icon: .heart, size: 72, color: .teaGreen)
      VStack(spacing: 12) {
        Text("You're all set.")
          .font(PauseFont.bold(28))
          .foregroundStyle(Color.cream)
          .multilineTextAlignment(.center)
        Text("Pause is on your side. Take it one breath at a time.")
          .font(.pauseBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .multilineTextAlignment(.center)
          .lineSpacing(4)
      }
      Spacer()
      PauseButton(title: "Start using Pause", style: .primaryOnDark, action: onFinish)
    }
  }
}
