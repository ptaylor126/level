import Foundation
import SwiftData
import SwiftUI

enum LevelMode: String, Codable, CaseIterable {
  case boss, base, rest, off

  var displayName: String {
    switch self {
    case .boss: return "Boss Level"
    case .base: return "Base Level"
    case .rest: return "Rest Level"
    case .off: return "Off"
    }
  }

  /// Background card color for this mode
  var cardColor: Color {
    switch self {
    case .boss: return .teaGreen
    case .base: return .cream
    case .rest: return .pastelPink
    case .off: return .mutedGrape
    }
  }

  /// Text/foreground color appropriate for each mode's card surface
  var textColor: Color {
    switch self {
    case .boss: return .darkGreen
    case .base: return .vintageGrape
    case .rest: return .rose
    case .off: return .cream
    }
  }

  /// Compact accent color for timeline segments and pills
  var segmentColor: Color {
    switch self {
    case .boss: return .teaGreen
    case .base: return .cream
    case .rest: return .pastelPink
    case .off: return .clear
    }
  }
}

@Model
final class ScheduleBlock {
  var startHour: Int         // 0-23
  var startMinute: Int       // 0-59
  var endHour: Int           // 0-23
  var endMinute: Int         // 0-59
  var modeRaw: String
  var dayOfWeek: Int         // 0=Sunday, 1=Monday, ... 6=Saturday. -1 = every day
  var createdAt: Date

  var mode: LevelMode {
    get { LevelMode(rawValue: modeRaw) ?? .base }
    set { modeRaw = newValue.rawValue }
  }

  /// Start time as total minutes from midnight (for sorting/comparison)
  var startMinutes: Int { startHour * 60 + startMinute }

  /// End time as total minutes from midnight
  var endMinutes: Int { endHour * 60 + endMinute }

  /// Formatted time range string, e.g. "7:00 - 9:00 AM"
  var timeRangeLabel: String {
    let startFormatted = formatTime(hour: startHour, minute: startMinute)
    let endFormatted = formatTime(hour: endHour, minute: endMinute)
    let ampm = endHour < 12 ? "AM" : "PM"
    return "\(startFormatted) - \(endFormatted) \(ampm)"
  }

  private func formatTime(hour: Int, minute: Int) -> String {
    let displayHour = hour % 12 == 0 ? 12 : hour % 12
    if minute == 0 {
      return "\(displayHour):00"
    }
    return String(format: "%d:%02d", displayHour, minute)
  }

  init(
    startHour: Int,
    startMinute: Int = 0,
    endHour: Int,
    endMinute: Int = 0,
    mode: LevelMode,
    dayOfWeek: Int = -1
  ) {
    self.startHour = startHour
    self.startMinute = startMinute
    self.endHour = endHour
    self.endMinute = endMinute
    self.modeRaw = mode.rawValue
    self.dayOfWeek = dayOfWeek
    self.createdAt = .now
  }
}
