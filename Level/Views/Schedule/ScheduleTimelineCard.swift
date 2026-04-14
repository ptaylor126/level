import SwiftUI

struct ScheduleTimelineCard: View {
  let blocks: [ScheduleBlock]

  private let barHeight: CGFloat = 80
  private let labelHeight: CGFloat = 20
  private let hourLabels = [(0, "12am"), (6, "6am"), (12, "12pm"), (18, "6pm")]

  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 12) {
        Text("TODAY")
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(Color.mutedGrape)

        GeometryReader { geo in
          let totalWidth = geo.size.width

          ZStack(alignment: .topLeading) {
            // Track background
            RoundedRectangle(cornerRadius: 6, style: .continuous)
              .fill(Color.warmGrey)
              .frame(height: barHeight)

            // Mode segments
            ForEach(blocks.indices, id: \.self) { index in
              let block = blocks[index]
              segmentView(block: block, totalWidth: totalWidth)
            }

            // Current time indicator
            currentTimeIndicator(totalWidth: totalWidth)
          }
          .frame(height: barHeight)

          // Hour labels below
          ZStack(alignment: .topLeading) {
            ForEach(hourLabels, id: \.0) { (hour, label) in
              Text(label)
                .font(.levelLabel)
                .foregroundStyle(Color.mutedGrape)
                .position(
                  x: (CGFloat(hour) / 24.0) * totalWidth,
                  y: labelHeight / 2
                )
            }
          }
          .frame(height: labelHeight)
          .offset(y: barHeight + 6)
        }
        .frame(height: barHeight + labelHeight + 6)
      }
    }
  }

  @ViewBuilder
  private func segmentView(block: ScheduleBlock, totalWidth: CGFloat) -> some View {
    let startFraction = CGFloat(block.startMinutes) / (24 * 60)
    let endMinutes = block.endMinutes <= block.startMinutes ? block.endMinutes + 24 * 60 : block.endMinutes
    let endFraction = min(CGFloat(endMinutes) / (24 * 60), 1.0)
    let segWidth = (endFraction - startFraction) * totalWidth
    let xOffset = startFraction * totalWidth

    if block.mode != .off && segWidth > 0 {
      RoundedRectangle(cornerRadius: 4, style: .continuous)
        .fill(block.mode.segmentColor)
        .frame(width: segWidth, height: barHeight)
        .offset(x: xOffset)
    }
  }

  @ViewBuilder
  private func currentTimeIndicator(totalWidth: CGFloat) -> some View {
    let cal = Calendar.current
    let now = Date()
    let hour = cal.component(.hour, from: now)
    let minute = cal.component(.minute, from: now)
    let fraction = CGFloat(hour * 60 + minute) / (24 * 60)
    let xPos = fraction * totalWidth

    Rectangle()
      .fill(Color.vintageGrape)
      .frame(width: 2, height: barHeight + 8)
      .offset(x: xPos - 1, y: -4)
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    ScheduleTimelineCard(blocks: [
      ScheduleBlock(startHour: 7, endHour: 9, mode: .boss),
      ScheduleBlock(startHour: 9, endHour: 17, mode: .base),
      ScheduleBlock(startHour: 17, endHour: 21, mode: .base),
      ScheduleBlock(startHour: 21, endHour: 7, mode: .rest)
    ])
    .padding(20)
  }
}
