import SwiftUI

struct UnlockLimitView: View {
  @Binding var allowanceMinutes: Int

  private let presets: [Int] = [15, 30, 60, 120]

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Daily allowance")
          .font(LevelFont.bold(32))
          .foregroundStyle(Color.cream)
          .staged(0.05)
        Text("How long should your blocked apps last each day? Every minute you use drains the tank.")
          .font(.levelBody)
          .foregroundStyle(Color.cream.opacity(0.75))
          .lineSpacing(4)
          .staged(0.15)
      }

      VStack(spacing: 16) {
        Text(allowanceDisplay)
          .font(.levelDisplay)
          .foregroundStyle(Color.cream)
          .contentTransition(.numericText(value: Double(allowanceMinutes)))
          .animation(.spring(response: 0.3, dampingFraction: 0.7), value: allowanceMinutes)

        Text("per day on blocked apps")
          .font(LevelFont.bold(11))
          .tracking(0.5)
          .textCase(.uppercase)
          .foregroundStyle(Color.cream.opacity(0.6))

        HStack(spacing: 16) {
          Button {
            if allowanceMinutes > 5 { allowanceMinutes = max(5, allowanceMinutes - 5) }
          } label: {
            Image(systemName: "minus")
              .font(.system(size: 18, weight: .semibold))
              .foregroundStyle(Color.cream)
              .frame(width: 48, height: 48)
              .background(Circle().fill(Color.cream.opacity(0.15)))
          }
          .buttonStyle(.plain)

          Slider(value: Binding(
            get: { Double(allowanceMinutes) },
            set: { allowanceMinutes = Int($0) }
          ), in: 5...240, step: 5)
          .tint(Color.teaGreen)

          Button {
            if allowanceMinutes < 240 { allowanceMinutes = min(240, allowanceMinutes + 5) }
          } label: {
            Image(systemName: "plus")
              .font(.system(size: 18, weight: .semibold))
              .foregroundStyle(Color.cream)
              .frame(width: 48, height: 48)
              .background(Circle().fill(Color.cream.opacity(0.15)))
          }
          .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)

        HStack(spacing: 8) {
          ForEach(presets, id: \.self) { preset in
            Button {
              allowanceMinutes = preset
            } label: {
              Text(Self.format(minutes: preset))
                .font(LevelFont.bold(13))
                .foregroundStyle(allowanceMinutes == preset ? Color.vintageGrape : Color.cream)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                  Capsule()
                    .fill(allowanceMinutes == preset ? Color.cream : Color.cream.opacity(0.12))
                )
            }
            .buttonStyle(.plain)
          }
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

  private var allowanceDisplay: String {
    Self.format(minutes: allowanceMinutes)
  }

  private static func format(minutes: Int) -> String {
    if minutes >= 60 {
      let h = minutes / 60
      let m = minutes % 60
      return m == 0 ? "\(h)h" : "\(h)h \(m)m"
    }
    return "\(minutes)m"
  }
}
