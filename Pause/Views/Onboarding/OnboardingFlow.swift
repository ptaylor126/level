import FamilyControls
import SwiftData
import SwiftUI

enum OnboardingStep: Int, CaseIterable {
  case welcome
  case appPicker
  case reasons
  case confirmation
}

struct OnboardingFlow: View {
  @Environment(\.modelContext) private var context
  @EnvironmentObject private var screenTime: ScreenTimeManager
  let profile: UserProfile

  @State private var step: OnboardingStep = .welcome
  @State private var draftReasons: [String] = ["", "", ""]

  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()
      VStack {
        StepIndicator(current: step.rawValue, total: OnboardingStep.allCases.count)
          .padding(.top, 16)
        Spacer(minLength: 0)
        content
          .transition(.opacity)
          .animation(.easeInOut(duration: 0.25), value: step)
        Spacer(minLength: 0)
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 24)
    }
    .preferredColorScheme(.dark)
  }

  @ViewBuilder
  private var content: some View {
    switch step {
    case .welcome:
      WelcomeView(onContinue: advanceFromWelcome)
    case .appPicker:
      AppPickerView(onContinue: { step = .reasons })
    case .reasons:
      ReasonsView(reasons: $draftReasons, onContinue: advanceFromReasons)
    case .confirmation:
      ConfirmationView(onFinish: finish)
    }
  }

  private func advanceFromWelcome() {
    Task {
      let granted = await screenTime.requestAuthorization()
      if granted {
        step = .appPicker
      }
    }
  }

  private func advanceFromReasons() {
    profile.reasons = draftReasons.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
    try? context.save()
    step = .confirmation
  }

  private func finish() {
    profile.onboardingComplete = true
    try? context.save()
    screenTime.persistSelection()
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
          .frame(width: index == current ? 22 : 6, height: 6)
          .animation(.easeInOut(duration: 0.25), value: current)
      }
    }
  }
}
