import Foundation
import SwiftData
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
  @Published var todayScreenTime: TimeInterval = 0
  @Published var yesterdayScreenTime: TimeInterval = 0
  @Published var momentumScore: Int = 100
  @Published var streak: Int = 0
  @Published var unlocksRemaining: Int = 10
  @Published var unlocksTotal: Int = 10
  @Published var allowanceMinutesTotal: Int = 30
  @Published var allowanceMinutesUsed: Int = 0
  @Published var weeklyDays: [WeeklyDayData] = []
  @Published var reasons: [String] = []
  @Published var goalMet: Bool = false
  @Published var momentumTrendScores: [Double] = []
  @Published var momentumTrendLabels: [String] = []
  @Published var recentTrigger: String?
  @Published var isTrackingBaseline: Bool = true
  @Published var baselineSeconds: TimeInterval = 0

  var xpPoints: Int { SharedStore.defaults.integer(forKey: "totalXP") }

  var allowanceSubtitle: String {
    let remaining = max(0, allowanceMinutesTotal - allowanceMinutesUsed)
    return "\(remaining)m of \(allowanceMinutesTotal)m left today"
  }

  var todayTimeSaved: TimeInterval {
    guard !isTrackingBaseline else { return 0 }
    return max(0, baselineSeconds - todayScreenTime)
  }

  var timeSavedFormatted: String {
    let seconds = Int(todayTimeSaved)
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    if hours > 0 {
      return "\(hours)h \(minutes)m"
    }
    return "\(minutes)m"
  }

  private var engine: MomentumEngine?

  func configure(context: ModelContext) {
    engine = MomentumEngine(context: context)
  }

  func refresh(context: ModelContext) {
    if engine == nil {
      engine = MomentumEngine(context: context)
    }

    engine?.updateToday()

    switch BaselineCalculator.resolve(context: context) {
    case .tracking:
      isTrackingBaseline = true
      baselineSeconds = 0
    case .ready(let seconds):
      isTrackingBaseline = false
      baselineSeconds = seconds
    }

    if let today = engine?.todayRecord() {
      todayScreenTime = today.totalScreenTime
      momentumScore = Int(today.momentumScore.rounded())
      unlocksRemaining = max(0, today.unlockLimit - today.unlockCount)
      unlocksTotal = today.unlockLimit
      goalMet = today.goalMet
      allowanceMinutesTotal = max(1, Int((today.dailyAllowanceSeconds / 60).rounded()))
      allowanceMinutesUsed = min(allowanceMinutesTotal, Int((today.totalScreenTime / 60).rounded()))
    }

    let allowanceFromDefaults = SharedStore.defaults.integer(forKey: "dailyAllowanceMinutes")
    if allowanceFromDefaults > 0 {
      allowanceMinutesTotal = allowanceFromDefaults
    }

    streak = engine?.currentStreak() ?? 0

    loadReasons(context: context)
    buildWeeklyData()
    buildMomentumTrend()
    loadRecentTrigger(context: context)
  }

  private func loadRecentTrigger(context: ModelContext) {
    var descriptor = FetchDescriptor<TriggerLog>(
      sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
    )
    descriptor.fetchLimit = 1
    if let log = try? context.fetch(descriptor).first {
      recentTrigger = log.trigger
    } else {
      recentTrigger = nil
    }
  }

  private func loadReasons(context: ModelContext) {
    let descriptor = FetchDescriptor<UserProfile>()
    if let profile = try? context.fetch(descriptor).first {
      reasons = profile.reasons
    }
  }

  private func buildWeeklyData() {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let records = engine?.weekRecords() ?? []

    let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    var days: [WeeklyDayData] = []

    for offset in (0..<7).reversed() {
      guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
      let weekday = calendar.component(.weekday, from: date)
      let index = (weekday + 5) % 7
      let name = dayNames[index]

      let record = records.first {
        calendar.isDate($0.date, inSameDayAs: date)
      }
      let met = record?.goalMet ?? false

      days.append(WeeklyDayData(label: name, seconds: record?.totalScreenTime ?? 0, goalMet: met, isToday: offset == 0))
    }

    weeklyDays = days
  }

  private func buildMomentumTrend() {
    let records = engine?.weekRecords() ?? []
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var scores: [Double] = []
    var labels: [String] = []

    for offset in (0..<7).reversed() {
      guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
      let record = records.first { calendar.isDate($0.date, inSameDayAs: date) }

      if let record {
        scores.append(record.momentumScore)
      } else if !scores.isEmpty {
        scores.append(scores.last ?? 50)
      }

      let weekday = calendar.component(.weekday, from: date)
      let index = (weekday + 5) % 7
      labels.append(dayNames[index])
    }

    momentumTrendScores = scores
    momentumTrendLabels = labels
  }
}

private extension Int {
  func clamped(fallback: Int) -> Int {
    self == 0 ? fallback : self
  }
}
