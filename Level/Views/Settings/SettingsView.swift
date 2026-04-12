import FamilyControls
import SwiftData
import SwiftUI

struct SettingsView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var screenTime: ScreenTimeManager
  @StateObject private var viewModel = SettingsViewModel()
  @State private var isAppPickerPresented = false

  var body: some View {
    NavigationStack {
      ZStack {
        Color.vintageGrape.ignoresSafeArea()
        ScrollView(showsIndicators: false) {
          VStack(spacing: 24) {
            manageAppsSection
            reasonsSection
            timingSection
            notificationsSection
            triggerPatternsSection
            appearanceSection
            aboutSection
          }
          .padding(.horizontal, 20)
          .padding(.top, 8)
          .padding(.bottom, 32)
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") {
            viewModel.save(context: context)
            dismiss()
          }
          .foregroundStyle(Color.teaGreen)
        }
      }
      .toolbarColorScheme(.dark, for: .navigationBar)
      .onAppear { viewModel.load(context: context) }
      .familyActivityPicker(isPresented: $isAppPickerPresented, selection: $screenTime.selection)
      .onChange(of: screenTime.selection) { _, _ in
        screenTime.persistSelection()
        screenTime.applyShields()
      }
    }
    .preferredColorScheme(.dark)
  }

  // MARK: - Manage Apps

  private var manageAppsSection: some View {
    settingsSection("MANAGE APPS") {
      VStack(alignment: .leading, spacing: 12) {
        Text("\(screenTime.selectedItemCount) apps and categories tracked")
          .font(.levelBody)
          .foregroundStyle(Color.cream)
        LevelButton(
          title: "Change tracked apps",
          style: .ghostOnDark,
          action: { isAppPickerPresented = true }
        )
      }
    }
  }

  // MARK: - Reasons

  private var reasonsSection: some View {
    settingsSection("MY REASONS") {
      VStack(spacing: 10) {
        ForEach(viewModel.reasons.indices, id: \.self) { index in
          HStack(spacing: 8) {
            TextField("Reason", text: $viewModel.reasons[index])
              .font(.levelBody)
              .foregroundStyle(Color.cream)
              .padding(.horizontal, 14)
              .padding(.vertical, 12)
              .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                  .fill(Color.cream.opacity(0.08))
              )
            if viewModel.reasons.count > 1 {
              Button { viewModel.removeReason(at: index) } label: {
                Image(systemName: "xmark.circle.fill")
                  .foregroundStyle(Color.cream.opacity(0.4))
              }
              .buttonStyle(.plain)
            }
          }
        }
        if viewModel.reasons.count < 10 {
          Button(action: viewModel.addReason) {
            HStack(spacing: 6) {
              Image(systemName: "plus")
              Text("Add reason")
            }
            .font(LevelFont.bold(14))
            .foregroundStyle(Color.cream.opacity(0.7))
            .frame(maxWidth: .infinity, minHeight: 40)
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  // MARK: - Timing

  private var timingSection: some View {
    settingsSection("TIMING") {
      VStack(spacing: 16) {
        settingsRow("Delay", value: "\(viewModel.defaultDelay)s") {
          Stepper("", value: $viewModel.defaultDelay, in: 5...60, step: 5)
            .labelsHidden()
        }
        settingsRow("Increment", value: "+\(viewModel.delayIncrement)s") {
          Stepper("", value: $viewModel.delayIncrement, in: 5...30, step: 5)
            .labelsHidden()
        }
        settingsRow("Daily opens", value: "\(viewModel.unlockLimit)") {
          Stepper("", value: $viewModel.unlockLimit, in: 5...50, step: 5)
            .labelsHidden()
        }
      }
    }
  }

  // MARK: - Notifications

  private var notificationsSection: some View {
    settingsSection("NOTIFICATIONS") {
      VStack(spacing: 16) {
        settingsToggle("Weekly recap", subtitle: "Sunday 7pm", isOn: $viewModel.notifyWeeklyRecap)
        settingsToggle("Morning summary", subtitle: "9am daily", isOn: $viewModel.notifyMorningSummary)
        settingsToggle("Streak at risk", subtitle: "8pm if trending high", isOn: $viewModel.notifyStreakAtRisk)
      }
    }
  }

  // MARK: - Trigger Patterns

  private var triggerPatternsSection: some View {
    settingsSection("YOUR PATTERNS") {
      let tracker = TriggerTracker(context: context)
      let counts = tracker.allTimeCounts()
      if counts.isEmpty {
        Text("Not enough data yet. Keep using Level.")
          .font(.levelCaption)
          .foregroundStyle(Color.cream.opacity(0.5))
      } else {
        VStack(alignment: .leading, spacing: 10) {
          if let summary = tracker.weekSummary() {
            Text("This week you mostly reached for your phone when you were \(summary.trigger) (\(summary.percentage)%)")
              .font(.levelBody)
              .foregroundStyle(Color.cream)
              .lineSpacing(4)
          }
          ForEach(counts, id: \.trigger) { item in
            HStack {
              Text(item.trigger.capitalized)
                .font(.levelBody)
                .foregroundStyle(Color.cream)
              Spacer()
              Text("\(item.count)")
                .font(LevelFont.bold(15))
                .foregroundStyle(Color.cream.opacity(0.6))
            }
          }
        }
      }
    }
  }

  // MARK: - Appearance

  private var appearanceSection: some View {
    settingsSection("APPEARANCE") {
      HStack(spacing: 12) {
        ForEach(["system", "light", "dark"], id: \.self) { mode in
          Button {
            viewModel.appearanceMode = mode
          } label: {
            Text(mode.capitalized)
              .font(LevelFont.medium(14))
              .foregroundStyle(viewModel.appearanceMode == mode ? Color.vintageGrape : Color.cream)
              .frame(maxWidth: .infinity, minHeight: 38)
              .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                  .fill(viewModel.appearanceMode == mode ? Color.cream : Color.cream.opacity(0.08))
              )
          }
          .buttonStyle(.plain)
        }
      }
    }
  }

  // MARK: - About

  private var aboutSection: some View {
    settingsSection("ABOUT") {
      VStack(alignment: .leading, spacing: 8) {
        Text("Your data never leaves your phone.")
          .font(.levelBody)
          .foregroundStyle(Color.cream)
        Text("Level v1.0")
          .font(.levelCaption)
          .foregroundStyle(Color.cream.opacity(0.5))
      }
    }
  }

  // MARK: - Helpers

  private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.levelLabel)
        .tracking(0.5)
        .foregroundStyle(Color.mutedGrape)
      content()
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
          RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.cream.opacity(0.06))
        )
    }
  }

  private func settingsRow<Trailing: View>(_ label: String, value: String, @ViewBuilder trailing: () -> Trailing) -> some View {
    HStack {
      Text(label)
        .font(.levelBody)
        .foregroundStyle(Color.cream)
      Text(value)
        .font(LevelFont.bold(15))
        .foregroundStyle(Color.teaGreen)
      Spacer()
      trailing()
    }
  }

  private func settingsToggle(_ label: String, subtitle: String, isOn: Binding<Bool>) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(label)
          .font(.levelBody)
          .foregroundStyle(Color.cream)
        Text(subtitle)
          .font(.levelCaption)
          .foregroundStyle(Color.cream.opacity(0.5))
      }
      Spacer()
      Toggle("", isOn: isOn)
        .labelsHidden()
        .tint(Color.teaGreen)
    }
  }
}
