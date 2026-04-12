import FamilyControls
import SwiftData
import SwiftUI

enum OnboardingStep: Int, CaseIterable {
  case welcome
  case appPicker
  case reasons
  case confirmation

  var canGoBack: Bool {
    self != .welcome
  }
}

struct OnboardingFlow: View {
  @Environment(\.modelContext) private var context
  @EnvironmentObject private var screenTime: ScreenTimeManager
  let profile: UserProfile

  @State private var step: OnboardingStep = .welcome
  @State private var draftReasons: [String] = ["", "", ""]
  @State private var isAppPickerPresented = false
  @State private var transitionEdge: Edge = .trailing

  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()
      GeometryReader { proxy in
        VStack(alignment: .leading, spacing: 0) {
          HStack {
            LevelWordmark()
            Spacer()
            if step.canGoBack {
              Button(action: goBack) {
                Image(systemName: "chevron.left")
                  .font(.system(size: 16, weight: .semibold))
                  .foregroundStyle(Color.cream.opacity(0.7))
                  .frame(width: 36, height: 36)
                  .background(
                    Circle().fill(Color.cream.opacity(0.1))
                  )
              }
              .buttonStyle(.plain)
              .transition(.opacity)
            }
          }
          .padding(.top, 4)
          .animation(.easeInOut(duration: 0.2), value: step.canGoBack)

          if step == .reasons {
            Color.clear.frame(height: max(0, proxy.size.height * 0.06))
          } else {
            Color.clear.frame(height: max(0, proxy.size.height * 0.24))
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

  @ViewBuilder
  private var content: some View {
    switch step {
    case .welcome:
      WelcomeView()
    case .appPicker:
      AppPickerView(onPickTapped: { isAppPickerPresented = true })
    case .reasons:
      ReasonsView(reasons: $draftReasons)
    case .confirmation:
      ConfirmationView()
    }
  }

  private var footer: some View {
    VStack(spacing: 16) {
      StepIndicator(current: step.rawValue, total: OnboardingStep.allCases.count)
      LevelButton(
        title: buttonTitle,
        style: .primaryOnDark,
        isEnabled: isButtonEnabled,
        action: handleButtonTap
      )
    }
  }

  private var buttonTitle: String {
    switch step {
    case .welcome: return "Get started"
    case .appPicker: return "Next"
    case .reasons: return "Next"
    case .confirmation: return "Got it"
    }
  }

  private var isButtonEnabled: Bool {
    switch step {
    case .welcome, .confirmation:
      return true
    case .appPicker:
      return screenTime.selectedItemCount > 0
    case .reasons:
      return draftReasons.contains { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
  }

  private func goBack() {
    guard let idx = OnboardingStep.allCases.firstIndex(of: step), idx > 0 else { return }
    transitionEdge = .leading
    step = OnboardingStep.allCases[idx - 1]
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      transitionEdge = .trailing
    }
  }

  private func handleButtonTap() {
    transitionEdge = .trailing
    switch step {
    case .welcome:
      Task {
        let granted = await screenTime.requestAuthorization()
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
      step = .confirmation
    case .confirmation:
      profile.onboardingComplete = true
      try? context.save()
      screenTime.persistSelection()
      screenTime.syncReasonsToDefaults(profile.reasons)
      screenTime.syncSettingsToDefaults(delay: 10, increment: 10, unlockLimit: 10)
      screenTime.startMonitoring()
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
