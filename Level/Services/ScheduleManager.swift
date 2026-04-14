import Foundation
import SwiftData

/// Manages the daily restriction schedule and applies mode settings to SharedStore
/// so the shield extension and other services can read the active configuration.
@MainActor
final class ScheduleManager: ObservableObject {
  @Published var currentMode: LevelMode = .off
  @Published var nextChange: (mode: LevelMode, startsAt: Date)?

  private weak var screenTime: ScreenTimeManager?

  init() {}

  func configure(screenTime: ScreenTimeManager) {
    self.screenTime = screenTime
  }

  // MARK: - Mode Resolution

  /// Returns the active LevelMode for the given date, checking quick mode override first.
  /// Requires blocks to be passed so no SwiftData access happens inside this service directly.
  func resolveMode(for date: Date = .now, blocks: [ScheduleBlock] = []) -> LevelMode {
    // Check quick mode override
    if let quickMode = activeQuickMode(at: date) {
      return quickMode
    }

    return scheduledMode(for: date, in: blocks)
  }

  /// Finds the mode for a date from the provided blocks, or defaults to .off.
  func scheduledMode(for date: Date = .now, in blocks: [ScheduleBlock]?) -> LevelMode {
    guard let blocks else { return .off }
    let cal = Calendar.current
    let weekday = cal.component(.weekday, from: date) - 1 // 0=Sunday
    let minuteOfDay = cal.component(.hour, from: date) * 60 + cal.component(.minute, from: date)

    let match = blocks.first { block in
      let appliesToDay = block.dayOfWeek == -1 || block.dayOfWeek == weekday
      let inRange: Bool
      if block.startMinutes < block.endMinutes {
        inRange = minuteOfDay >= block.startMinutes && minuteOfDay < block.endMinutes
      } else {
        // Wraps midnight
        inRange = minuteOfDay >= block.startMinutes || minuteOfDay < block.endMinutes
      }
      return appliesToDay && inRange
    }
    return match?.mode ?? .off
  }

  /// Returns the next scheduled mode change after the given date (ignoring quick mode).
  func nextModeChange(from date: Date = .now, blocks: [ScheduleBlock]) -> (mode: LevelMode, startsAt: Date)? {
    let cal = Calendar.current
    let weekday = cal.component(.weekday, from: date) - 1
    let minuteOfDay = cal.component(.hour, from: date) * 60 + cal.component(.minute, from: date)
    let startOfDay = cal.startOfDay(for: date)

    // Collect block start/end transitions for today
    var transitions: [(minutes: Int, mode: LevelMode)] = []
    for block in blocks {
      let appliesToDay = block.dayOfWeek == -1 || block.dayOfWeek == weekday
      guard appliesToDay else { continue }
      transitions.append((block.startMinutes, block.mode))
      transitions.append((block.endMinutes, .off))
    }

    // Sort and find first after now
    let sorted = transitions.sorted { $0.minutes < $1.minutes }
    if let next = sorted.first(where: { $0.minutes > minuteOfDay }) {
      let nextDate = startOfDay.addingTimeInterval(TimeInterval(next.minutes * 60))
      return (next.mode, nextDate)
    }
    return nil
  }

  // MARK: - Apply Mode

  /// Writes the current mode's settings to SharedStore so shield and other extensions can read them.
  func applyCurrentMode(blocks: [ScheduleBlock]) {
    let mode = resolveMode(for: .now, blocks: blocks)
    currentMode = mode
    nextChange = nextModeChange(from: .now, blocks: blocks)

    // Write mode string for extensions
    SharedStore.defaults.set(mode.rawValue, forKey: SharedStore.Key.currentLevelMode)

    switch mode {
    case .boss:
      SharedStore.defaults.set(30, forKey: "defaultDelaySeconds")
      SharedStore.defaults.set(15, forKey: "delayIncrementSeconds")
      SharedStore.defaults.set(3, forKey: "defaultUnlockLimit")
      screenTime?.applyShields()

    case .base:
      SharedStore.defaults.set(10, forKey: "defaultDelaySeconds")
      SharedStore.defaults.set(10, forKey: "delayIncrementSeconds")
      SharedStore.defaults.set(10, forKey: "defaultUnlockLimit")
      screenTime?.applyShields()

    case .rest:
      // Shields stay on; extension shows the Rest Level lockout UI
      SharedStore.defaults.set(0, forKey: "defaultDelaySeconds")
      SharedStore.defaults.set(0, forKey: "delayIncrementSeconds")
      SharedStore.defaults.set(0, forKey: "defaultUnlockLimit")
      screenTime?.applyShields()

    case .off:
      SharedStore.defaults.set(0, forKey: "defaultDelaySeconds")
      SharedStore.defaults.set(0, forKey: "delayIncrementSeconds")
      SharedStore.defaults.set(0, forKey: "defaultUnlockLimit")
      screenTime?.clearShields()
    }
  }

  // MARK: - Quick Mode

  /// Returns the active quick mode if one is set and still valid.
  private func activeQuickMode(at date: Date) -> LevelMode? {
    guard
      let raw = SharedStore.defaults.string(forKey: SharedStore.Key.quickModeRaw),
      let mode = LevelMode(rawValue: raw),
      let startTimestamp = SharedStore.defaults.object(forKey: SharedStore.Key.quickModeStartTimestamp) as? Date
    else { return nil }

    // Quick mode is valid if it started before now and we haven't crossed into a new day
    let cal = Calendar.current
    if cal.isDate(startTimestamp, inSameDayAs: date) && startTimestamp <= date {
      return mode
    }
    // Expired — clean up
    clearQuickMode()
    return nil
  }

  func setQuickMode(_ mode: LevelMode, blocks: [ScheduleBlock]) {
    SharedStore.defaults.set(mode.rawValue, forKey: SharedStore.Key.quickModeRaw)
    SharedStore.defaults.set(Date(), forKey: SharedStore.Key.quickModeStartTimestamp)
    applyCurrentMode(blocks: blocks)
  }

  func clearQuickMode(blocks: [ScheduleBlock] = []) {
    SharedStore.defaults.removeObject(forKey: SharedStore.Key.quickModeRaw)
    SharedStore.defaults.removeObject(forKey: SharedStore.Key.quickModeStartTimestamp)
    if !blocks.isEmpty {
      applyCurrentMode(blocks: blocks)
    }
  }

  // MARK: - Default Schedule

  /// Installs the PRD's suggested default schedule into the given ModelContext.
  func installDefaultSchedule(context: ModelContext) {
    let defaults: [(Int, Int, LevelMode)] = [
      (7, 9, .boss),    // 7am–9am Boss
      (9, 17, .base),   // 9am–5pm Base
      (17, 21, .base),  // 5pm–9pm Base
      (21, 7, .rest)    // 9pm–7am Rest (wraps midnight)
    ]

    for (start, end, mode) in defaults {
      let block = ScheduleBlock(startHour: start, endHour: end, mode: mode)
      context.insert(block)
    }

    try? context.save()
  }

  // MARK: - Refresh

  func refresh(context: ModelContext, blocks: [ScheduleBlock]) {
    applyCurrentMode(blocks: blocks)
  }
}
