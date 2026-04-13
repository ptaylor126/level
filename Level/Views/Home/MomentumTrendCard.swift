import SwiftUI

struct MomentumTrendCard: View {
  var scores: [Double]
  var dayLabels: [String] = []

  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Text("MOMENTUM TREND")
            .font(.levelLabel)
            .tracking(0.5)
            .foregroundStyle(Color.vintageGrape)
          Spacer()
          LevelIconView(icon: .chart, size: 16, color: .mutedGrape)
        }

        if scores.count < 2 {
          Text("Check back in a couple of days.")
            .font(.levelCaption)
            .foregroundStyle(Color.mutedGrape)
            .frame(height: 80)
        } else {
          TrendLine(scores: scores, dayLabels: dayLabels)
            .frame(height: 80)
        }
      }
    }
  }
}

private struct TrendLine: View {
  let scores: [Double]
  let dayLabels: [String]

  private var minScore: Double { max(0, (scores.min() ?? 0) - 5) }
  private var maxScore: Double { min(100, (scores.max() ?? 100) + 5) }
  private var range: Double { max(maxScore - minScore, 1) }

  var body: some View {
    GeometryReader { geo in
      ZStack(alignment: .bottomLeading) {
        Path { path in
          guard scores.count >= 2 else { return }
          let stepX = geo.size.width / CGFloat(scores.count - 1)

          for (i, score) in scores.enumerated() {
            let x = CGFloat(i) * stepX
            let y = geo.size.height * (1 - CGFloat((score - minScore) / range))
            if i == 0 {
              path.move(to: CGPoint(x: x, y: y))
            } else {
              path.addLine(to: CGPoint(x: x, y: y))
            }
          }
        }
        .stroke(Color.teaGreen, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

        ForEach(scores.indices, id: \.self) { i in
          let stepX = geo.size.width / CGFloat(scores.count - 1)
          let x = CGFloat(i) * stepX
          let y = geo.size.height * (1 - CGFloat((scores[i] - minScore) / range))

          Circle()
            .fill(i == scores.count - 1 ? Color.teaGreen : Color.teaGreen.opacity(0.5))
            .frame(width: i == scores.count - 1 ? 8 : 5, height: i == scores.count - 1 ? 8 : 5)
            .position(x: x, y: y)
        }

        if !dayLabels.isEmpty {
          HStack {
            ForEach(dayLabels.indices, id: \.self) { i in
              if i < dayLabels.count {
                Text(dayLabels[i])
                  .font(.levelLabel)
                  .tracking(0.5)
                  .foregroundStyle(Color.mutedGrape)
              }
              if i < dayLabels.count - 1 {
                Spacer()
              }
            }
          }
          .offset(y: geo.size.height + 12)
        }
      }
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    MomentumTrendCard(
      scores: [50, 52, 55, 53, 56, 58, 61],
      dayLabels: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    )
    .padding(20)
  }
}
