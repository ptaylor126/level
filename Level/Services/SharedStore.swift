import Foundation

enum SharedStore {
  static let appGroupIdentifier = "group.com.paultaylor.level"

  static let defaults: UserDefaults = {
    UserDefaults(suiteName: appGroupIdentifier) ?? .standard
  }()

  enum Key {
    static let familyActivitySelection = "familyActivitySelection"
    static let unlockCounts = "unlockCounts"
    static let declinedOpens = "declinedOpens"

    // Schedule / mode keys
    static let currentLevelMode = "currentLevelMode"
    static let quickModeRaw = "quickModeRaw"
    static let quickModeStartTimestamp = "quickModeStartTimestamp"
  }
}
