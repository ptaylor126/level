import SwiftData
import SwiftUI

struct HomeView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.scenePhase) private var scenePhase
  @StateObject private var viewModel = HomeViewModel()
  @State private var appeared = false

  private var dateString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d"
    return formatter.string(from: Date())
  }

  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()

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
    }
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        viewModel.refresh(context: context)
      }
    }
  }

  private var headerRow: some View {
    HStack(alignment: .bottom) {
      VStack(alignment: .leading, spacing: 2) {
        PauseWordmark(size: 28, color: .cream)
        Text(dateString)
          .font(.pauseCaption)
          .foregroundStyle(Color.mutedGrape)
      }
      Spacer()
      PauseIconView(icon: .gear, size: 22, color: .mutedGrape)
        .padding(.bottom, 2)
    }
    .padding(.vertical, 8)
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
