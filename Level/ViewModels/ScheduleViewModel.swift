import Foundation
import SwiftData
import SwiftUI

@MainActor
final class ScheduleViewModel: ObservableObject {
  @Published var blocks: [ScheduleBlock] = []
  @Published var currentMode: LevelMode = .off
  @Published var nextChangeLabel: String? = nil
  @Published var hasSchedule: Bool = false

  private var manager: ScheduleManager

  init(manager: ScheduleManager) {
    self.manager = manager
  }

  // MARK: - Refresh

  func refresh(context: ModelContext) {
    let descriptor = FetchDescriptor<ScheduleBlock>(
      sortBy: [SortDescriptor(\.startHour), SortDescriptor(\.startMinute)]
    )
    blocks = (try? context.fetch(descriptor)) ?? []
    hasSchedule = !blocks.isEmpty

    manager.refresh(context: context, blocks: blocks)
    currentMode = manager.currentMode
    buildNextChangeLabel()
  }

  private func buildNextChangeLabel() {
    guard let next = manager.nextChange else {
      nextChangeLabel = nil
      return
    }
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mma"
    formatter.amSymbol = "am"
    formatter.pmSymbol = "pm"
    let timeStr = formatter.string(from: next.startsAt)
    nextChangeLabel = "\(next.mode.displayName) starts at \(timeStr)"
  }

  // MARK: - Mutating

  func addBlock(
    startHour: Int,
    startMinute: Int,
    endHour: Int,
    endMinute: Int,
    mode: LevelMode,
    context: ModelContext
  ) {
    let block = ScheduleBlock(
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      mode: mode
    )
    context.insert(block)
    try? context.save()
    refresh(context: context)
  }

  func removeBlock(_ block: ScheduleBlock, context: ModelContext) {
    context.delete(block)
    try? context.save()
    refresh(context: context)
  }

  func installDefault(context: ModelContext) {
    manager.installDefaultSchedule(context: context)
    refresh(context: context)
  }

  func setQuickMode(_ mode: LevelMode, context: ModelContext) {
    manager.setQuickMode(mode, blocks: blocks)
    refresh(context: context)
  }

  func clearQuickMode(context: ModelContext) {
    manager.clearQuickMode(blocks: blocks)
    refresh(context: context)
  }

  // MARK: - Convenience

  /// Label for the current mode card's primary line, e.g. "Boss Level until 9:00pm"
  var currentModeTitle: String {
    guard currentMode != .off else { return "Off" }
    if let next = manager.nextChange {
      let formatter = DateFormatter()
      formatter.dateFormat = "h:mma"
      formatter.amSymbol = "am"
      formatter.pmSymbol = "pm"
      return "\(currentMode.displayName) until \(formatter.string(from: next.startsAt))"
    }
    return currentMode.displayName
  }
}
