import FamilyControls
import SwiftData
import SwiftUI

enum OnboardingStep: Int, CaseIterable {
  case welcome
  case appPicker
  case reasons
  case unlockLimit
  case sessionLength
  case momentum
  case summary
  case confirmation

  var canGoBack: Bool {
    self != .welcome
  }

  var isSkippable: Bool {
    switch self {
    case .reasons, .unlockLimit, .sessionLength: return true
    default: return false
    }
  }
}

struct OnboardingFlow: View {
  @Environment(\.modelContext) private var context
  @EnvironmentObject private var screenTime: ScreenTimeManager
  let profile: UserProfile

  @State private var step: OnboardingStep = .welcome
  @State private var draftReasons: [String] = ["", "", ""]
  @State private var unlockLimit: Int = 10
  @State private var sessionMinutes: Int = 5
  @State private var isAppPickerPresented = false
  @State private var transitionEdge: Edge = .trailing
  @State private var isAuthLoading = false

  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()
      GeometryReader { proxy in
        VStack(alignment: .leading, spacing: 0) {
          header
            .padding(.top, 4)
            .animation(.easeInOut(duration: 0.2), value: step.canGoBack)

          switch step {
          case .reasons, .summary, .momentum, .unlockLimit, .sessionLength:
            Color.clear.frame(height: max(0, proxy.size.height * 0.06))
          default:
            Color.clear.frame(height: max(0, proxy.size.height * 0.18))
          }

          ZStack {
            content
              .id(step)
              .transition(
                .asymmetric(
                  insertion: .move(edge: transitionEdge).combined(with: .opacity),
                  removal: .move(edge: transitionEdge == .trailing ? .leading : .trailing).combined(with: .opacity)
                )
              )
          }
          .animation(.spring(response: 0.55, dampingFraction: 0.88), value: step)
          .frame(maxWidth: .infinity, alignment: .topLeading)

          Spacer(minLength: 0)

          footer
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 24)
      }
    }
    .preferredColorScheme(.dark)
    .familyActivityPicker(isPresented: $isAppPickerPresented, selection: $screenTime.selection)
    .onChange(of: screenTime.selection) { _, _ in
      screenTime.persistSelection()
    }
  }

  private var header: some View {
    HStack {
      LevelWordmark()
      Spacer()
      if step.canGoBack {
        Button(action: goBack) {
          Image(systemName: "chevron.left")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(Color.cream.opacity(0.7))
            .frame(width: 36, height: 36)
            .background(Circle().fill(Color.cream.opacity(0.1)))
        }
        .buttonStyle(.plain)
        .transition(.opacity)
      }
    }
  }

  @ViewBuilder
  private var content: some View {
    switch step {
    case .welcome:
      WelcomeView()
    case .appPicker:
      AppPickerView(onPickTapped: { isAppPickerPresented = true })
    case .reasons:
      ReasonsView(reasons: $draftReasons)
    case .unlockLimit:
      UnlockLimitView(unlockLimit: $unlockLimit)
    case .sessionLength:
      SessionLengthView(sessionMinutes: $sessionMinutes)
    case .momentum:
      MomentumIntroView()
    case .summary:
      SummaryView(
        reasons: draftReasons,
        onEditApps: { goToStep(.appPicker) },
        onEditReasons: { goToStep(.reasons) }
      )
    case .confirmation:
      ConfirmationView()
    }
  }

  private var footer: some View {
    VStack(spacing: 12) {
      if step.isSkippable {
        Button(action: { advance() }) {
          Text("Skip")
            .font(LevelFont.medium(14))
            .foregroundStyle(Color.cream.opacity(0.5))
        }
        .buttonStyle(.plain)
      }
      StepIndicator(current: step.rawValue, total: OnboardingStep.allCases.count)
      ZStack {
        LevelButton(
          title: isAuthLoading ? "" : buttonTitle,
          style: .primaryOnDark,
          isEnabled: isButtonEnabled && !isAuthLoading,
          action: handleButtonTap
        )
        if isAuthLoading {
          ProgressView()
            .tint(Color.vintageGrape)
        }
      }
    }
  }

  private var buttonTitle: String {
    switch step {
    case .welcome: return "Get started"
    case .appPicker: return "Next"
    case .reasons: return "Next"
    case .unlockLimit: return "Next"
    case .sessionLength: return "Next"
    case .momentum: return "Next"
    case .summary: return "Looks good"
    case .confirmation: return "Got it"
    }
  }

  private var isButtonEnabled: Bool {
    switch step {
    case .welcome, .confirmation, .summary, .momentum, .unlockLimit, .sessionLength:
      return true
    case .appPicker:
      return screenTime.selectedItemCount > 0
    case .reasons:
      return true
    }
  }

  private func goBack() {
    guard let idx = OnboardingStep.allCases.firstIndex(of: step), idx > 0 else { return }
    goToStep(OnboardingStep.allCases[idx - 1])
  }

  private func goToStep(_ target: OnboardingStep) {
    transitionEdge = .leading
    step = target
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      transitionEdge = .trailing
    }
  }

  private func advance() {
    guard let idx = OnboardingStep.allCases.firstIndex(of: step),
          idx < OnboardingStep.allCases.count - 1 else { return }
    transitionEdge = .trailing
    step = OnboardingStep.allCases[idx + 1]
  }

  private func handleButtonTap() {
    transitionEdge = .trailing
    switch step {
    case .welcome:
      isAuthLoading = true
      Task {
        let granted = await screenTime.requestAuthorization()
        isAuthLoading = false
        if granted {
          step = .appPicker
        }
      }
    case .appPicker:
      step = .reasons
    case .reasons:
      profile.reasons = draftReasons
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
      try? context.save()
      step = .unlockLimit
    case .unlockLimit:
      step = .sessionLength
    case .sessionLength:
      step = .momentum
    case .momentum:
      step = .summary
    case .summary:
      step = .confirmation
    case .confirmation:
      profile.onboardingComplete = true
      try? context.save()
      screenTime.persistSelection()
      screenTime.syncReasonsToDefaults(profile.reasons)
      screenTime.syncSettingsToDefaults(
        delay: 10,
        increment: 10,
        unlockLimit: unlockLimit
      )
      SharedStore.defaults.set(sessionMinutes * 60, forKey: "sessionLengthSeconds")
      screenTime.startMonitoring()
      Task { let _ = await NotificationManager.shared.requestPermission() }
    }
  }
}

private struct StepIndicator: View {
  let current: Int
  let total: Int

  var body: some View {
    HStack(spacing: 6) {
      ForEach(0..<total, id: \.self) { index in
        Capsule()
          .fill(index <= current ? Color.cream : Color.cream.opacity(0.25))
          .frame(width: index == current ? 24 : 6, height: 6)
      }
    }
    .animation(.spring(response: 0.45, dampingFraction: 0.75), value: current)
  }
}
