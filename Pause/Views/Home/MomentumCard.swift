import SwiftUI

/// Half-width card showing the user's momentum score and streak.
/// Always uses Pastel Pink background — the ONE pink card on the home screen.
struct MomentumCard: View {
  var score: Int = 74
  var streak: Int = 9

  var body: some View {
    PauseCard(background: .pastelPink) {
      VStack(alignment: .leading, spacing: 0) {
        // Label
        Text("MOMENTUM")
          .font(.pauseLabel)
          .tracking(0.5)
          .foregroundStyle(Color.rose)

        Spacer(minLength: 12)

        // Score badge
        Text("\(score)")
          .font(.pauseDisplay)
          .foregroundStyle(Color.darkGreen)
          .padding(.horizontal, 14)
          .padding(.vertical, 6)
          .background(Color.teaGreen)
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

        Spacer(minLength: 12)

        // Streak
        HStack(spacing: 4) {
          PauseIconView(icon: .flame, size: 14, color: .rose)
          Text("\(streak) day streak")
            .font(.pauseCaption)
            .foregroundStyle(Color.rose)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    HStack(spacing: 12) {
      MomentumCard(score: 74, streak: 9)
      Spacer()
    }
    .padding(20)
  }
}
