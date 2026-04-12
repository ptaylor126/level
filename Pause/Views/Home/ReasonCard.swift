import SwiftUI

/// Full-width card showing one of the user's personal reasons.
/// Heart icon, "Why I'm Doing This" label, rotating reason text.
struct ReasonCard: View {
  /// The user's reasons. The card displays one at a time, cycling on each app open.
  var reasons: [String] = [
    "Be more present with my family.",
    "Read more books.",
    "Sleep better.",
    "Get more work done.",
  ]
  var displayIndex: Int = 0

  private var currentReason: String {
    guard !reasons.isEmpty else { return "" }
    return reasons[displayIndex % reasons.count]
  }

  var body: some View {
    PauseCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 12) {
        // Header row
        HStack(spacing: 8) {
          PauseIconView(icon: .heart, size: 16, color: .vintageGrape)

          Text("WHY I'M DOING THIS")
            .font(.pauseLabel)
            .tracking(0.5)
            .foregroundStyle(Color.vintageGrape)

          Spacer()
        }

        // Reason text
        Text(currentReason)
          .font(.pauseH2)
          .foregroundStyle(Color.vintageGrape)
          .fixedSize(horizontal: false, vertical: true)
          .lineSpacing(4)
      }
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    VStack(spacing: 12) {
      ReasonCard(displayIndex: 0)
      ReasonCard(displayIndex: 1)
    }
    .padding(20)
  }
}
