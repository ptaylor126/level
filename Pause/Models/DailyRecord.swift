import Foundation
import SwiftData

@Model
final class DailyRecord {
  var date: Date
  var totalScreenTime: TimeInterval
  var unlockCount: Int
  var unlockLimit: Int
  var momentumScore: Double
  var goalMet: Bool

  init(
    date: Date,
    totalScreenTime: TimeInterval = 0,
    unlockCount: Int = 0,
    unlockLimit: Int = 10,
    momentumScore: Double = 50,
    goalMet: Bool = false
  ) {
    self.date = date
    self.totalScreenTime = totalScreenTime
    self.unlockCount = unlockCount
    self.unlockLimit = unlockLimit
    self.momentumScore = momentumScore
    self.goalMet = goalMet
  }
}
