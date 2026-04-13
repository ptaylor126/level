import SwiftUI

struct UnlockLimitView: View {
  @Binding var unlockLimit: Int

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Daily opens")
          .font(LevelFont.bold(32))
          .foregroundStyle(Color.cream)
          .staged(0.05)
        Text("How many times can you open these apps per day? You can change this anytime.")
          .font(.levelBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .lineSpacing(4)
          .staged(0.15)
      }

      VStack(spacing: 16) {
        Text("\(unlockLimit)")
          .font(.levelDisplay)
          .foregroundStyle(Color.cream)
          .contentTransition(.numericText(value: Double(unlockLimit)))
          .animation(.spring(response: 0.3, dampingFraction: 0.7), value: unlockLimit)

        Text(unlockLimit == 1 ? "open per day" : "opens per day")
          .font(LevelFont.bold(11))
          .tracking(0.5)
          .textCase(.uppercase)
          .foregroundStyle(Color.cream.opacity(0.6))

        HStack(spacing: 20) {
          Button {
            if unlockLimit > 1 { unlockLimit -= 1 }
          } label: {
            Image(systemName: "minus")
              .font(.system(size: 18, weight: .semibold))
              .foregroundStyle(Color.cream)
              .frame(width: 48, height: 48)
              .background(Circle().fill(Color.cream.opacity(0.15)))
          }
          .buttonStyle(.plain)

          Slider(value: Binding(
            get: { Double(unlockLimit) },
            set: { unlockLimit = Int($0) }
          ), in: 1...50, step: 1)
          .tint(Color.teaGreen)

          Button {
            if unlockLimit < 50 { unlockLimit += 1 }
          } label: {
            Image(systemName: "plus")
              .font(.system(size: 18, weight: .semibold))
              .foregroundStyle(Color.cream)
              .frame(width: 48, height: 48)
              .background(Circle().fill(Color.cream.opacity(0.15)))
          }
          .buttonStyle(.plain)
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 24)
      .background(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(Color.cream.opacity(0.08))
      )
      .staged(0.25)
    }
  }
}
