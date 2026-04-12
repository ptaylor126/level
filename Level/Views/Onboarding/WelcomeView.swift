import SwiftUI

struct WelcomeView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Use your phone less.")
        .font(LevelFont.bold(32))
        .foregroundStyle(Color.cream)
        .multilineTextAlignment(.leading)
        .staged(0.05)
      Text("Level makes you wait a few seconds before opening the apps that suck you in. That's it.")
        .font(.levelBody)
        .foregroundStyle(Color.cream.opacity(0.75))
        .multilineTextAlignment(.leading)
        .lineSpacing(4)
        .staged(0.18)
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    WelcomeView()
      .padding(20)
  }
}
