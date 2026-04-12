import Foundation
import SwiftData

@Model
final class TriggerLog {
  var timestamp: Date
  var trigger: String

  init(timestamp: Date = .now, trigger: String) {
    self.timestamp = timestamp
    self.trigger = trigger
  }
}
