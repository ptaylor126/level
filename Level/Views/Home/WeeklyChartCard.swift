import SwiftUI

/// Data for a single day in the weekly chart.
struct WeeklyDayData: Identifiable {
  let id = UUID()
  let label: String       // "Mon", "Tue", etc.
  let seconds: TimeInterval
  let goalMet: Bool
  let isToday: Bool
}

/// Full-width card showing a 7-bar chart for Mon–Sun screen time.
/// Vintage Grape bars for normal days, Tea Green for goal-met days.
struct WeeklyChartCard: View {
  var days: [WeeklyDayData] = WeeklyChartCard.mockDays
  /// The daily screen-time goal in seconds. Used to scale bar heights.
  var goalSeconds: TimeInterval = 7200  // 2h default

  // The tallest value drives the chart scale.
  private var maxSeconds: TimeInterval {
    max(days.map(\.seconds).max() ?? goalSeconds, goalSeconds)
  }

  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 16) {
        // Header
        HStack {
          Text("THIS WEEK")
            .font(.levelLabel)
            .tracking(0.5)
            .foregroundStyle(Color.vintageGrape)

          Spacer()

          LevelIconView(icon: .chart, size: 16, color: .mutedGrape)
        }

        if days.allSatisfy({ $0.seconds == 0 }) {
          Text("Check back tomorrow for your first chart.")
            .font(.levelCaption)
            .foregroundStyle(Color.mutedGrape)
            .frame(height: 80)
        } else {
          HStack(alignment: .bottom, spacing: 8) {
            ForEach(days) { day in
              DayBar(
                day: day,
                heightFraction: maxSeconds > 0 ? day.seconds / maxSeconds : 0
              )
            }
          }
          .frame(height: 80)
        }
      }
    }
  }

  // MARK: - Mock data
  static var mockDays: [WeeklyDayData] = [
    WeeklyDayData(label: "Mon", seconds: 6300,  goalMet: true,  isToday: false),
    WeeklyDayData(label: "Tue", seconds: 8100,  goalMet: false, isToday: false),
    WeeklyDayData(label: "Wed", seconds: 5400,  goalMet: true,  isToday: false),
    WeeklyDayData(label: "Thu", seconds: 7560,  goalMet: false, isToday: false),
    WeeklyDayData(label: "Fri", seconds: 6900,  goalMet: true,  isToday: false),
    WeeklyDayData(label: "Sat", seconds: 9000,  goalMet: false, isToday: false),
    WeeklyDayData(label: "Sun", seconds: 5700,  goalMet: true,  isToday: true),
  ]
}

// MARK: - DayBar

private struct DayBar: View {
  let day: WeeklyDayData
  /// 0.0 – 1.0, relative to the tallest bar.
  let heightFraction: Double

  private var barColor: Color {
    day.goalMet ? .teaGreen : .vintageGrape
  }

  private var labelColor: Color {
    day.isToday ? .vintageGrape : .mutedGrape
  }

  var body: some View {
    GeometryReader { geo in
      VStack(alignment: .center, spacing: 4) {
        Spacer(minLength: 0)

        // Bar — rounded top corners only
        let barHeight = max(geo.size.height * 0.75 * heightFraction, 4)
        RoundedCornerBar(radius: 4)
          .fill(barColor)
          .frame(height: barHeight)

        // Day label
        Text(day.label)
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(labelColor)
          .lineLimit(1)
      }
    }
    .frame(maxWidth: .infinity)
  }
}

// MARK: - RoundedCornerBar (top corners only)

/// A Shape that rounds only the top two corners of a rectangle.
private struct RoundedCornerBar: Shape {
  var radius: CGFloat

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let r = min(radius, rect.height / 2, rect.width / 2)
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
    path.addQuadCurve(
      to: CGPoint(x: rect.minX + r, y: rect.minY),
      control: CGPoint(x: rect.minX, y: rect.minY)
    )
    path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
    path.addQuadCurve(
      to: CGPoint(x: rect.maxX, y: rect.minY + r),
      control: CGPoint(x: rect.maxX, y: rect.minY)
    )
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.closeSubpath()
    return path
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    WeeklyChartCard()
      .padding(20)
  }
}
