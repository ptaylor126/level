import SwiftUI

/// Fixed-size card rendered to UIImage via ImageRenderer.
/// Keep layout self-contained — no external dependencies beyond design tokens.
struct ShareCardView: View {
  let momentum: Int
  let streak: Int
  let xp: Int
  let timeSavedLabel: String

  var body: some View {
    ZStack {
      Color.vintageGrape

      VStack(alignment: .leading, spacing: 0) {
        // Top bar — wordmark
        HStack {
          LevelWordmark(size: 36, color: .cream)
          Spacer()
        }
        .padding(.bottom, 40)

        // Momentum badge
        VStack(alignment: .leading, spacing: 8) {
          Text("MOMENTUM")
            .font(.levelLabel)
            .tracking(0.5)
            .foregroundStyle(Color.mutedGrape)

          Text("\(momentum)")
            .font(LevelFont.extraBold(80))
            .foregroundStyle(Color.teaGreen)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.teaGreen.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(.bottom, 36)

        // Stats stack
        VStack(alignment: .leading, spacing: 14) {
          statRow(value: "\(streak) day streak")
          statRow(value: "\(xp) XP")
          statRow(value: "\(timeSavedLabel) saved this week")
        }

        Spacer()

        // Footer
        HStack {
          Spacer()
          Text("Level.")
            .font(LevelFont.wordmark(16))
            .foregroundStyle(Color.mutedGrape)
        }
      }
      .padding(32)
    }
    .frame(width: 400, height: 500)
  }

  private func statRow(value: String) -> some View {
    Text(value)
      .font(LevelFont.bold(17))
      .foregroundStyle(Color.cream)
  }
}

#Preview {
  ShareCardView(
    momentum: 72,
    streak: 5,
    xp: 340,
    timeSavedLabel: "3h 20m"
  )
}
