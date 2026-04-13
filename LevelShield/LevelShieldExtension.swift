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

    let reasons = defaults?.stringArray(forKey: "userReasons") ?? []
    let lastReasonIndex = defaults?.integer(forKey: "lastReasonIndex") ?? -1
    let reason = pickReason(from: reasons, avoiding: lastReasonIndex)

    let baseDelay = defaults?.integer(forKey: "defaultDelaySeconds").nonZero ?? 10
    let increment = defaults?.integer(forKey: "delayIncrementSeconds").nonZero ?? 10
    let opensToday = defaults?.integer(forKey: "todayOpenAttempts") ?? 0
    let delay = baseDelay + (increment * opensToday)

    let lastShown = defaults?.object(forKey: "lastShieldTimestamp") as? Date
    let elapsed = lastShown.map { Date().timeIntervalSince($0) } ?? 0
    let delayMet = elapsed >= Double(delay) && lastShown != nil

    defaults?.set(Date(), forKey: "lastShieldTimestamp")
    defaults?.set(opensToday + 1, forKey: "todayOpenAttempts")

    let declinedCount = defaults?.integer(forKey: "todayDeclinedCount") ?? 0
    defaults?.set(declinedCount + 1, forKey: "todayDeclinedCount")

    let unlockCount = defaults?.integer(forKey: "todayUnlockCount") ?? 0
    let unlockLimit = defaults?.integer(forKey: "defaultUnlockLimit").nonZero ?? 10
    let exhausted = unlockCount >= unlockLimit

    if delayMet && !exhausted {
      defaults?.set(unlockCount + 1, forKey: "todayUnlockCount")
    }

    let grape = UIColor(red: 71/255, green: 49/255, blue: 68/255, alpha: 1)
    let cream = UIColor(red: 255/255, green: 248/255, blue: 240/255, alpha: 1)
    let green = UIColor(red: 221/255, green: 244/255, blue: 201/255, alpha: 1)
    let muted = UIColor(red: 107/255, green: 80/255, blue: 104/255, alpha: 1)

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

    if delayMet {
      return ShieldConfiguration(
        backgroundBlurStyle: nil,
        backgroundColor: grape,
        icon: nil,
        title: ShieldConfiguration.Label(text: "Level", color: green),
        subtitle: ShieldConfiguration.Label(text: reason, color: cream),
        primaryButtonLabel: ShieldConfiguration.Label(text: "Not now", color: grape),
        primaryButtonBackgroundColor: cream,
        secondaryButtonLabel: ShieldConfiguration.Label(text: "Open anyway", color: muted)
      )
    }

    let waitSeconds = delay - Int(elapsed)
    let waitText = waitSeconds > 60
      ? "Wait \(waitSeconds / 60)m \(waitSeconds % 60)s"
      : "Wait \(max(waitSeconds, 1))s"

    return ShieldConfiguration(
      backgroundBlurStyle: nil,
      backgroundColor: grape,
      icon: nil,
      title: ShieldConfiguration.Label(text: "Level", color: green),
      subtitle: ShieldConfiguration.Label(
        text: "\(reason)\n\n\(waitText) before you can open this.",
        color: cream
      ),
      primaryButtonLabel: ShieldConfiguration.Label(text: "Not now", color: grape),
      primaryButtonBackgroundColor: cream,
      secondaryButtonLabel: nil
    )
  }

  private func pickReason(from reasons: [String], avoiding lastIndex: Int) -> String {
    guard !reasons.isEmpty else { return "Do you actually need to open this?" }
    if reasons.count == 1 {
      defaults?.set(0, forKey: "lastReasonIndex")
      return reasons[0]
    }
    var index = Int.random(in: 0..<reasons.count)
    if index == lastIndex {
      index = (index + 1) % reasons.count
    }
    defaults?.set(index, forKey: "lastReasonIndex")
    return reasons[index]
  }

  private func resetIfNewDay() {
    let lastReset = defaults?.object(forKey: "lastDayReset") as? Date
    let calendar = Calendar.current
    if let lastReset, calendar.isDateInToday(lastReset) { return }
    defaults?.set(0, forKey: "todayOpenAttempts")
    defaults?.set(0, forKey: "todayUnlockCount")
    defaults?.set(0, forKey: "todayDeclinedCount")
    defaults?.removeObject(forKey: "lastShieldTimestamp")
    defaults?.set(Date(), forKey: "lastDayReset")
  }
}

private extension Int {
  var nonZero: Int? { self == 0 ? nil : self }
}
