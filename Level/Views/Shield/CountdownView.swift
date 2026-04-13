import SwiftUI

struct CountdownView: View {
  let reason: String
  let totalSeconds: Int
  let onOpenAnyway: () -> Void
  let onDismiss: () -> Void

  @State private var remaining: Int
  @State private var timerActive = true
  @State private var showOpenButton = false

  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  init(reason: String, totalSeconds: Int, onOpenAnyway: @escaping () -> Void, onDismiss: @escaping () -> Void) {
    self.reason = reason
    self.totalSeconds = totalSeconds
    self.onOpenAnyway = onOpenAnyway
    self.onDismiss = onDismiss
    self._remaining = State(initialValue: totalSeconds)
  }

  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()

      VStack(spacing: 0) {
        Spacer()

        VStack(spacing: 32) {
          Text(reason)
            .font(LevelFont.regular(20))
            .foregroundStyle(Color.cream)
            .multilineTextAlignment(.center)
            .lineSpacing(6)
            .padding(.horizontal, 32)

          if remaining > 0 {
            Text(formattedTime)
              .font(LevelFont.extraBold(48))
              .foregroundStyle(Color.teaGreen)
              .contentTransition(.numericText(value: Double(remaining)))
              .animation(.easeInOut(duration: 0.3), value: remaining)
              .monospacedDigit()
          }

          if showOpenButton {
            LevelButton(
              title: "Open anyway",
              style: .primaryOnDark,
              action: onOpenAnyway
            )
            .padding(.horizontal, 40)
            .transition(.scale.combined(with: .opacity))
          }
        }

        Spacer()

        LevelButton(
          title: "Not now",
          style: .ghostOnDark,
          action: onDismiss
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
      }
    }
    .preferredColorScheme(.dark)
    .onReceive(timer) { _ in
      guard timerActive, remaining > 0 else { return }
      remaining -= 1
      if remaining <= 0 {
        timerActive = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
          showOpenButton = true
        }
      }
    }
  }

  private var formattedTime: String {
    if remaining >= 60 {
      let m = remaining / 60
      let s = remaining % 60
      return String(format: "%d:%02d", m, s)
    }
    return "\(remaining)"
  }
}

#Preview {
  CountdownView(
    reason: "You said you wanted to read more books.",
    totalSeconds: 10,
    onOpenAnyway: {},
    onDismiss: {}
  )
}
