import Foundation
import SwiftData

@Model
final class DailyRecord {
  var date: Date
  var totalScreenTime: TimeInterval
  var unlockCount: Int
  var unlockLimit: Int
  var dailyAllowanceSeconds: TimeInterval
  var focusSessionSeconds: TimeInterval
  var momentumScore: Double
  var goalMet: Bool

  init(
    date: Date,
    totalScreenTime: TimeInterval = 0,
    unlockCount: Int = 0,
    unlockLimit: Int = 10,
    dailyAllowanceSeconds: TimeInterval = 30 * 60,
    focusSessionSeconds: TimeInterval = 0,
    momentumScore: Double = 100,
    goalMet: Bool = false
  ) {
    self.date = date
    self.totalScreenTime = totalScreenTime
    self.unlockCount = unlockCount
    self.unlockLimit = unlockLimit
    self.dailyAllowanceSeconds = dailyAllowanceSeconds
    self.focusSessionSeconds = focusSessionSeconds
    self.momentumScore = momentumScore
    self.goalMet = goalMet
  }
}
