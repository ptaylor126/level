import Foundation
import SwiftData

@MainActor
final class TriggerTracker: ObservableObject {
  @Published var shouldShowPrompt = false

  private let context: ModelContext
  private var declinedCount = 0
  private var lastInteraction: Date?
  private var promptShownThisSession = false

  private let sessionTimeout: TimeInterval = 30 * 60
  private let promptThreshold = 3

  init(context: ModelContext) {
    self.context = context
  }

  func recordDeclinedOpen() {
    resetSessionIfStale()
    declinedCount += 1
    lastInteraction = Date()

    if declinedCount >= promptThreshold && !promptShownThisSession {
      shouldShowPrompt = true
      promptShownThisSession = true
    }
  }

  func logTrigger(_ trigger: String) {
    let log = TriggerLog(trigger: trigger)
    context.insert(log)
    try? context.save()
    shouldShowPrompt = false
  }

  func dismissPrompt() {
    shouldShowPrompt = false
  }

  func weekSummary() -> (trigger: String, percentage: Int)? {
    let calendar = Calendar.current
    guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else { return nil }

    let descriptor = FetchDescriptor<TriggerLog>(
      predicate: #Predicate { $0.timestamp >= weekAgo }
    )
    guard let logs = try? context.fetch(descriptor), !logs.isEmpty else { return nil }

    var counts: [String: Int] = [:]
    for log in logs {
      counts[log.trigger, default: 0] += 1
    }

    guard let top = counts.max(by: { $0.value < $1.value }) else { return nil }
    let percentage = Int((Double(top.value) / Double(logs.count)) * 100)
    return (trigger: top.key, percentage: percentage)
  }

  func allTimeCounts() -> [(trigger: String, count: Int)] {
    let descriptor = FetchDescriptor<TriggerLog>()
    guard let logs = try? context.fetch(descriptor), !logs.isEmpty else { return [] }

    var counts: [String: Int] = [:]
    for log in logs {
      counts[log.trigger, default: 0] += 1
    }

    return counts
      .sorted { $0.value > $1.value }
      .map { (trigger: $0.key, count: $0.value) }
  }

  private func resetSessionIfStale() {
    if let last = lastInteraction, Date().timeIntervalSince(last) > sessionTimeout {
      declinedCount = 0
      promptShownThisSession = false
    }
  }
}
