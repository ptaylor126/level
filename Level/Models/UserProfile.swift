import Foundation
import SwiftData

@Model
final class UserProfile {
  var reasons: [String]
  var onboardingComplete: Bool
  var createdAt: Date
  var computedBaselineSeconds: Double?

  init(
    reasons: [String] = [],
    onboardingComplete: Bool = false,
    createdAt: Date = .now,
    computedBaselineSeconds: Double? = nil
  ) {
    self.reasons = reasons
    self.onboardingComplete = onboardingComplete
    self.createdAt = createdAt
    self.computedBaselineSeconds = computedBaselineSeconds
  }
}
