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
      backgroundSpotlight.ignoresSafeArea()

      ScrollView(showsIndicators: false) {
        VStack(spacing: 24) {
          topBar

          progressRing

          weekDots

          timeSavedCard

          ManagedAppsCard(
            unlocksSubtitle: viewModel.allowanceSubtitle,
            onTapApp: {
              SharedStore.defaults.set(Date(), forKey: "pendingUnlockTimestamp")
              showPathBCountdown = true
            }
          )

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

  // MARK: - Background

  private var backgroundSpotlight: some View {
    ZStack {
      Color.vintageGrape
      RadialGradient(
        gradient: Gradient(colors: [Color(hex: "5A3F57"), Color.vintageGrape]),
        center: UnitPoint(x: 0.5, y: 0.15),
        startRadius: 20,
        endRadius: 420
      )
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
    HStack(spacing: 5) {
      Image(levelIcon: .flame)
        .resizable()
        .scaledToFit()
        .frame(width: 18, height: 18)
      Text("\(viewModel.streak)")
        .font(LevelFont.bold(15))
        .foregroundStyle(Color.vintageGrape)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 7)
    .background(Color.cream)
    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    .frame(minWidth: 44, minHeight: 44)
    .contentShape(Rectangle())
  }

  private var xpPill: some View {
    HStack(spacing: 5) {
      Image(levelIcon: .diamond)
        .resizable()
        .scaledToFit()
        .frame(width: 18, height: 18)
      Text("\(viewModel.xpPoints)")
        .font(LevelFont.bold(15))
        .foregroundStyle(Color.vintageGrape)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 7)
    .background(Color.cream)
    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    .frame(minWidth: 44, minHeight: 44)
    .contentShape(Rectangle())
  }

  // MARK: - Progress Ring

  private var progressRing: some View {
    VStack(spacing: 12) {
      MomentumTankView(score: viewModel.momentumScore, height: 360)

      Text("MOMENTUM")
        .font(.levelLabel)
        .tracking(1)
        .foregroundStyle(Color.mutedGrape)
    }
    .padding(.vertical, 4)
  }

  // MARK: - Week Dots

  private var weekDots: some View {
    let baseSize: CGFloat = 28
    let todayScale: CGFloat = 1.3
    let rowHeight: CGFloat = baseSize * todayScale + 4

    return VStack(spacing: 8) {
      ZStack {
        GeometryReader { geo in
          let count = viewModel.weeklyDays.count
          let w = geo.size.width
          let stepW = count > 0 ? w / CGFloat(count) : 0
          let midY = geo.size.height / 2

          if count > 1 {
            Path { p in
              p.move(to: CGPoint(x: stepW / 2, y: midY))
              p.addLine(to: CGPoint(x: w - stepW / 2, y: midY))
            }
            .stroke(Color.deepGrape, lineWidth: 3)

            ForEach(0..<max(0, count - 1), id: \.self) { i in
              if viewModel.weeklyDays[i].goalMet && viewModel.weeklyDays[i + 1].goalMet {
                Path { p in
                  let x1 = stepW * (CGFloat(i) + 0.5)
                  let x2 = stepW * (CGFloat(i + 1) + 0.5)
                  p.move(to: CGPoint(x: x1, y: midY))
                  p.addLine(to: CGPoint(x: x2, y: midY))
                }
                .stroke(Color.teaGreen, lineWidth: 3)
              }
            }
          }
        }
        .frame(height: rowHeight)

        HStack(alignment: .center, spacing: 0) {
          ForEach(viewModel.weeklyDays.indices, id: \.self) { index in
            let day = viewModel.weeklyDays[index]
            DayToken(state: tokenState(for: day), size: day.isToday ? baseSize * todayScale : baseSize)
              .frame(maxWidth: .infinity)
          }
        }
        .frame(height: rowHeight)
      }

      HStack(spacing: 0) {
        ForEach(viewModel.weeklyDays.indices, id: \.self) { index in
          Text(viewModel.weeklyDays[index].label)
            .font(.levelLabel)
            .foregroundStyle(Color.mutedGrape)
            .frame(maxWidth: .infinity)
        }
      }
    }
  }

  private func tokenState(for day: WeeklyDayData) -> DayTokenState {
    if day.goalMet { return .completed }
    if day.seconds > 0 { return .missed }
    return .empty
  }

  // MARK: - Time Saved Card

  private var timeSavedCard: some View {
    LevelCard(
        background: viewModel.isTrackingBaseline ? .cream : (viewModel.todayTimeSaved > 0 ? .teaGreen : .cream),
        showBorder: false
      ) {
        VStack(alignment: .leading, spacing: 6) {
          if viewModel.isTrackingBaseline {
            VStack(alignment: .leading, spacing: 2) {
              Text("Tracking your baseline…")
                .font(LevelFont.bold(18))
                .foregroundStyle(Color.vintageGrape.opacity(0.45))
              Text("We'll show your daily time saved after 3 days.")
                .font(.levelCaption)
                .foregroundStyle(Color.vintageGrape.opacity(0.45))
            }
          } else {
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
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
