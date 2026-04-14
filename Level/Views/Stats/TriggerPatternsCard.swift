import SwiftUI

struct TriggerPatternsCard: View {
  var triggerCounts: [(trigger: String, count: Int)]
  var topTrigger: String?

  private static let segmentColors: [Color] = [
    .teaGreen,
    .pastelPink,
    .mutedGrape,
    .warmGrey,
    Color(hex: "C5E8B0"),
  ]

  private var total: Int {
    triggerCounts.prefix(5).map(\.count).reduce(0, +)
  }

  private var hasEnoughData: Bool {
    triggerCounts.map(\.count).reduce(0, +) >= 5
  }

  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 16) {
        VStack(alignment: .leading, spacing: 4) {
          Text("Be on the level.")
            .font(.levelH2)
            .foregroundStyle(Color.vintageGrape)

          Text("Here's what drives you.")
            .font(.levelCaption)
            .foregroundStyle(Color.mutedGrape)
        }

        if hasEnoughData {
          VStack(spacing: 16) {
            DonutChart(
              segments: Array(triggerCounts.prefix(5)),
              colors: TriggerPatternsCard.segmentColors
            )
            .frame(width: 120, height: 120)
            .frame(maxWidth: .infinity)

            if let top = topTrigger {
              Text("You mostly reach for your phone when you're \(top.lowercased()).")
                .font(.levelCaption)
                .foregroundStyle(Color.vintageGrape)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            }

            legendView
          }
        } else {
          Text("Keep using Level and we'll show your patterns here.")
            .font(.levelCaption)
            .foregroundStyle(Color.mutedGrape)
            .padding(.vertical, 8)
        }
      }
    }
  }

  private var legendView: some View {
    let items = Array(triggerCounts.prefix(5).enumerated())
    return VStack(alignment: .leading, spacing: 6) {
      ForEach(items, id: \.offset) { index, item in
        HStack(spacing: 8) {
          Circle()
            .fill(TriggerPatternsCard.segmentColors[index % TriggerPatternsCard.segmentColors.count])
            .frame(width: 10, height: 10)

          Text(item.trigger)
            .font(.levelCaption)
            .foregroundStyle(Color.vintageGrape)

          Spacer()

          let pct = total > 0 ? Int((Double(item.count) / Double(total)) * 100) : 0
          Text("\(pct)%")
            .font(.levelLabel)
            .tracking(0.5)
            .foregroundStyle(Color.mutedGrape)
        }
      }
    }
  }
}

private struct DonutChart: View {
  let segments: [(trigger: String, count: Int)]
  let colors: [Color]

  private var total: Double {
    Double(segments.map(\.count).reduce(0, +))
  }

  var body: some View {
    ZStack {
      ForEach(segments.indices, id: \.self) { i in
        let fraction = total > 0 ? Double(segments[i].count) / total : 0
        let start = startAngle(for: i)
        let end = start + fraction

        Circle()
          .trim(from: start, to: end)
          .stroke(
            colors[i % colors.count],
            style: StrokeStyle(lineWidth: 20, lineCap: .butt)
          )
          .rotationEffect(.degrees(-90))
      }

      Circle()
        .fill(Color.cream)
        .frame(width: 80, height: 80)
    }
  }

  private func startAngle(for index: Int) -> Double {
    var angle: Double = 0
    for i in 0..<index {
      angle += total > 0 ? Double(segments[i].count) / total : 0
    }
    return angle
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    VStack(spacing: 12) {
      TriggerPatternsCard(
        triggerCounts: [
          (trigger: "Bored", count: 12),
          (trigger: "Habit", count: 8),
          (trigger: "Anxious", count: 5),
          (trigger: "Just checking", count: 4),
          (trigger: "Avoiding something", count: 3),
        ],
        topTrigger: "Bored"
      )

      TriggerPatternsCard(triggerCounts: [], topTrigger: nil)
    }
    .padding(20)
  }
}
