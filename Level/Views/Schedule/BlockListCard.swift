import SwiftUI

struct BlockListCard: View {
  let blocks: [ScheduleBlock]
  var onEdit: (ScheduleBlock) -> Void
  var onDelete: (ScheduleBlock) -> Void

  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 12) {
        Text("TIME BLOCKS")
          .font(.levelLabel)
          .tracking(0.5)
          .foregroundStyle(Color.mutedGrape)

        VStack(spacing: 0) {
          ForEach(blocks.indices, id: \.self) { index in
            let block = blocks[index]

            Button {
              onEdit(block)
            } label: {
              HStack(spacing: 12) {
                // Mode color dot
                Circle()
                  .fill(block.mode.segmentColor == .clear ? Color.warmGrey : block.mode.segmentColor)
                  .frame(width: 10, height: 10)
                  .overlay(
                    Circle()
                      .strokeBorder(Color.warmGrey, lineWidth: 0.5)
                  )

                // Time range
                Text(block.timeRangeLabel)
                  .font(LevelFont.bold(14))
                  .foregroundStyle(Color.vintageGrape)

                Spacer()

                // Mode name
                Text(block.mode.displayName)
                  .font(.levelCaption)
                  .foregroundStyle(Color.mutedGrape)

                // Delete
                Button {
                  onDelete(block)
                } label: {
                  Image(systemName: "minus.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.warmGrey)
                }
                .buttonStyle(.plain)
              }
              .padding(.vertical, 12)
              .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if index < blocks.count - 1 {
              Divider()
                .background(Color.warmGrey)
            }
          }
        }
      }
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    BlockListCard(
      blocks: [
        ScheduleBlock(startHour: 7, endHour: 9, mode: .boss),
        ScheduleBlock(startHour: 9, endHour: 17, mode: .base),
        ScheduleBlock(startHour: 21, endHour: 7, mode: .rest)
      ],
      onEdit: { _ in },
      onDelete: { _ in }
    )
    .padding(20)
  }
}
