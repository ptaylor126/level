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
    switch action {
    case .primaryButtonPressed:
      let declined = defaults?.integer(forKey: "todayDeclinedCount") ?? 0
      defaults?.set(declined + 1, forKey: "todayDeclinedCount")
      let xp = defaults?.integer(forKey: "totalXP") ?? 0
      defaults?.set(xp + 10, forKey: "totalXP")
      defaults?.set(10, forKey: "pendingXPGain")
      completionHandler(.close)

    case .secondaryButtonPressed:
      completionHandler(.close)

    @unknown default:
      completionHandler(.close)
    }
  }
}
