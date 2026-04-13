import SwiftUI

struct CountdownView: View {
  @EnvironmentObject private var screenTime: ScreenTimeManager

  let onDismiss: () -> Void

  @State private var remaining: Int = 0
  @State private var showOpenButton = false
  @State private var timerActive = true
  @State private var appeared = false

  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  private var reason: String {
    screenTime.currentReason()
  }

  private var totalSeconds: Int {
    screenTime.pendingCountdownSeconds()
  }

  private var attemptNumber: Int {
    SharedStore.defaults.integer(forKey: "todayOpenAttempts")
  }

  private var isExhausted: Bool {
    let count = SharedStore.defaults.integer(forKey: "todayUnlockCount")
    let limit = SharedStore.defaults.integer(forKey: "defaultUnlockLimit")
    return count >= (limit > 0 ? limit : 10)
  }

  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()

      if isExhausted {
        exhaustedContent
      } else {
        timerContent
      }
    }
    .preferredColorScheme(.dark)
    .onAppear {
      remaining = totalSeconds
      withAnimation(.easeOut(duration: 0.3)) {
        appeared = true
      }
    }
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

  private var timerContent: some View {
    VStack(spacing: 0) {
      HStack {
        LevelWordmark(size: 28, color: .cream)
        Spacer()
      }
      .padding(.top, 8)
      .opacity(appeared ? 1 : 0)

      Spacer()

      VStack(spacing: 24) {
        Text(reason)
          .font(LevelFont.regular(20))
          .foregroundStyle(Color.cream)
          .multilineTextAlignment(.center)
          .lineSpacing(6)
          .padding(.horizontal, 20)
          .opacity(appeared ? 1 : 0)
          .offset(y: appeared ? 0 : 10)
          .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)

        Text("Attempt \(attemptNumber) today")
          .font(.levelCaption)
          .foregroundStyle(Color.mutedGrape)
          .opacity(appeared ? 1 : 0)
          .animation(.easeOut(duration: 0.3).delay(0.2), value: appeared)

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
            action: handleOpenAnyway
          )
          .padding(.horizontal, 20)
          .transition(.scale.combined(with: .opacity))
        }
      }

      Spacer()

      LevelButton(
        title: "Not now",
        style: .ghostOnDark,
        action: handleNotNow
      )
      .padding(.bottom, 40)
      .opacity(appeared ? 1 : 0)
      .animation(.easeOut(duration: 0.3).delay(0.3), value: appeared)
    }
    .padding(.horizontal, 20)
  }

  private var exhaustedContent: some View {
    VStack(spacing: 0) {
      HStack {
        LevelWordmark(size: 28, color: .cream)
        Spacer()
      }
      .padding(.top, 8)

      Spacer()

      VStack(spacing: 24) {
        Text(reason)
          .font(LevelFont.regular(20))
          .foregroundStyle(Color.cream)
          .multilineTextAlignment(.center)
          .lineSpacing(6)
          .padding(.horizontal, 20)
          .staged(0.1)

        Text("You've used all your opens today.\nSee you tomorrow.")
          .font(.levelBody)
          .foregroundStyle(Color.cream.opacity(0.7))
          .multilineTextAlignment(.center)
          .lineSpacing(4)
          .staged(0.2)
      }

      Spacer()

      LevelButton(
        title: "Got it",
        style: .primaryOnDark,
        action: onDismiss
      )
      .padding(.bottom, 40)
      .staged(0.3)
    }
    .padding(.horizontal, 20)
  }

  private func handleOpenAnyway() {
    screenTime.startSession()
    screenTime.clearPendingCountdown()
    onDismiss()
  }

  private func handleNotNow() {
    let declined = SharedStore.defaults.integer(forKey: "todayDeclinedCount")
    SharedStore.defaults.set(declined + 1, forKey: "todayDeclinedCount")
    screenTime.clearPendingCountdown()
    onDismiss()
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
