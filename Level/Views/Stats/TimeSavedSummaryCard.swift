import SwiftUI

struct TimeSavedSummaryCard: View {
  var timeSaved: TimeInterval
  var vsLastWeek: Double

  private var cardBackground: Color {
    timeSaved > 0 ? .teaGreen : .cream
  }

  private var formattedTime: String {
    let seconds = Int(timeSaved)
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    if hours > 0 { return "\(hours)h \(minutes)m" }
    return "\(minutes)m"
  }

  private var subtitle: String {
    if timeSaved <= 0 {
      return "Tough week. New one starts Monday."
    }
    let pct = Int(abs(vsLastWeek).rounded())
    if vsLastWeek > 1 {
      return "That's \(pct)% better than last week"
    }
    return "Same as last week — keep at it"
  }

  var body: some View {
    LevelCard(background: cardBackground, showBorder: timeSaved <= 0) {
      VStack(alignment: .leading, spacing: 8) {
        Text("SAVED THIS WEEK")
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(Color.vintageGrape)

        if timeSaved > 0 {
          Text(formattedTime)
            .font(.levelDisplay)
            .foregroundStyle(Color.vintageGrape)
        } else {
          Text("0m")
            .font(.levelDisplay)
            .foregroundStyle(Color.vintageGrape.opacity(0.4))
        }

        Text(subtitle)
          .font(.levelCaption)
          .foregroundStyle(Color.vintageGrape.opacity(0.7))
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    VStack(spacing: 12) {
      TimeSavedSummaryCard(timeSaved: 5400, vsLastWeek: 20)
        .padding(.horizontal, 20)
      TimeSavedSummaryCard(timeSaved: 0, vsLastWeek: 0)
        .padding(.horizontal, 20)
    }
  }
}
