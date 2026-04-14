import SwiftUI

struct MomentumTrend30Card: View {
  var scores: [Double]
  var direction: String

  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Text("MOMENTUM — LAST 30 DAYS")
            .font(.levelLabel)
            .tracking(0.5)
            .foregroundStyle(Color.vintageGrape)

          Spacer()

          LevelIconView(icon: .chart, size: 16, color: .mutedGrape)
        }

        if scores.count < 3 {
          Text("Check back in a few days for your trend.")
            .font(.levelCaption)
            .foregroundStyle(Color.mutedGrape)
            .frame(height: 120)
        } else {
          Trend30Chart(scores: scores)
            .frame(height: 120)
        }

        Text(direction)
          .font(.levelCaption)
          .foregroundStyle(Color.mutedGrape)
      }
    }
  }
}

private struct Trend30Chart: View {
  let scores: [Double]

  private let yLabels: [Double] = [100, 75, 50, 25, 0]

  var body: some View {
    HStack(spacing: 8) {
      yAxis

      GeometryReader { geo in
        ZStack {
          gridLines(in: geo)
          linePath(in: geo)
          endDot(in: geo)
        }
      }
    }
  }

  private var yAxis: some View {
    VStack {
      ForEach(yLabels, id: \.self) { label in
        Text("\(Int(label))")
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(Color.mutedGrape)
        if label != 0 {
          Spacer()
        }
      }
    }
    .frame(width: 24)
  }

  private func gridLines(in geo: GeometryProxy) -> some View {
    let levels: [Double] = [0, 25, 50, 75, 100]
    return ZStack {
      ForEach(levels, id: \.self) { level in
        let y = geo.size.height * (1 - CGFloat(level / 100))
        Path { path in
          path.move(to: CGPoint(x: 0, y: y))
          path.addLine(to: CGPoint(x: geo.size.width, y: y))
        }
        .stroke(Color.warmGrey, lineWidth: 0.5)
      }
    }
  }

  private func linePath(in geo: GeometryProxy) -> some View {
    guard scores.count >= 2 else { return AnyView(EmptyView()) }

    let stepX = geo.size.width / CGFloat(scores.count - 1)

    let path = Path { p in
      for (i, score) in scores.enumerated() {
        let x = CGFloat(i) * stepX
        let y = geo.size.height * (1 - CGFloat(score / 100))
        if i == 0 {
          p.move(to: CGPoint(x: x, y: y))
        } else {
          p.addLine(to: CGPoint(x: x, y: y))
        }
      }
    }

    return AnyView(
      path.stroke(
        Color.teaGreen,
        style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
      )
    )
  }

  private func endDot(in geo: GeometryProxy) -> some View {
    guard let last = scores.last else { return AnyView(EmptyView()) }

    let stepX = geo.size.width / CGFloat(max(scores.count - 1, 1))
    let x = CGFloat(scores.count - 1) * stepX
    let y = geo.size.height * (1 - CGFloat(last / 100))

    return AnyView(
      ZStack {
        Circle()
          .fill(Color.teaGreen)
          .frame(width: 10, height: 10)
          .position(x: x, y: y)

        Text("\(Int(last.rounded()))")
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(Color.vintageGrape)
          .position(x: min(x + 18, geo.size.width - 12), y: y)
      }
    )
  }
}

private let previewScores: [Double] = (0..<30).map { i in
  let d = Double(i)
  return 50 + sin(d / 5) * 15 + d * 0.5
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    VStack(spacing: 12) {
      MomentumTrend30Card(
        scores: previewScores,
        direction: "Trending up"
      )

      MomentumTrend30Card(scores: [], direction: "Holding steady")
    }
    .padding(20)
  }
}
