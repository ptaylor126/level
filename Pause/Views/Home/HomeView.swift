import SwiftUI

/// Root home screen — a scrollable bento grid of data cards.
/// All values are mock/placeholder; the real data pipeline is wired up separately.
struct HomeView: View {
  // MARK: - Appearance state
  @State private var appeared = false

  // MARK: - Mock data (replace with real view model bindings later)
  private let todaySeconds: TimeInterval       = 5700    // 1h 35m
  private let yesterdaySeconds: TimeInterval   = 7200    // 2h 00m
  private let momentumScore: Int               = 74
  private let streak: Int                      = 9
  private let unlocksRemaining: Int            = 6
  private let unlocksTotal: Int                = 10
  private let weeklyDays: [WeeklyDayData]      = WeeklyChartCard.mockDays
  private let appLimits: [AppLimitData]        = AppLimitsCard.mockLimits
  private let reasons: [String]                = [
    "Be more present with my family.",
    "Read more books.",
    "Sleep better.",
    "Get more work done.",
  ]

  // MARK: - Formatted date
  private var dateString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d"
    return formatter.string(from: Date())
  }

  // MARK: - Body
  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()

      ScrollView(showsIndicators: false) {
        VStack(spacing: 12) {
          // ── Header ─────────────────────────────────────────────────────────
          headerRow

          // ── Screen Time (full width) ───────────────────────────────────────
          ScreenTimeCard(
            todaySeconds: todaySeconds,
            yesterdaySeconds: yesterdaySeconds
          )

          // ── Momentum + Unlocks (half width pair) ──────────────────────────
          halfWidthRow

          // ── Weekly Chart (full width) ─────────────────────────────────────
          WeeklyChartCard(days: weeklyDays)

          // ── App Limits (full width) ───────────────────────────────────────
          AppLimitsCard(limits: appLimits)

          // ── Reason (full width) ───────────────────────────────────────────
          ReasonCard(reasons: reasons, displayIndex: 0)

          // Bottom breathing room
          Spacer(minLength: 32)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        // Subtle fade-in on first appearance
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.2), value: appeared)
      }
    }
    .onAppear {
      appeared = true
    }
  }

  // MARK: - Subviews

  private var headerRow: some View {
    HStack(alignment: .bottom) {
      VStack(alignment: .leading, spacing: 2) {
        PauseWordmark(size: 28, color: .cream)
        Text(dateString)
          .font(.pauseCaption)
          .foregroundStyle(Color.mutedGrape)
      }
      Spacer()

      // Settings gear — navigates to settings (wire up later)
      PauseIconView(icon: .gear, size: 22, color: .mutedGrape)
        .padding(.bottom, 2)
    }
    .padding(.vertical, 8)
  }

  private var halfWidthRow: some View {
    HStack(spacing: 12) {
      MomentumCard(score: momentumScore, streak: streak)
        .frame(maxWidth: .infinity)

      UnlocksCard(remaining: unlocksRemaining, total: unlocksTotal)
        .frame(maxWidth: .infinity)
    }
  }
}

#Preview {
  HomeView()
}
