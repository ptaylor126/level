import SwiftUI

struct BaselineView: View {
  @Binding var baselineHours: Double

  private let options: [(label: String, hours: Double)] = [
    ("2-3 hours", 2.5),
    ("3-4 hours", 3.5),
    ("4-5 hours", 4.5),
    ("5-6 hours", 5.5),
    ("6+ hours", 7.0)
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text("How long are you usually on your phone?")
          .font(LevelFont.bold(28))
          .foregroundStyle(Color.cream)
          .multilineTextAlignment(.leading)
          .staged(0.05)
        Text("Per day, roughly. We'll use this to show how much time you're saving.")
          .font(.levelBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .lineSpacing(4)
          .staged(0.15)
      }

      VStack(spacing: 10) {
        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
          Button {
            baselineHours = option.hours
          } label: {
            HStack {
              Text(option.label)
                .font(LevelFont.bold(17))
                .foregroundStyle(baselineHours == option.hours ? Color.vintageGrape : Color.cream)
              Spacer()
              if baselineHours == option.hours {
                Image(systemName: "checkmark")
                  .font(.system(size: 14, weight: .bold))
                  .foregroundStyle(Color.vintageGrape)
              }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
              RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(baselineHours == option.hours ? Color.teaGreen : Color.cream.opacity(0.08))
            )
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
          }
          .buttonStyle(.plain)
          .staged(0.25 + Double(index) * 0.05)
        }
      }
    }
  }
}
