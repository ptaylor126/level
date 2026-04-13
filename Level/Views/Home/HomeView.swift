import SwiftData
import SwiftUI

struct HomeView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.scenePhase) private var scenePhase
  @Environment(\.colorScheme) private var colorScheme
  @StateObject private var viewModel = HomeViewModel()
  @State private var appeared = false
  @State private var showSettings = false
  @State private var showTriggerPrompt = false

  private var backgroundColor: Color {
    colorScheme == .dark ? .vintageGrape : .cream
  }

  private var primaryTextColor: Color {
    colorScheme == .dark ? .cream : .vintageGrape
  }

  private var secondaryTextColor: Color {
    colorScheme == .dark ? .mutedGrape : .mutedGrape
  }

  private var dateString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d"
    return formatter.string(from: Date())
  }

  var body: some View {
    ZStack {
      backgroundColor.ignoresSafeArea()

      ScrollView(showsIndicators: false) {
        VStack(spacing: 12) {
          headerRow

          ScreenTimeCard(
            todaySeconds: viewModel.todayScreenTime,
            yesterdaySeconds: viewModel.yesterdayScreenTime
          )

          halfWidthRow

          WeeklyChartCard(days: viewModel.weeklyDays)

          AppLimitsCard(limits: AppLimitsCard.mockLimits)

          ReasonCard(reasons: viewModel.reasons, displayIndex: 0)

          Spacer(minLength: 32)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.2), value: appeared)
      }
    }
    .onAppear {
      appeared = true
      viewModel.refresh(context: context)
      checkTriggerPrompt()
    }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        viewModel.refresh(context: context)
        checkTriggerPrompt()
      }
    }
    .overlay(alignment: .bottom) {
      if showTriggerPrompt {
        TriggerPromptView(
          onSelect: { trigger in
            let tracker = TriggerTracker(context: context)
            tracker.logTrigger(trigger)
            SharedStore.defaults.set(0, forKey: "todayDeclinedCount")
            SharedStore.defaults.set(true, forKey: "triggerPromptShownThisSession")
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
              showTriggerPrompt = false
            }
          },
          onDismiss: {
            SharedStore.defaults.set(true, forKey: "triggerPromptShownThisSession")
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
              showTriggerPrompt = false
            }
          }
        )
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
      }
    }
    .sheet(isPresented: $showSettings) {
      SettingsView()
    }
    .onChange(of: showSettings) { _, showing in
      if !showing {
        viewModel.refresh(context: context)
      }
    }
  }

  private var headerRow: some View {
    HStack(alignment: .bottom) {
      VStack(alignment: .leading, spacing: 2) {
        LevelWordmark(size: 28, color: primaryTextColor)
        Text(dateString)
          .font(.levelCaption)
          .foregroundStyle(secondaryTextColor)
      }
      Spacer()
      Button { showSettings = true } label: {
        LevelIconView(icon: .gear, size: 28, color: secondaryTextColor)
          .frame(width: 44, height: 44)
          .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
    }
    .padding(.vertical, 8)
  }

  private func checkTriggerPrompt() {
    let declined = SharedStore.defaults.integer(forKey: "todayDeclinedCount")
    let alreadyShown = SharedStore.defaults.bool(forKey: "triggerPromptShownThisSession")
    if declined >= 3 && !alreadyShown {
      withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(0.5)) {
        showTriggerPrompt = true
      }
    }
  }

  private var halfWidthRow: some View {
    HStack(spacing: 12) {
      MomentumCard(score: viewModel.momentumScore, streak: viewModel.streak)
        .frame(maxWidth: .infinity)
      UnlocksCard(remaining: viewModel.unlocksRemaining, total: viewModel.unlocksTotal)
        .frame(maxWidth: .infinity)
    }
  }
}

#Preview {
  HomeView()
    .modelContainer(DataStore.shared.container)
}
