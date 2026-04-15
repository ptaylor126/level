import FamilyControls
import Foundation
import SwiftData
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
  @Published var reasons: [String] = []
  @Published var defaultDelay: Int = 10
  @Published var delayIncrement: Int = 10
  @Published var unlockLimit: Int = 10
  @Published var dailyAllowanceMinutes: Int = 30
  @Published var notifyWeeklyRecap: Bool = true
  @Published var notifyMorningSummary: Bool = false
  @Published var notifyStreakAtRisk: Bool = false
  @Published var appearanceMode: String = "system"

  private var profile: UserProfile?
  private var appSettings: AppSettings?

  func load(context: ModelContext) {
    if let p = try? context.fetch(FetchDescriptor<UserProfile>()).first {
      profile = p
      reasons = p.reasons
    }
    if let s = try? context.fetch(FetchDescriptor<AppSettings>()).first {
      appSettings = s
      defaultDelay = s.defaultDelaySeconds
      delayIncrement = s.delayIncrementSeconds
      unlockLimit = s.defaultUnlockLimit
      dailyAllowanceMinutes = s.dailyAllowanceMinutes
      notifyWeeklyRecap = s.notifyWeeklyRecap
      notifyMorningSummary = s.notifyMorningSummary
      notifyStreakAtRisk = s.notifyStreakAtRisk
      appearanceMode = s.appearanceMode
    } else {
      let settings = AppSettings()
      context.insert(settings)
      appSettings = settings
      try? context.save()
    }
  }

  func save(context: ModelContext) {
    profile?.reasons = reasons.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    appSettings?.defaultDelaySeconds = defaultDelay
    appSettings?.delayIncrementSeconds = delayIncrement
    appSettings?.defaultUnlockLimit = unlockLimit
    appSettings?.dailyAllowanceMinutes = dailyAllowanceMinutes
    appSettings?.notifyWeeklyRecap = notifyWeeklyRecap
    appSettings?.notifyMorningSummary = notifyMorningSummary
    appSettings?.notifyStreakAtRisk = notifyStreakAtRisk
    appSettings?.appearanceMode = appearanceMode

    try? context.save()

    SharedStore.defaults.set(reasons, forKey: "userReasons")
    SharedStore.defaults.set(defaultDelay, forKey: "defaultDelaySeconds")
    SharedStore.defaults.set(delayIncrement, forKey: "delayIncrementSeconds")
    SharedStore.defaults.set(unlockLimit, forKey: "defaultUnlockLimit")
    SharedStore.defaults.set(dailyAllowanceMinutes, forKey: "dailyAllowanceMinutes")

    if let settings = appSettings {
      NotificationManager.shared.scheduleAll(settings: settings)
    }
  }

  func addReason() {
    reasons.append("")
  }

  func removeReason(at index: Int) {
    guard reasons.count > 1, reasons.indices.contains(index) else { return }
    reasons.remove(at: index)
  }
}
