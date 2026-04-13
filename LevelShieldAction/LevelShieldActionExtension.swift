import Foundation
import ManagedSettings

class LevelShieldActionExtension: ShieldActionDelegate {

  private let defaults = UserDefaults(suiteName: "group.com.paultaylor.level")
  private let store = ManagedSettingsStore(named: .init("LevelMain"))

  override func handle(
    action: ShieldAction,
    for application: ApplicationToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    switch action {
    case .primaryButtonPressed:
      let unlockCount = defaults?.integer(forKey: "todayUnlockCount") ?? 0
      defaults?.set(unlockCount + 1, forKey: "todayUnlockCount")
      defaults?.set(Date().timeIntervalSince1970, forKey: "sessionStartTimestamp")

      if var apps = store.shield.applications {
        apps.remove(application)
        store.shield.applications = apps.isEmpty ? nil : apps
      }
      completionHandler(.close)

    case .secondaryButtonPressed:
      let declined = defaults?.integer(forKey: "todayDeclinedCount") ?? 0
      defaults?.set(declined + 1, forKey: "todayDeclinedCount")
      completionHandler(.close)

    @unknown default:
      completionHandler(.close)
    }
  }

  override func handle(
    action: ShieldAction,
    for category: ActivityCategoryToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    switch action {
    case .primaryButtonPressed:
      let unlockCount = defaults?.integer(forKey: "todayUnlockCount") ?? 0
      defaults?.set(unlockCount + 1, forKey: "todayUnlockCount")
      defaults?.set(Date().timeIntervalSince1970, forKey: "sessionStartTimestamp")

      store.shield.applicationCategories = nil
      completionHandler(.close)

    case .secondaryButtonPressed:
      let declined = defaults?.integer(forKey: "todayDeclinedCount") ?? 0
      defaults?.set(declined + 1, forKey: "todayDeclinedCount")
      completionHandler(.close)

    @unknown default:
      completionHandler(.close)
    }
  }

  override func handle(
    action: ShieldAction,
    for webDomain: WebDomainToken,
    completionHandler: @escaping (ShieldActionResponse) -> Void
  ) {
    switch action {
    case .primaryButtonPressed:
      let unlockCount = defaults?.integer(forKey: "todayUnlockCount") ?? 0
      defaults?.set(unlockCount + 1, forKey: "todayUnlockCount")

      if var domains = store.shield.webDomains {
        domains.remove(webDomain)
        store.shield.webDomains = domains.isEmpty ? nil : domains
      }
      completionHandler(.close)

    case .secondaryButtonPressed:
      completionHandler(.close)

    @unknown default:
      completionHandler(.close)
    }
  }
}
