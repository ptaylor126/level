import SwiftUI

/// Full-width card showing one of the user's personal reasons.
/// Heart icon, "Why I'm Doing This" label, rotating reason text.
struct ReasonCard: View {
  /// The user's reasons. The card displays one at a time, cycling on each app open.
  var reasons: [String] = []
  var displayIndex: Int = 0

  private var currentReason: String {
    guard !reasons.isEmpty else { return "Add a reason in settings." }
    let dayOffset = Calendar.current.component(.hour, from: Date()) / 6
    let index = (displayIndex + dayOffset) % reasons.count
    return reasons[index]
  }

  var body: some View {
    LevelCard(background: .pastelPink, showBorder: false) {
      VStack(alignment: .leading, spacing: 12) {
        HStack(spacing: 8) {
          LevelIconView(icon: .heart, size: 16, color: .rose)
          Text("WHY I'M DOING THIS")
            .font(.levelLabel)
            .tracking(0.5)
            .foregroundStyle(Color.rose)
          Spacer()
        }

        Text(currentReason)
          .font(.levelH2)
          .foregroundStyle(Color.rose)
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
