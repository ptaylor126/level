import SwiftUI

struct ManagedAppsBreakdownCard: View {
  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Text("TODAY")
            .font(.levelLabel)
            .tracking(0.5)
            .foregroundStyle(Color.vintageGrape)

          Spacer()

          LevelIconView(icon: .chart, size: 16, color: .mutedGrape)
        }

        VStack(spacing: 8) {
          LevelIconView(icon: .phone, size: 28, color: .warmGrey)

          Text("Per-app breakdown coming soon.")
            .font(.levelCaption)
            .foregroundStyle(Color.mutedGrape)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
      }
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    ManagedAppsBreakdownCard()
      .padding(20)
  }
}
