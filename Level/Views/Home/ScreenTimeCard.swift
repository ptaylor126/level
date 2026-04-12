import SwiftUI

/// Full-width card showing today's total screen time and comparison to yesterday.
/// Background is Tea Green when improving (less than yesterday), Cream otherwise.
struct ScreenTimeCard: View {
  /// Today's screen time in seconds.
  var todaySeconds: TimeInterval = 5700   // 1h 35m mock
  /// Yesterday's screen time in seconds.
  var yesterdaySeconds: TimeInterval = 7200  // 2h 0m mock

  private var isImproving: Bool { todaySeconds < yesterdaySeconds }

  private var background: Color { isImproving ? .teaGreen : .cream }

  private var primaryTextColor: Color { isImproving ? .darkGreen : .vintageGrape }

  private var secondaryTextColor: Color { isImproving ? .darkGreen.opacity(0.7) : .mutedGrape }

  private var labelColor: Color { isImproving ? .darkGreen : .vintageGrape }

  private var formattedTime: String {
    let totalMinutes = Int(todaySeconds) / 60
    let hours = totalMinutes / 60
    let minutes = totalMinutes % 60
    if hours > 0 {
      return "\(hours)h \(minutes)m"
    }
    return "\(minutes)m"
  }

  private var changeDescription: String {
    guard yesterdaySeconds > 0 else { return "No data for yesterday" }
    let diff = abs(yesterdaySeconds - todaySeconds)
    let diffMinutes = Int(diff) / 60
    let diffHours = diffMinutes / 60
    let diffMins = diffMinutes % 60

    let diffString: String
    if diffHours > 0 {
      diffString = "\(diffHours)h \(diffMins)m"
    } else {
      diffString = "\(diffMins)m"
    }

    if isImproving {
      return "\(diffString) less than yesterday"
    } else if todaySeconds > yesterdaySeconds {
      return "\(diffString) more than yesterday"
    } else {
      return "Same as yesterday"
    }
  }

  var body: some View {
    LevelCard(background: background, showBorder: !isImproving) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 8) {
          // Label
          Text("SCREEN TIME TODAY")
            .font(.levelLabel)
            .tracking(0.5)
            .foregroundStyle(labelColor)

          // Display number
          Text(formattedTime)
            .font(.levelDisplay)
            .foregroundStyle(primaryTextColor)

          // Comparison caption
          Text(changeDescription)
            .font(.levelCaption)
            .foregroundStyle(secondaryTextColor)
        }

        Spacer()

        // Phone icon — top-right of card
        LevelIconView(icon: .phone, size: 28, color: labelColor.opacity(0.5))
          .padding(.top, 2)
      }
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    VStack(spacing: 12) {
      ScreenTimeCard(todaySeconds: 5700, yesterdaySeconds: 7200)   // improving
      ScreenTimeCard(todaySeconds: 8100, yesterdaySeconds: 7200)   // worse
    }
    .padding(20)
  }
}
