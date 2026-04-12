import Foundation

enum SharedStore {
  static let appGroupIdentifier = "group.com.paultaylor.pause"

  static let defaults: UserDefaults = {
    UserDefaults(suiteName: appGroupIdentifier) ?? .standard
  }()

  enum Key {
    static let familyActivitySelection = "familyActivitySelection"
    static let unlockCounts = "unlockCounts"
    static let declinedOpens = "declinedOpens"
  }
}
