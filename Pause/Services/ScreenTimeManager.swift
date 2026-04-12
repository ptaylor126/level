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
  private let store = ManagedSettingsStore(named: .init("PauseMain"))

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
    let activity = DeviceActivityName("PauseDaily")
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
}
