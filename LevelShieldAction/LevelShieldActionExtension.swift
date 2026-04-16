import Foundation
import ManagedSettings

class LevelShieldActionExtension: ShieldActionDelegate {

  private let defaults = UserDefaults(suiteName: "group.com.paultaylor.level")

  override func handle(
    action: ShieldAction,
    for application: ApplicationToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    handleAction(action, completionHandler: completionHandler)
  }

  override func handle(
    action: ShieldAction,
    for category: ActivityCategoryToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    handleAction(action, completionHandler: completionHandler)
  }

  override func handle(
    action: ShieldAction,
    for webDomain: WebDomainToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    handleAction(action, completionHandler: completionHandler)
  }

  private func handleAction(
    _ action: ShieldAction,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    let isFocusSession = defaults?.bool(forKey: "focusSessionActive") == true
    let currentMode = defaults?.string(forKey: "currentLevelMode") ?? ""
    let isRest = currentMode == "rest"
    let unlockCount = defaults?.integer(forKey: "todayUnlockCount") ?? 0
    let unlockLimit = (defaults?.integer(forKey: "defaultUnlockLimit")).flatMap { $0 > 0 ? $0 : nil } ?? 10
    let exhausted = unlockCount >= unlockLimit

    switch action {
    case .primaryButtonPressed:
      if isFocusSession || isRest || exhausted {
        completionHandler(.close)
        return
      }

      // "Open anyway": clear shields, count unlock, start session
      let store = ManagedSettingsStore(named: .init("LevelMain"))
      store.shield.applications = nil
      store.shield.applicationCategories = nil
      store.shield.webDomains = nil

      defaults?.set(unlockCount + 1, forKey: "todayUnlockCount")
      defaults?.set(Date(), forKey: "sessionStartTimestamp")

      completionHandler(.close)

    case .secondaryButtonPressed:
      // "I'm good": award 10 XP
      let declined = defaults?.integer(forKey: "todayDeclinedCount") ?? 0
      defaults?.set(declined + 1, forKey: "todayDeclinedCount")
      let xp = defaults?.integer(forKey: "totalXP") ?? 0
      defaults?.set(xp + 10, forKey: "totalXP")
      completionHandler(.close)

    @unknown default:
      completionHandler(.close)
    }
  }
}
