import Foundation
import SwiftData

@Model
final class AppSettings {
  var defaultDelaySeconds: Int
  var delayIncrementSeconds: Int
  var defaultUnlockLimit: Int
  var notifyWeeklyRecap: Bool
  var notifyMorningSummary: Bool
  var notifyStreakAtRisk: Bool
  var appearanceMode: String

  init(
    defaultDelaySeconds: Int = 10,
    delayIncrementSeconds: Int = 10,
    defaultUnlockLimit: Int = 10,
    notifyWeeklyRecap: Bool = true,
    notifyMorningSummary: Bool = false,
    notifyStreakAtRisk: Bool = false,
    appearanceMode: String = "system"
  ) {
    self.defaultDelaySeconds = defaultDelaySeconds
    self.delayIncrementSeconds = delayIncrementSeconds
    self.defaultUnlockLimit = defaultUnlockLimit
    self.notifyWeeklyRecap = notifyWeeklyRecap
    self.notifyMorningSummary = notifyMorningSummary
    self.notifyStreakAtRisk = notifyStreakAtRisk
    self.appearanceMode = appearanceMode
  }
}
