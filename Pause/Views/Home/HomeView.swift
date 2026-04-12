import SwiftUI

struct HomeView: View {
  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()
      VStack(spacing: 16) {
        Text("Pause")
          .font(.pauseWordmark)
          .foregroundStyle(Color.cream)
        Text("Setup complete. Build order begins here.")
          .font(.pauseBody)
          .foregroundStyle(Color.cream.opacity(0.8))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 32)
      }
    }
  }
}

#Preview {
  HomeView()
}
