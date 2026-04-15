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

  func refreshAuthorizationStatus() {
    authorizationStatus = center.authorizationStatus
    #if DEBUG
    print("[Level] refreshAuth status=\(authorizationStatus.rawValue)")
    #endif
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
