import SwiftData
import SwiftUI

struct StatsView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.scenePhase) private var scenePhase
  @StateObject private var viewModel = StatsViewModel()

  private func formattedTime(_ seconds: TimeInterval) -> String {
    let s = Int(seconds)
    let h = s / 3600
    let m = (s % 3600) / 60
    if h > 0 { return "\(h)h \(m)m" }
    return "\(m)m"
  }

  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()

      ScrollView(showsIndicators: false) {
        VStack(spacing: 24) {
          header

          TimeSavedSummaryCard(
            timeSaved: viewModel.weekTimeSaved,
            vsLastWeek: viewModel.weekTimeSavedVsPrior
          )

          ManagedAppsBreakdownCard()

          weeklyOverviewSection

          MomentumTrend30Card(
            scores: viewModel.momentumScores30,
            direction: viewModel.momentumDirection
          )

          TriggerPatternsCard(
            triggerCounts: viewModel.triggerCounts,
            topTrigger: viewModel.topTrigger
          )

          XPHistoryCard(totalXP: viewModel.totalXP)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 32)
      }
    }
    .onAppear {
      viewModel.refresh(context: context)
    }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        viewModel.refresh(context: context)
      }
    }
  }

  private var header: some View {
    HStack {
      Text("Stats")
        .font(.levelH1)
        .foregroundStyle(Color.cream)

      Spacer()
    }
    .padding(.vertical, 8)
  }

  private var weeklyOverviewSection: some View {
    VStack(spacing: 12) {
      WeeklyChartCard(days: viewModel.weekDays)

      if viewModel.weekDays.contains(where: { $0.seconds > 0 }) {
        HStack {
          if let best = viewModel.bestDay {
            VStack(alignment: .leading, spacing: 2) {
              Text("BEST DAY")
                .font(.levelLabel)
                .tracking(0.5)
                .foregroundStyle(Color.mutedGrape)
              Text("\(best.label) — \(formattedTime(best.seconds))")
                .font(.levelCaption)
                .foregroundStyle(Color.cream)
            }
          }

          Spacer()

          if let tough = viewModel.toughestDay {
            VStack(alignment: .trailing, spacing: 2) {
              Text("TOUGHEST DAY")
                .font(.levelLabel)
                .tracking(0.5)
                .foregroundStyle(Color.mutedGrape)
              Text("\(tough.label) — \(formattedTime(tough.seconds))")
                .font(.levelCaption)
                .foregroundStyle(Color.cream)
            }
          }
        }
        .padding(.horizontal, 4)
      }
    }
  }
}

#Preview {
  StatsView()
    .modelContainer(DataStore.shared.container)
}
