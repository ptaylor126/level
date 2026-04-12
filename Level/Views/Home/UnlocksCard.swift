import SwiftUI

/// Half-width card showing remaining unlocks for today.
/// Cream background with subtle Warm Grey border.
struct UnlocksCard: View {
  var remaining: Int = 6
  var total: Int = 10

  private var isLow: Bool { remaining <= 2 }

  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 0) {
        // Label
        Text("UNLOCKS LEFT")
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(Color.vintageGrape)

        Spacer(minLength: 12)

        // Remaining count — large display number
        Text("\(remaining)")
          .font(.levelDisplay)
          .foregroundStyle(Color.vintageGrape)

        Spacer(minLength: 4)

        // Subtitle
        Text("of \(total) today")
          .font(.levelCaption)
          .foregroundStyle(Color.mutedGrape)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    HStack(spacing: 12) {
      UnlocksCard(remaining: 6, total: 10)
      UnlocksCard(remaining: 1, total: 10)
    }
    .padding(20)
  }
}
