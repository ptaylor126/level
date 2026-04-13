import SwiftUI

struct HowItWorksView: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text("How it works.")
          .font(LevelFont.bold(28))
          .foregroundStyle(Color.cream)
          .staged(0.05)
        Text("Two ways to open a blocked app.")
          .font(.levelBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .lineSpacing(4)
          .staged(0.15)
      }

      VStack(spacing: 14) {
        StepRow(
          number: "1",
          title: "Try to open the app",
          detail: "You'll see a reminder. Open Level to start your timer."
        )
        .staged(0.25)

        StepRow(
          number: "2",
          title: "Or open Level first",
          detail: "Tap an app from your list to unlock whenever you want."
        )
        .staged(0.35)

        StepRow(
          number: "3",
          title: "Wait through the timer",
          detail: "Then decide if you really need it."
        )
        .staged(0.45)
      }
    }
  }
}

private struct StepRow: View {
  let number: String
  let title: String
  let detail: String

  var body: some View {
    HStack(alignment: .top, spacing: 14) {
      Text(number)
        .font(LevelFont.bold(18))
        .foregroundStyle(Color.vintageGrape)
        .frame(width: 36, height: 36)
        .background(Circle().fill(Color.teaGreen))

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(LevelFont.bold(15))
          .foregroundStyle(Color.cream)
        Text(detail)
          .font(.levelCaption)
          .foregroundStyle(Color.cream.opacity(0.7))
          .lineSpacing(2)
      }
      Spacer()
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(Color.cream.opacity(0.08))
    )
  }
}
