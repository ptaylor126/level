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

    let reason = nextReason()

    let opensToday = defaults?.integer(forKey: "todayOpenAttempts") ?? 0
    defaults?.set(opensToday + 1, forKey: "todayOpenAttempts")
    defaults?.set(Date(), forKey: "lastShieldTimestamp")

    let declinedCount = defaults?.integer(forKey: "todayDeclinedCount") ?? 0
    defaults?.set(declinedCount + 1, forKey: "todayDeclinedCount")

    let unlockCount = defaults?.integer(forKey: "todayUnlockCount") ?? 0
    let unlockLimit = defaults?.integer(forKey: "defaultUnlockLimit").nonZero ?? 10
    let exhausted = unlockCount >= unlockLimit

    let grape = UIColor(red: 71/255, green: 49/255, blue: 68/255, alpha: 1)
    let cream = UIColor(red: 255/255, green: 248/255, blue: 240/255, alpha: 1)
    let green = UIColor(red: 221/255, green: 244/255, blue: 201/255, alpha: 1)

    if exhausted {
      return ShieldConfiguration(
        backgroundBlurStyle: nil,
        backgroundColor: grape,
        icon: nil,
        title: ShieldConfiguration.Label(text: "Level", color: green),
        subtitle: ShieldConfiguration.Label(
          text: "You've used all your opens today.\nSee you tomorrow.",
          color: cream
        ),
        primaryButtonLabel: ShieldConfiguration.Label(text: "Got it", color: grape),
        primaryButtonBackgroundColor: cream,
        secondaryButtonLabel: nil
      )
    }

    return ShieldConfiguration(
      backgroundBlurStyle: nil,
      backgroundColor: grape,
      icon: nil,
      title: ShieldConfiguration.Label(text: "Level", color: green),
      subtitle: ShieldConfiguration.Label(
        text: "\(reason)\n\nOpen Level to start your timer.",
        color: cream
      ),
      primaryButtonLabel: ShieldConfiguration.Label(text: "Open Level", color: grape),
      primaryButtonBackgroundColor: cream,
      secondaryButtonLabel: ShieldConfiguration.Label(
        text: "Not now",
        color: UIColor(red: 107/255, green: 80/255, blue: 104/255, alpha: 1)
      )
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

    if index < reasons.count {
      return reasons[index]
    }
    return reasons.first ?? Self.fallbackReasons[0]
  }

  private func resetIfNewDay() {
    let lastReset = defaults?.object(forKey: "lastDayReset") as? Date
    let calendar = Calendar.current
    if let lastReset, calendar.isDateInToday(lastReset) { return }
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
