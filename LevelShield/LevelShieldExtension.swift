import Foundation
import ManagedSettings
import ManagedSettingsUI
import UIKit

class LevelShieldExtension: ShieldConfigurationDataSource {

  private let defaults = UserDefaults(suiteName: "group.com.paultaylor.level")

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

    let opensToday = defaults?.integer(forKey: "todayOpenAttempts") ?? 0
    defaults?.set(opensToday + 1, forKey: "todayOpenAttempts")
    defaults?.set(Date(), forKey: "lastShieldTimestamp")

    let grape = UIColor(red: 71/255, green: 49/255, blue: 68/255, alpha: 1)
    let cream = UIColor(red: 255/255, green: 248/255, blue: 240/255, alpha: 1)
    let muted = UIColor(red: 107/255, green: 80/255, blue: 104/255, alpha: 1)

    return ShieldConfiguration(
      backgroundBlurStyle: .systemMaterialDark,
      backgroundColor: grape,
      icon: nil,
      title: nil,
      subtitle: nil,
      primaryButtonLabel: ShieldConfiguration.Label(text: "Continue", color: grape),
      primaryButtonBackgroundColor: cream,
      secondaryButtonLabel: ShieldConfiguration.Label(text: "Not now", color: muted)
    )
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
