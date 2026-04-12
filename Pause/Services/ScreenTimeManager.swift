import FamilyControls
import Foundation
import ManagedSettings
import SwiftUI

@MainActor
final class ScreenTimeManager: ObservableObject {
  @Published var selection: FamilyActivitySelection
  @Published var authorizationStatus: AuthorizationStatus

  private let center = AuthorizationCenter.shared

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

  func requestAuthorization() async -> Bool {
    do {
      try await center.requestAuthorization(for: .individual)
    } catch {
      // Authorization denied or errored; fall through to read current state.
    }
    authorizationStatus = center.authorizationStatus
    return isAuthorized
  }

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
}
