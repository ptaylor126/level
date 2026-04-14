import Foundation
import SwiftData

@MainActor
final class MomentumEngine {

  private let context: ModelContext

  init(context: ModelContext) {
    self.context = context
  }

  func calculateDailyScore(for record: DailyRecord, previous: DailyRecord?) -> Double {
    let previousScore = previous?.momentumScore ?? 50

    var delta: Double = 0

    let screenTimeGoalSeconds: TimeInterval = 2 * 3600
    if record.totalScreenTime < screenTimeGoalSeconds {
      delta += 3
    } else {
      delta -= 2
    }

    let halfLimit = Double(record.unlockLimit) * 0.5
    if Double(record.unlockCount) < halfLimit {
      delta += 2
    }

    if record.unlockCount >= record.unlockLimit {
      delta -= 1
    }

    let declinedOpens = SharedStore.defaults.integer(forKey: SharedStore.Key.declinedOpens)
    delta += Double(min(declinedOpens, 5))

    let raw = previousScore + delta
    let smoothed = (0.7 * raw) + (0.3 * previousScore)
    return min(100, max(0, smoothed))
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

    let yesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday)!
    let yesterdayDescriptor = FetchDescriptor<DailyRecord>(
      predicate: #Predicate { record in
        record.date >= yesterday && record.date < startOfToday
      },
      sortBy: [SortDescriptor(\.date, order: .reverse)]
    )
    let previousRecord = try? context.fetch(yesterdayDescriptor).first

    todayRecord.momentumScore = calculateDailyScore(for: todayRecord, previous: previousRecord)

    let screenTimeGoalSeconds: TimeInterval = 2 * 3600
    todayRecord.goalMet = todayRecord.totalScreenTime < screenTimeGoalSeconds

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
