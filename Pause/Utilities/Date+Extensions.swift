import Foundation

extension Date {
  var startOfDay: Date {
    Calendar.current.startOfDay(for: self)
  }

  var isToday: Bool {
    Calendar.current.isDateInToday(self)
  }

  var isYesterday: Bool {
    Calendar.current.isDateInYesterday(self)
  }

  func daysBetween(_ other: Date) -> Int {
    let start = Calendar.current.startOfDay(for: self)
    let end = Calendar.current.startOfDay(for: other)
    return abs(Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0)
  }

  func formatted(as format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: self)
  }
}
