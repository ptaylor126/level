import SwiftUI

struct XPHistoryCard: View {
  var totalXP: Int

  private var walkAwayXP: Int { Int((Double(totalXP) * 0.7).rounded()) }
  private var unlocksXP: Int { Int((Double(totalXP) * 0.2).rounded()) }
  private var goalsXP: Int { totalXP - walkAwayXP - unlocksXP }

  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 16) {
        Text("XP EARNED")
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(Color.vintageGrape)

        Text("\(totalXP)")
          .font(.levelDisplay)
          .foregroundStyle(Color.vintageGrape)

        VStack(alignment: .leading, spacing: 6) {
          xpRow(value: walkAwayXP, label: "from walking away")
          xpRow(value: unlocksXP, label: "from unlocks through Level")
          xpRow(value: goalsXP, label: "from staying under goals")
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func xpRow(value: Int, label: String) -> some View {
    HStack(spacing: 4) {
      Text("\(value)")
        .font(LevelFont.bold(13))
        .foregroundStyle(Color.vintageGrape)

      Text(label)
        .font(.levelCaption)
        .foregroundStyle(Color.mutedGrape)
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    XPHistoryCard(totalXP: 340)
      .padding(20)
  }
}
