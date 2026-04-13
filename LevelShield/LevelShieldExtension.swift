import Foundation
import ManagedSettings
import ManagedSettingsUI
import UIKit

class LevelShieldExtension: ShieldConfigurationDataSource {

  private let defaults = UserDefaults(suiteName: "group.com.paultaylor.level")

  private static let fallbackReasons = [
    "Do you actually need to open this?",
    "You've got better things to do.",
    "Is this worth your time right now?",
    "What were you about to do before this?"
  ]

  override func configuration(shielding application: Application) -> ShieldConfiguration {
    makeConfig(appName: application.localizedDisplayName)
  }

  override func configuration(
    shielding application: Application,
    in category: ActivityCategory
  ) -> ShieldConfiguration {
    makeConfig(appName: application.localizedDisplayName)
  }

  override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
    makeConfig(appName: nil)
  }

  override func configuration(
    shielding webDomain: WebDomain,
    in category: ActivityCategory
  ) -> ShieldConfiguration {
    makeConfig(appName: nil)
  }

  private func makeConfig(appName: String?) -> ShieldConfiguration {
    resetIfNewDay()

    let reason = nextReason()

    let baseDelay = defaults?.integer(forKey: "defaultDelaySeconds").nonZero ?? 10
    let increment = defaults?.integer(forKey: "delayIncrementSeconds").nonZero ?? 10
    let opensToday = defaults?.integer(forKey: "todayOpenAttempts") ?? 0
    let delay = baseDelay + (increment * opensToday)

    let lastShown = defaults?.object(forKey: "lastShieldTimestamp") as? Date
    let elapsed = lastShown.map { Date().timeIntervalSince($0) } ?? 0
    let delayMet = elapsed >= Double(delay) && lastShown != nil

    defaults?.set(opensToday + 1, forKey: "todayOpenAttempts")
    defaults?.set(Date(), forKey: "lastShieldTimestamp")

    let unlockCount = defaults?.integer(forKey: "todayUnlockCount") ?? 0
    let unlockLimit = defaults?.integer(forKey: "defaultUnlockLimit").nonZero ?? 10
    let exhausted = unlockCount >= unlockLimit
    let opensText = "\(unlockCount) of \(unlockLimit) opens today"

    let grape = UIColor(red: 71/255, green: 49/255, blue: 68/255, alpha: 1)
    let cream = UIColor(red: 255/255, green: 248/255, blue: 240/255, alpha: 1)
    let muted = UIColor(red: 107/255, green: 80/255, blue: 104/255, alpha: 1)

    let appIcon = UIImage(named: "shield-icon", in: Bundle(for: LevelShieldExtension.self), compatibleWith: nil)

    let title: String
    if let name = appName, !name.isEmpty {
      title = "Open \(name)?"
    } else {
      title = "Need this right now?"
    }

    if exhausted {
      return ShieldConfiguration(
        backgroundBlurStyle: .systemMaterialDark,
        backgroundColor: grape,
        icon: appIcon,
        title: ShieldConfiguration.Label(text: title, color: cream),
        subtitle: ShieldConfiguration.Label(
          text: "You've used all your opens today.\n\n\(opensText)",
          color: cream
        ),
        primaryButtonLabel: ShieldConfiguration.Label(text: "Not now", color: grape),
        primaryButtonBackgroundColor: cream,
        secondaryButtonLabel: nil
      )
    }

    if delayMet {
      return ShieldConfiguration(
        backgroundBlurStyle: .systemMaterialDark,
        backgroundColor: grape,
        icon: appIcon,
        title: ShieldConfiguration.Label(text: title, color: cream),
        subtitle: ShieldConfiguration.Label(
          text: "\u{25B8} \(reason)\n\n\(opensText)",
          color: cream
        ),
        primaryButtonLabel: ShieldConfiguration.Label(text: "Not now", color: grape),
        primaryButtonBackgroundColor: cream,
        secondaryButtonLabel: ShieldConfiguration.Label(text: "Open anyway", color: muted)
      )
    }

    let waitSeconds = max(delay - Int(elapsed), 1)
    let waitText = waitSeconds > 60
      ? "\(waitSeconds / 60)m \(waitSeconds % 60)s"
      : "\(waitSeconds)s"

    return ShieldConfiguration(
      backgroundBlurStyle: .systemMaterialDark,
      backgroundColor: grape,
      icon: appIcon,
      title: ShieldConfiguration.Label(text: title, color: cream),
      subtitle: ShieldConfiguration.Label(
        text: "\u{25B8} \(reason)\n\nWait \(waitText), then try again.\n\(opensText)",
        color: cream
      ),
      primaryButtonLabel: ShieldConfiguration.Label(text: "Not now", color: grape),
      primaryButtonBackgroundColor: cream,
      secondaryButtonLabel: nil
    )
  }

  private func nextReason() -> String {
    let userReasons = defaults?.stringArray(forKey: "userReasons") ?? []
    let reasons = userReasons.isEmpty ? Self.fallbackReasons : userReasons

    var playlist = defaults?.array(forKey: "reasonPlaylist") as? [Int] ?? []
    if playlist.isEmpty {
      playlist = Array(0..<reasons.count).shuffled()
      defaults?.set(playlist, forKey: "reasonPlaylist")
    }

    let index = playlist.removeFirst()
    defaults?.set(playlist, forKey: "reasonPlaylist")
    return index < reasons.count ? reasons[index] : (reasons.first ?? Self.fallbackReasons[0])
  }

  private func resetIfNewDay() {
    let lastReset = defaults?.object(forKey: "lastDayReset") as? Date
    if let lastReset, Calendar.current.isDateInToday(lastReset) { return }
    defaults?.set(0, forKey: "todayOpenAttempts")
    defaults?.set(0, forKey: "todayUnlockCount")
    defaults?.set(0, forKey: "todayDeclinedCount")
    defaults?.removeObject(forKey: "lastShieldTimestamp")
    defaults?.removeObject(forKey: "reasonPlaylist")
    defaults?.set(false, forKey: "triggerPromptShownThisSession")
    defaults?.set(Date(), forKey: "lastDayReset")
  }
}

private extension Int {
  var nonZero: Int? { self == 0 ? nil : self }
}
