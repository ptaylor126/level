import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings
import SwiftUI

extension FamilyActivitySelection {
  var isEmptyTokens: Bool {
    applicationTokens.isEmpty && categoryTokens.isEmpty && webDomainTokens.isEmpty
  }
}

@MainActor
final class ScreenTimeManager: ObservableObject {
  @Published var selection: FamilyActivitySelection
  @Published var authorizationStatus: AuthorizationStatus
  @Published var focusSessionActive = false
  @Published var focusSessionEndDate: Date?

  private let center = AuthorizationCenter.shared
  private let activityCenter = DeviceActivityCenter()
  private let store = ManagedSettingsStore(named: .init("LevelMain"))

  init() {
    self.selection = Self.loadStoredSelection() ?? FamilyActivitySelection()
    self.authorizationStatus = center.authorizationStatus
    self.focusSessionActive = SharedStore.defaults.bool(forKey: "focusSessionActive")
    self.focusSessionEndDate = SharedStore.defaults.object(forKey: "focusSessionEndTimestamp") as? Date
  }

  var isAuthorized: Bool {
    authorizationStatus == .approved
  }

  func refreshAuthorizationStatus() {
    authorizationStatus = center.authorizationStatus
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

  static func loadStoredSelection() -> FamilyActivitySelection? {
    guard let data = SharedStore.defaults.data(forKey: SharedStore.Key.familyActivitySelection)
    else { return nil }
    return try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
  }

  // MARK: - Sync shared state for extensions

  func syncReasonsToDefaults(_ reasons: [String]) {
    SharedStore.defaults.set(reasons, forKey: "userReasons")
  }

  func syncSettingsToDefaults(delay: Int, increment: Int, unlockLimit: Int, dailyAllowanceMinutes: Int) {
    SharedStore.defaults.set(delay, forKey: "defaultDelaySeconds")
    SharedStore.defaults.set(increment, forKey: "delayIncrementSeconds")
    SharedStore.defaults.set(unlockLimit, forKey: "defaultUnlockLimit")
    SharedStore.defaults.set(dailyAllowanceMinutes, forKey: "dailyAllowanceMinutes")
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
    persistSelection()

    let effective: FamilyActivitySelection = {
      if let stored = Self.loadStoredSelection(), !stored.isEmptyTokens {
        return stored
      }
      return selection
    }()

    store.shield.applications = effective.applicationTokens.isEmpty
      ? nil : effective.applicationTokens
    store.shield.applicationCategories = effective.categoryTokens.isEmpty
      ? nil : .specific(effective.categoryTokens)
    store.shield.webDomains = effective.webDomainTokens.isEmpty
      ? nil : effective.webDomainTokens

    logShieldState(label: "applyShields", written: effective)
  }

  func logShieldState(label: String, written: FamilyActivitySelection? = nil) {
    let storedData = SharedStore.defaults.data(forKey: SharedStore.Key.familyActivitySelection)
    let readBackApps = store.shield.applications
    let readBackWeb = store.shield.webDomains
    let categoriesReadBackDescription: String = {
      switch store.shield.applicationCategories {
      case .some(.all): return "all"
      case .some(.specific(let set, except: _)): return "specific(\(set.count))"
      case .none: return "nil"
      @unknown default: return "unknown"
      }
    }()
    let appGroupReachable = SharedStore.defaults.dictionaryRepresentation().keys.contains(SharedStore.Key.familyActivitySelection)

    print("[Level][diag] \(label):")
    print("  auth.rawValue=\(authorizationStatus.rawValue) isAuthorized=\(isAuthorized)")
    print("  selection(mem) apps=\(selection.applicationTokens.count) cats=\(selection.categoryTokens.count) web=\(selection.webDomainTokens.count)")
    if let written {
      print("  selection(effective) apps=\(written.applicationTokens.count) cats=\(written.categoryTokens.count) web=\(written.webDomainTokens.count)")
    }
    print("  sharedDefaults.suiteReachable=\(appGroupReachable) bytes=\(storedData?.count ?? -1)")
    print("  store(name=LevelMain) readback apps=\(readBackApps?.count ?? -1) cats=\(categoriesReadBackDescription) web=\(readBackWeb?.count ?? -1)")
  }

  func clearShields() {
    store.shield.applications = nil
    store.shield.applicationCategories = nil
    store.shield.webDomains = nil
  }

  // MARK: - Session expiry (unlock sessions from shield)

  func checkSessionExpiry() {
    guard let start = SharedStore.defaults.object(forKey: "sessionStartTimestamp") as? Date else { return }
    let sessionSeconds = SharedStore.defaults.integer(forKey: "sessionLengthSeconds")
    let duration = sessionSeconds > 0 ? TimeInterval(sessionSeconds) : 300
    if Date().timeIntervalSince(start) >= duration {
      SharedStore.defaults.removeObject(forKey: "sessionStartTimestamp")
      applyShields()
    }
  }

  // MARK: - Focus session

  func startFocusSession(durationMinutes: Int) {
    let endDate = Date().addingTimeInterval(TimeInterval(durationMinutes * 60))
    SharedStore.defaults.set(true, forKey: "focusSessionActive")
    SharedStore.defaults.set(Date(), forKey: "focusSessionStartTimestamp")
    SharedStore.defaults.set(endDate, forKey: "focusSessionEndTimestamp")
    SharedStore.defaults.set(durationMinutes * 60, forKey: "focusSessionDurationSeconds")
    focusSessionActive = true
    focusSessionEndDate = endDate
    applyShields()
  }

  func endFocusSession(completed: Bool) {
    let startTimestamp = SharedStore.defaults.object(forKey: "focusSessionStartTimestamp") as? Date
    let elapsed = startTimestamp.map { Date().timeIntervalSince($0) } ?? 0

    SharedStore.defaults.set(false, forKey: "focusSessionActive")
    SharedStore.defaults.removeObject(forKey: "focusSessionEndTimestamp")
    SharedStore.defaults.removeObject(forKey: "focusSessionStartTimestamp")
    SharedStore.defaults.removeObject(forKey: "focusSessionDurationSeconds")
    focusSessionActive = false
    focusSessionEndDate = nil

    if completed {
      let minutes = Int(elapsed / 60)
      let xp = SharedStore.defaults.integer(forKey: "totalXP")
      SharedStore.defaults.set(xp + minutes, forKey: "totalXP")
    } else {
      let xp = SharedStore.defaults.integer(forKey: "totalXP")
      SharedStore.defaults.set(max(0, xp - 20), forKey: "totalXP")
    }

    let previousFocus = SharedStore.defaults.double(forKey: "todayFocusSessionSeconds")
    SharedStore.defaults.set(previousFocus + elapsed, forKey: "todayFocusSessionSeconds")
  }

  func checkFocusSessionExpiry() {
    guard focusSessionActive,
          let endDate = SharedStore.defaults.object(forKey: "focusSessionEndTimestamp") as? Date,
          endDate <= Date() else { return }
    endFocusSession(completed: true)
  }

  var focusSessionTimeRemaining: TimeInterval? {
    guard focusSessionActive, let endDate = focusSessionEndDate else { return nil }
    let remaining = endDate.timeIntervalSince(Date())
    return remaining > 0 ? remaining : nil
  }
}
