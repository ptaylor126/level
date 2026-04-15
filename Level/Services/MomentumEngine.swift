import Foundation
import SwiftData

@MainActor
final class MomentumEngine {

  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  /// Drain model: each day starts at 100. Time spent on blocked apps drains
  /// the tank proportional to the daily allowance. Focus sessions recharge at
  /// a 4:1 ratio (4 min focus earns back 1 min of drained score).
  func calculateDailyScore(for record: DailyRecord, previous: DailyRecord?) -> Double {
    let allowance = max(60, record.dailyAllowanceSeconds)
    let usedSeconds = max(0, record.totalScreenTime)
    let drainFraction = min(1.0, usedSeconds / allowance)
    let drainedPoints = drainFraction * 100.0

    let rechargeSeconds = record.focusSessionSeconds / 4.0
    let rechargePoints = (rechargeSeconds / allowance) * 100.0

    let raw = 100.0 - drainedPoints + rechargePoints
    return min(100, max(0, raw))
  }

  func updateToday() {
    let calendar = Calendar.current
    let startOfToday = calendar.startOfDay(for: Date())

    let descriptor = FetchDescriptor<DailyRecord>(
      predicate: #Predicate { $0.date >= startOfToday },
      sortBy: [SortDescriptor(\.date, order: .reverse)]
    )

    let todayRecord: DailyRecord
    if let existing = try? context.fetch(descriptor).first {
      todayRecord = existing
    } else {
      todayRecord = DailyRecord(date: startOfToday)
      context.insert(todayRecord)
    }

    todayRecord.unlockCount = SharedStore.defaults.integer(forKey: "todayUnlockCount")

    let allowanceMinutes = SharedStore.defaults.integer(forKey: "dailyAllowanceMinutes")
    if allowanceMinutes > 0 {
      todayRecord.dailyAllowanceSeconds = TimeInterval(allowanceMinutes * 60)
    }
    let focusSeconds = SharedStore.defaults.double(forKey: "todayFocusSessionSeconds")
    todayRecord.focusSessionSeconds = focusSeconds

    let yesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
    let yesterdayDescriptor = FetchDescriptor<DailyRecord>(
      predicate: #Predicate { record in
        record.date >= yesterday && record.date < startOfToday
      },
      sortBy: [SortDescriptor(\.date, order: .reverse)]
    )
    let previousRecord = try? context.fetch(yesterdayDescriptor).first

    todayRecord.momentumScore = calculateDailyScore(for: todayRecord, previous: previousRecord)
    SharedStore.defaults.set(todayRecord.momentumScore, forKey: "currentMomentumScore")

    todayRecord.goalMet = todayRecord.totalScreenTime < todayRecord.dailyAllowanceSeconds

    try? context.save()
  }

  func currentStreak() -> Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    let descriptor = FetchDescriptor<DailyRecord>(
      sortBy: [SortDescriptor(\.date, order: .reverse)]
    )
    guard let records = try? context.fetch(descriptor) else { return 0 }

    var streak = 0
    var checkDate = today

    for record in records {
      let recordDay = calendar.startOfDay(for: record.date)
      if recordDay == checkDate || recordDay == calendar.date(byAdding: .day, value: -1, to: checkDate)! {
        if record.goalMet {
          streak += 1
          checkDate = recordDay
        } else if recordDay < today {
          break
        }
      } else if recordDay < calendar.date(byAdding: .day, value: -1, to: checkDate)! {
        break
      }
    }
    return streak
  }

  func todayRecord() -> DailyRecord? {
    let startOfToday = Calendar.current.startOfDay(for: Date())
    let descriptor = FetchDescriptor<DailyRecord>(
      predicate: #Predicate { $0.date >= startOfToday },
      sortBy: [SortDescriptor(\.date, order: .reverse)]
    )
    return try? context.fetch(descriptor).first
  }

  func weekRecords() -> [DailyRecord] {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    guard let weekAgo = calendar.date(byAdding: .day, value: -6, to: today) else { return [] }

    let descriptor = FetchDescriptor<DailyRecord>(
      predicate: #Predicate { $0.date >= weekAgo },
      sortBy: [SortDescriptor(\.date, order: .forward)]
    )
    return (try? context.fetch(descriptor)) ?? []
  }

  func monthRecords() -> [DailyRecord] {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    guard let monthAgo = calendar.date(byAdding: .day, value: -29, to: today) else { return [] }
    let descriptor = FetchDescriptor<DailyRecord>(
      predicate: #Predicate { $0.date >= monthAgo },
      sortBy: [SortDescriptor(\.date, order: .forward)]
    )
    return (try? context.fetch(descriptor)) ?? []
  }
}
