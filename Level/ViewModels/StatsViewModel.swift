import Foundation
import SwiftData
import SwiftUI

@MainActor
final class StatsViewModel: ObservableObject {
  @Published var weekTimeSaved: TimeInterval = 0
  @Published var weekTimeSavedVsPrior: Double = 0
  @Published var weekDays: [WeeklyDayData] = []
  @Published var bestDay: (label: String, seconds: TimeInterval)? = nil
  @Published var toughestDay: (label: String, seconds: TimeInterval)? = nil
  @Published var momentumScores30: [Double] = []
  @Published var momentumDirection: String = "Holding steady"
  @Published var triggerCounts: [(trigger: String, count: Int)] = []
  @Published var topTrigger: String? = nil
  @Published var totalXP: Int = 0

  private var engine: MomentumEngine?

  func refresh(context: ModelContext) {
    if engine == nil {
      engine = MomentumEngine(context: context)
    }

    totalXP = SharedStore.defaults.integer(forKey: "totalXP")

    buildWeekTimeSaved(context: context)
    buildWeeklyData()
    buildMomentum30()
    buildTriggerData(context: context)
  }

  private func buildWeekTimeSaved(context: ModelContext) {
    guard let eng = engine else { return }

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let baseline = SharedStore.defaults.double(forKey: "baselineSeconds")
    let dailyBaseline = baseline > 0 ? baseline : 3.5 * 3600

    let currentWeekRecords = eng.weekRecords()

    var currentSaved: TimeInterval = 0
    for offset in 0..<7 {
      guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
      if let record = currentWeekRecords.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
        currentSaved += max(0, dailyBaseline - record.totalScreenTime)
      }
    }
    weekTimeSaved = currentSaved

    guard let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: today),
          let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: today) else { return }

    let priorDescriptor = FetchDescriptor<DailyRecord>(
      predicate: #Predicate { $0.date >= twoWeeksAgo && $0.date < oneWeekAgo },
      sortBy: [SortDescriptor(\.date, order: .forward)]
    )
    let priorRecords = (try? context.fetch(priorDescriptor)) ?? []

    var priorSaved: TimeInterval = 0
    for offset in 0..<7 {
      guard let date = calendar.date(byAdding: .day, value: -(offset + 7), to: today) else { continue }
      if let record = priorRecords.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
        priorSaved += max(0, dailyBaseline - record.totalScreenTime)
      }
    }

    if priorSaved > 0 {
      weekTimeSavedVsPrior = ((currentSaved - priorSaved) / priorSaved) * 100
    } else {
      weekTimeSavedVsPrior = 0
    }
  }

  private func buildWeeklyData() {
    guard let eng = engine else { return }

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let records = eng.weekRecords()
    let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    var days: [WeeklyDayData] = []

    for offset in (0..<7).reversed() {
      guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
      let weekday = calendar.component(.weekday, from: date)
      let index = (weekday + 5) % 7
      let name = dayNames[index]

      let record = records.first { calendar.isDate($0.date, inSameDayAs: date) }
      let seconds = record?.totalScreenTime ?? 0
      let met = record?.goalMet ?? false

      days.append(WeeklyDayData(label: name, seconds: seconds, goalMet: met, isToday: offset == 0))
    }

    weekDays = days

    let daysWithData = days.filter { $0.seconds > 0 }
    if let best = daysWithData.min(by: { $0.seconds < $1.seconds }) {
      bestDay = (label: best.label, seconds: best.seconds)
    } else {
      bestDay = nil
    }
    if let toughest = daysWithData.max(by: { $0.seconds < $1.seconds }) {
      toughestDay = (label: toughest.label, seconds: toughest.seconds)
    } else {
      toughestDay = nil
    }
  }

  private func buildMomentum30() {
    guard let eng = engine else { return }

    let records = eng.monthRecords()
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    var scores: [Double] = []

    for offset in (0..<30).reversed() {
      guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
      if let record = records.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
        scores.append(record.momentumScore)
      } else if !scores.isEmpty {
        scores.append(scores.last ?? 50)
      }
    }

    momentumScores30 = scores

    if scores.count >= 7 {
      let recent = scores.suffix(7)
      let older = scores.dropLast(7).suffix(7)
      let recentAvg = recent.reduce(0, +) / Double(recent.count)
      let olderAvg = older.isEmpty ? recentAvg : older.reduce(0, +) / Double(older.count)
      let diff = recentAvg - olderAvg
      if diff > 2 {
        momentumDirection = "Trending up"
      } else if diff < -2 {
        momentumDirection = "Dipping — you've got this"
      } else {
        momentumDirection = "Holding steady"
      }
    } else {
      momentumDirection = "Holding steady"
    }
  }

  private func buildTriggerData(context: ModelContext) {
    let tracker = TriggerTracker(context: context)
    let counts = tracker.allTimeCounts()
    triggerCounts = counts
    topTrigger = counts.first?.trigger
  }
}

private extension StatsViewModel {
  func formattedTime(_ seconds: TimeInterval) -> String {
    let s = Int(seconds)
    let h = s / 3600
    let m = (s % 3600) / 60
    if h > 0 { return "\(h)h \(m)m" }
    return "\(m)m"
  }
}
