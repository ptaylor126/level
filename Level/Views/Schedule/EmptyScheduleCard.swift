import SwiftUI

struct EmptyScheduleCard: View {
  var onUseSuggested: () -> Void
  var onBuildOwn: () -> Void

  private let suggestedBlocks: [(String, String)] = [
    ("7:00 - 9:00 AM", "Boss Level"),
    ("9:00 AM - 5:00 PM", "Base Level"),
    ("5:00 - 9:00 PM", "Base Level"),
    ("9:00 PM - 7:00 AM", "Rest Level")
  ]

  var body: some View {
    LevelCard(background: .cream, showBorder: true) {
      VStack(alignment: .leading, spacing: 16) {
        VStack(alignment: .leading, spacing: 6) {
          Text("No schedule yet")
            .font(.levelH2)
            .foregroundStyle(Color.vintageGrape)

          Text("Set up your daily schedule to automatically adjust your restrictions throughout the day.")
            .font(.levelBody)
            .foregroundStyle(Color.mutedGrape)
            .fixedSize(horizontal: false, vertical: true)
            .lineSpacing(4)
        }

        // Suggested schedule preview
        VStack(spacing: 0) {
          ForEach(suggestedBlocks.indices, id: \.self) { index in
            let (time, mode) = suggestedBlocks[index]
            HStack(spacing: 10) {
              Circle()
                .fill(dotColor(for: mode))
                .frame(width: 8, height: 8)
              Text(time)
                .font(LevelFont.bold(13))
                .foregroundStyle(Color.vintageGrape)
              Spacer()
              Text(mode)
                .font(.levelCaption)
                .foregroundStyle(Color.mutedGrape)
            }
            .padding(.vertical, 8)

            if index < suggestedBlocks.count - 1 {
              Divider()
                .background(Color.warmGrey)
            }
          }
        }
        .padding(12)
        .background(Color.warmGrey.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

        // Buttons
        VStack(spacing: 10) {
          LevelButton(title: "Use this schedule", style: .primaryOnLight) {
            onUseSuggested()
          }

          Button {
            onBuildOwn()
          } label: {
            Text("Build your own")
              .font(LevelFont.bold(15))
              .foregroundStyle(Color.mutedGrape)
              .frame(maxWidth: .infinity, minHeight: 44)
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  private func dotColor(for modeName: String) -> Color {
    switch modeName {
    case "Boss Level": return .teaGreen
    case "Rest Level": return .pastelPink
    default: return .warmGrey
    }
  }
}

#Preview {
  ZStack {
    Color.vintageGrape.ignoresSafeArea()
    EmptyScheduleCard(
      onUseSuggested: {},
      onBuildOwn: {}
    )
    .padding(20)
  }
}
