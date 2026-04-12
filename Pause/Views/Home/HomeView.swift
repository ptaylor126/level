import SwiftUI

struct HomeView: View {
  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()
      VStack(spacing: 16) {
        PauseWordmark()
        Text("Home screen coming next.")
          .font(.pauseBody)
          .foregroundStyle(Color.cream.opacity(0.6))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 32)
      }
    }
  }
}

#Preview {
  HomeView()
}
