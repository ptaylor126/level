import Foundation
import SwiftData

enum BaselineState {
  case tracking(daysCollected: Int)
  case ready(seconds: TimeInterval)
}

@MainActor
enum BaselineCalculator {
  static let requiredDays = 3

  static func resolve(context: ModelContext) -> BaselineState {
    let profile = fetchProfile(context: context)

    if let cached = profile?.computedBaselineSeconds, cached > 0 {
      return .ready(seconds: cached)
    }

    let days = trackingDays(context: context)

    if days.count >= requiredDays {
      let average = days.reduce(0, +) / Double(days.count)
      profile?.computedBaselineSeconds = average
      try? context.save()
      return .ready(seconds: average)
    }

    return .tracking(daysCollected: days.count)
  }

  private static func trackingDays(context: ModelContext) -> [TimeInterval] {
    let calendar = Calendar.current
    let startOfToday = calendar.startOfDay(for: Date())

    let descriptor = FetchDescriptor<DailyRecord>(
      predicate: #Predicate { $0.date < startOfToday && $0.totalScreenTime > 0 },
      sortBy: [SortDescriptor(\.date, order: .forward)]
    )
    let records = (try? context.fetch(descriptor)) ?? []
    return records.prefix(requiredDays).map { $0.totalScreenTime }
  }

  private static func fetchProfile(context: ModelContext) -> UserProfile? {
    let descriptor = FetchDescriptor<UserProfile>()
    return try? context.fetch(descriptor).first
  }
}
