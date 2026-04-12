import Foundation
import SwiftData

@Model
final class UserProfile {
  var reasons: [String]
  var onboardingComplete: Bool
  var createdAt: Date

  init(reasons: [String] = [], onboardingComplete: Bool = false, createdAt: Date = .now) {
    self.reasons = reasons
    self.onboardingComplete = onboardingComplete
    self.createdAt = createdAt
  }
}
