import SwiftUI

struct CurrentModeCard: View {
  let mode: LevelMode
  let modeTitle: String        // e.g. "Boss Level until 5pm"
  let nextChangeLabel: String? // e.g. "Base Level starts at 5pm"

  var body: some View {
    LevelCard(background: mode.cardColor, showBorder: false) {
      VStack(alignment: .leading, spacing: 6) {
        Text("NOW ACTIVE")
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(mode.textColor.opacity(0.6))

        Text(modeTitle)
          .font(LevelFont.extraBold(28))
          .foregroundStyle(mode.textColor)
          .fixedSize(horizontal: false, vertical: true)

        if let label = nextChangeLabel {
          Text(label)
            .font(.levelCaption)
            .foregroundStyle(mode.textColor.opacity(0.7))
            .padding(.top, 2)
        } else if mode == .off {
          Text("Taking a break from Level. That's fine.")
            .font(.levelCaption)
            .foregroundStyle(mode.textColor.opacity(0.7))
            .padding(.top, 2)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    VStack(spacing: 12) {
      CurrentModeCard(
        mode: .boss,
        modeTitle: "Boss Level until 9:00am",
        nextChangeLabel: "Base Level starts at 9:00am"
      )
      CurrentModeCard(
        mode: .rest,
        modeTitle: "Rest Level until 7:00am",
        nextChangeLabel: nil
      )
      CurrentModeCard(
        mode: .off,
        modeTitle: "Off",
        nextChangeLabel: nil
      )
    }
    .padding(20)
  }
}
