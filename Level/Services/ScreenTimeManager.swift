import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings
import SwiftUI

@MainActor
final class ScreenTimeManager: ObservableObject {
  @Published var selection: FamilyActivitySelection
  @Published var authorizationStatus: AuthorizationStatus

  private let center = AuthorizationCenter.shared
  private let activityCenter = DeviceActivityCenter()
  private let store = ManagedSettingsStore(named: .init("LevelMain"))

  init() {
    self.selection = Self.loadStoredSelection() ?? FamilyActivitySelection()
    self.authorizationStatus = center.authorizationStatus
  }

  var isAuthorized: Bool {
    authorizationStatus == .approved
  }

  var selectedItemCount: Int {
    selection.applicationTokens.count
      + selection.categoryTokens.count
      + selection.webDomainTokens.count
  }

  // MARK: - Authorization

  func requestAuthorization() async -> Bool {
    do {
      try await center.requestAuthorization(for: .individual)
    } catch {}
    authorizationStatus = center.authorizationStatus
    return isAuthorized
  }

  // MARK: - Selection persistence

  func persistSelection() {
    guard let data = try? JSONEncoder().encode(selection) else { return }
    SharedStore.defaults.set(data, forKey: SharedStore.Key.familyActivitySelection)
  }

  func clearSelection() {
    selection = FamilyActivitySelection()
    SharedStore.defaults.removeObject(forKey: SharedStore.Key.familyActivitySelection)
  }

  private static func loadStoredSelection() -> FamilyActivitySelection? {
    guard let data = SharedStore.defaults.data(forKey: SharedStore.Key.familyActivitySelection)
    else { return nil }
    return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
  }

  // MARK: - Sync shared state for extensions

  func syncReasonsToDefaults(_ reasons: [String]) {
    SharedStore.defaults.set(reasons, forKey: "userReasons")
  }

  func syncSettingsToDefaults(delay: Int, increment: Int, unlockLimit: Int) {
    SharedStore.defaults.set(delay, forKey: "defaultDelaySeconds")
    SharedStore.defaults.set(increment, forKey: "delayIncrementSeconds")
    SharedStore.defaults.set(unlockLimit, forKey: "defaultUnlockLimit")
  }

  // MARK: - Monitoring

  func startMonitoring() {
    let schedule = DeviceActivitySchedule(
      intervalStart: DateComponents(hour: 0, minute: 0),
      intervalEnd: DateComponents(hour: 23, minute: 59),
      repeats: true
    )
    let activity = DeviceActivityName("LevelDaily")
    do {
      try activityCenter.startMonitoring(activity, during: schedule)
    } catch {}
    applyShields()
  }

  func stopMonitoring() {
    activityCenter.stopMonitoring()
    clearShields()
  }

  // MARK: - Shield management

  func applyShields() {
    store.shield.applications = selection.applicationTokens.isEmpty
      ? nil : selection.applicationTokens
    store.shield.applicationCategories = selection.categoryTokens.isEmpty
      ? nil : .specific(selection.categoryTokens)
    store.shield.webDomains = selection.webDomainTokens.isEmpty
      ? nil : selection.webDomainTokens
  }

  func clearShields() {
    store.shield.applications = nil
    store.shield.applicationCategories = nil
    store.shield.webDomains = nil
  }

  // MARK: - Session timer

  private var sessionTimer: Timer?

  func startSession() {
    let unlockCount = SharedStore.defaults.integer(forKey: "todayUnlockCount")
    SharedStore.defaults.set(unlockCount + 1, forKey: "todayUnlockCount")

    clearShields()

    let sessionSeconds = SharedStore.defaults.integer(forKey: "sessionLengthSeconds")
    let duration = sessionSeconds > 0 ? TimeInterval(sessionSeconds) : 300

    sessionTimer?.invalidate()
    sessionTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
      Task { @MainActor in
        self?.applyShields()
      }
    }
  }

  func cancelSession() {
    sessionTimer?.invalidate()
    sessionTimer = nil
    applyShields()
  }

  // MARK: - Pending countdown

  var hasPendingCountdown: Bool {
    guard let timestamp = SharedStore.defaults.object(forKey: "lastShieldTimestamp") as? Date else {
      return false
    }
    return Date().timeIntervalSince(timestamp) < 30
  }

  func pendingCountdownSeconds() -> Int {
    let baseDelay = SharedStore.defaults.integer(forKey: "defaultDelaySeconds")
    let increment = SharedStore.defaults.integer(forKey: "delayIncrementSeconds")
    let opens = SharedStore.defaults.integer(forKey: "todayOpenAttempts")
    let base = baseDelay > 0 ? baseDelay : 10
    let inc = increment > 0 ? increment : 10
    return base + (inc * max(0, opens - 1))
  }

  func currentReason() -> String {
    let reasons = SharedStore.defaults.stringArray(forKey: "userReasons") ?? []
    if reasons.isEmpty {
      return ["Do you actually need to open this?",
              "You've got better things to do.",
              "Is this worth your time right now?",
              "What were you about to do before this?"].randomElement()!
    }
    return reasons.randomElement()!
  }

  func clearPendingCountdown() {
    SharedStore.defaults.removeObject(forKey: "lastShieldTimestamp")
  }
}
