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
    let reasons = defaults?.stringArray(forKey: "userReasons") ?? []
    let reason = reasons.randomElement() ?? "Do you actually need to open this?"

    let delaySeconds = defaults?.integer(forKey: "defaultDelaySeconds").nonZero ?? 10
    let lastShown = defaults?.object(forKey: "lastShieldTimestamp") as? Date
    let elapsed = lastShown.map { Date().timeIntervalSince($0) } ?? 0

    defaults?.set(Date(), forKey: "lastShieldTimestamp")

    let unlockCount = defaults?.integer(forKey: "todayUnlockCount") ?? 0
    let unlockLimit = defaults?.integer(forKey: "defaultUnlockLimit").nonZero ?? 10
    let exhausted = unlockCount >= unlockLimit

    let grape = UIColor(red: 71/255, green: 49/255, blue: 68/255, alpha: 1)
    let cream = UIColor(red: 255/255, green: 248/255, blue: 240/255, alpha: 1)
    let green = UIColor(red: 221/255, green: 244/255, blue: 201/255, alpha: 1)

    let subtitle: String
    let secondary: ShieldConfiguration.Label?

    if exhausted {
      subtitle = "You've used all your opens today.\nCome back tomorrow."
      secondary = nil
    } else if elapsed >= Double(delaySeconds) && lastShown != nil {
      subtitle = reason
      secondary = ShieldConfiguration.Label(text: "Open anyway", color: cream)
    } else {
      subtitle = reason
      secondary = nil
    }

    return ShieldConfiguration(
      backgroundBlurStyle: nil,
      backgroundColor: grape,
      icon: nil,
      title: ShieldConfiguration.Label(text: "Level", color: green),
      subtitle: ShieldConfiguration.Label(text: subtitle, color: cream),
      primaryButtonLabel: ShieldConfiguration.Label(text: "Not now", color: grape),
      primaryButtonBackgroundColor: cream,
      secondaryButtonLabel: secondary
    )
  }
}

private extension Int {
  var nonZero: Int? { self == 0 ? nil : self }
}
