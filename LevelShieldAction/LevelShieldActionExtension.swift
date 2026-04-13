import ManagedSettings
import UserNotifications

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
      defaults?.set(Date(), forKey: "pendingCountdownTimestamp")
      sendOpenNotification()
      completionHandler(.close)

    case .secondaryButtonPressed:
      completionHandler(.close)

    @unknown default:
      completionHandler(.close)
    }
  }

  private func sendOpenNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Timer ready"
    content.body = "Tap to start your countdown in Level."
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
    let request = UNNotificationRequest(
      identifier: "open-level-timer",
      content: content,
      trigger: trigger
    )
    UNUserNotificationCenter.current().add(request)
  }
}
