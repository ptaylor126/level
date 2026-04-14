import SwiftData
import SwiftUI

struct HomeView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.scenePhase) private var scenePhase
  @StateObject private var viewModel = HomeViewModel()
  @State private var appeared = false
  @State private var showTriggerPrompt = false
  @State private var showPathBCountdown = false

  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()

      ScrollView(showsIndicators: false) {
        VStack(spacing: 24) {
          topBar

          progressRing

          weekDots

          timeSavedCard

          ManagedAppsCard(onTapApp: {
            SharedStore.defaults.set(Date(), forKey: "pendingUnlockTimestamp")
            showPathBCountdown = true
          })

          reasonCard
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 32)
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
    .fullScreenCover(isPresented: $showPathBCountdown) {
      CountdownView(path: .pathB, onDismiss: {
        showPathBCountdown = false
      })
    }
  }

  // MARK: - Top Bar

  private var topBar: some View {
    HStack(alignment: .center) {
      LevelWordmark(size: 28, color: .cream)
      Spacer()
      HStack(spacing: 8) {
        streakPill
        xpPill
      }
    }
    .padding(.vertical, 8)
  }

  private var streakPill: some View {
    HStack(spacing: 4) {
      LevelIconView(icon: .flame, size: 14, color: .vintageGrape)
      Text("\(viewModel.streak)")
        .font(LevelFont.bold(13))
        .foregroundStyle(Color.vintageGrape)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background(Color.cream)
    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
  }

  private var xpPill: some View {
    HStack(spacing: 4) {
      Image(systemName: "diamond.fill")
        .font(.system(size: 11, weight: .bold))
        .foregroundStyle(Color.pastelPink)
      Text("\(viewModel.xpPoints)")
        .font(LevelFont.bold(13))
        .foregroundStyle(Color.vintageGrape)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 5)
    .background(Color.cream)
    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
  }

  // MARK: - Progress Ring

  private var progressRing: some View {
    VStack(spacing: 16) {
      Text("\(viewModel.momentumScore)")
        .font(LevelFont.extraBold(56))
        .foregroundStyle(Color.cream)
        .contentTransition(.numericText(value: Double(viewModel.momentumScore)))
        .animation(.easeInOut(duration: 0.4), value: viewModel.momentumScore)

      SpiritLevelView(score: viewModel.momentumScore, recentTrigger: viewModel.recentTrigger)

      Text("MOMENTUM")
        .font(.levelLabel)
        .tracking(1)
        .foregroundStyle(Color.mutedGrape)
    }
    .padding(.vertical, 8)
  }

  // MARK: - Week Dots

  private var weekDots: some View {
    HStack(spacing: 0) {
      ForEach(viewModel.weeklyDays.indices, id: \.self) { index in
        let day = viewModel.weeklyDays[index]
        VStack(spacing: 6) {
          ZStack {
            Circle()
              .fill(day.goalMet ? Color.teaGreen : Color.cream.opacity(0.15))
              .frame(width: 28, height: 28)
            if day.isToday {
              Circle()
                .strokeBorder(Color.cream, lineWidth: 2)
                .frame(width: 28, height: 28)
            }
          }
          Text(day.label)
            .font(.levelLabel)
            .foregroundStyle(Color.mutedGrape)
        }
        .frame(maxWidth: .infinity)
      }
    }
  }

  // MARK: - Time Saved Card

  private var timeSavedCard: some View {
    VStack(spacing: 8) {
      LevelCard(
        background: viewModel.todayTimeSaved > 0 ? .teaGreen : .cream,
        showBorder: false
      ) {
        VStack(alignment: .leading, spacing: 6) {
          HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(viewModel.timeSavedFormatted)
              .font(LevelFont.extraBold(40))
              .foregroundStyle(Color.vintageGrape)
            if viewModel.todayTimeSaved > 0 {
              Image(systemName: "arrow.up")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.darkGreen)
            }
          }
          Text("saved today")
            .font(.levelCaption)
            .foregroundStyle(Color.vintageGrape.opacity(0.7))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }

      Text("\(viewModel.unlocksRemaining) of \(viewModel.unlocksTotal) opens left today")
        .font(.levelCaption)
        .foregroundStyle(Color.mutedGrape)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
    }
  }

  // MARK: - Reason Card

  private var reasonCard: some View {
    ReasonCard(reasons: viewModel.reasons, displayIndex: 0)
  }

  // MARK: - Helpers

  private func checkTriggerPrompt() {
    let declined = SharedStore.defaults.integer(forKey: "todayDeclinedCount")
    let alreadyShown = SharedStore.defaults.bool(forKey: "triggerPromptShownThisSession")
    if declined >= 3 && !alreadyShown {
      withAnimation(.spring(response: 0.4, dampingFraction: 0.85).delay(0.5)) {
        showTriggerPrompt = true
      }
    }
  }
}

#Preview {
  HomeView()
    .modelContainer(DataStore.shared.container)
}
