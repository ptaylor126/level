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
    makeConfig()
  }

  override func configuration(
    shielding application: Application,
    in category: ActivityCategory
  ) -> ShieldConfiguration {
    makeConfig()
  }

  override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
    makeConfig()
  }

  override func configuration(
    shielding webDomain: WebDomain,
    in category: ActivityCategory
  ) -> ShieldConfiguration {
    makeConfig()
  }

  private func makeConfig() -> ShieldConfiguration {
    resetIfNewDay()

    let grape = UIColor(red: 71/255, green: 49/255, blue: 68/255, alpha: 1)
    let cream = UIColor(red: 255/255, green: 248/255, blue: 240/255, alpha: 1)
    let appIcon = UIImage(named: "ShieldIcon", in: Bundle(for: LevelShieldExtension.self), compatibleWith: nil)

    // Rest Level: fully blocked, no unlock option
    let currentMode = defaults?.string(forKey: "currentLevelMode") ?? ""
    if currentMode == "rest" {
      return ShieldConfiguration(
        backgroundBlurStyle: .systemMaterialDark,
        backgroundColor: grape,
        icon: appIcon,
        title: ShieldConfiguration.Label(text: "Rest Level is on.", color: cream),
        subtitle: ShieldConfiguration.Label(text: "See you in the morning.", color: cream),
        primaryButtonLabel: ShieldConfiguration.Label(text: "I'm good", color: grape),
        primaryButtonBackgroundColor: cream,
        secondaryButtonLabel: nil
      )
    }

    let reason = nextReason()

    if defaults?.object(forKey: "firstAttemptTimestamp") == nil {
      defaults?.set(Date(), forKey: "firstAttemptTimestamp")
    }
    defaults?.set(Date(), forKey: "lastShieldShownTimestamp")

    let opensToday = defaults?.integer(forKey: "todayOpenAttempts") ?? 0
    defaults?.set(opensToday + 1, forKey: "todayOpenAttempts")

    let unlockCount = defaults?.integer(forKey: "todayUnlockCount") ?? 0
    let unlockLimit = defaults?.integer(forKey: "defaultUnlockLimit").nonZero ?? 10
    let exhausted = unlockCount >= unlockLimit
    let attemptText = "Attempt \(opensToday + 1) today."

    if exhausted {
      return ShieldConfiguration(
        backgroundBlurStyle: .systemMaterialDark,
        backgroundColor: grape,
        icon: appIcon,
        title: ShieldConfiguration.Label(text: "Level with me.", color: cream),
        subtitle: ShieldConfiguration.Label(
          text: "You've used all your opens today.\n\nSee you tomorrow.",
          color: cream
        ),
        primaryButtonLabel: ShieldConfiguration.Label(text: "Not now", color: grape),
        primaryButtonBackgroundColor: cream,
        secondaryButtonLabel: nil
      )
    }

    let subtitle = "\nRemember:\n\u{25B8} \(reason)\n\n\(attemptText)"
    let muted = UIColor(red: 107/255, green: 80/255, blue: 104/255, alpha: 1)

    return ShieldConfiguration(
      backgroundBlurStyle: .systemMaterialDark,
      backgroundColor: grape,
      icon: appIcon,
      title: ShieldConfiguration.Label(text: "Level with me.", color: cream),
      subtitle: ShieldConfiguration.Label(text: subtitle, color: cream),
      primaryButtonLabel: ShieldConfiguration.Label(text: "OK, I'll do that", color: grape),
      primaryButtonBackgroundColor: cream,
      secondaryButtonLabel: ShieldConfiguration.Label(text: "Actually, I'm good", color: muted)
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
    defaults?.removeObject(forKey: "firstAttemptTimestamp")
    defaults?.removeObject(forKey: "lastShieldShownTimestamp")
    defaults?.removeObject(forKey: "reasonPlaylist")
    defaults?.set(false, forKey: "triggerPromptShownThisSession")
    defaults?.set(Date(), forKey: "lastDayReset")
  }
}

private extension Int {
  var nonZero: Int? { self == 0 ? nil : self }
}
