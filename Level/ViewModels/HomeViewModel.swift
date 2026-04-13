import Foundation
import SwiftData
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
  @Published var todayScreenTime: TimeInterval = 0
  @Published var yesterdayScreenTime: TimeInterval = 0
  @Published var momentumScore: Int = 50
  @Published var streak: Int = 0
  @Published var unlocksRemaining: Int = 10
  @Published var unlocksTotal: Int = 10
  @Published var weeklyDays: [WeeklyDayData] = []
  @Published var reasons: [String] = []
  @Published var goalMet: Bool = false
  @Published var momentumTrendScores: [Double] = []
  @Published var momentumTrendLabels: [String] = []

  var xpPoints: Int { momentumScore * 10 }

  var todayTimeSaved: TimeInterval {
    max(0, yesterdayScreenTime - todayScreenTime)
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

    if let today = engine?.todayRecord() {
      todayScreenTime = today.totalScreenTime
      momentumScore = Int(today.momentumScore)
      unlocksRemaining = max(0, today.unlockLimit - today.unlockCount)
      unlocksTotal = today.unlockLimit
      goalMet = today.goalMet
    }

    let unlockCount = SharedStore.defaults.integer(forKey: "todayUnlockCount")
    let unlockLimit = SharedStore.defaults.integer(forKey: "defaultUnlockLimit").clamped(fallback: 10)
    unlocksRemaining = max(0, unlockLimit - unlockCount)
    unlocksTotal = unlockLimit

    streak = engine?.currentStreak() ?? 0

    loadReasons(context: context)
    buildWeeklyData()
    buildMomentumTrend()
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
