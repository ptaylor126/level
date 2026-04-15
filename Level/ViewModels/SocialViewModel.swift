import Foundation
import SwiftData
import SwiftUI

@MainActor
final class SocialViewModel: ObservableObject {
  @Published var momentumScore: Int = 50
  @Published var streak: Int = 0
  @Published var totalXP: Int = 0
  @Published var weekTimeSaved: TimeInterval = 0
  @Published var displayName: String = "You"
  @Published var notifyEmail: String? = nil
  @Published var isNotifySignedUp: Bool = false

  private var engine: MomentumEngine?

  init() {
    if let savedName = SharedStore.defaults.string(forKey: "displayName"), !savedName.isEmpty {
      displayName = savedName
    }
    if let savedEmail = SharedStore.defaults.string(forKey: "notifySignupEmail"), !savedEmail.isEmpty {
      notifyEmail = savedEmail
      isNotifySignedUp = true
    }
  }

  func refresh(context: ModelContext) {
    if engine == nil {
      engine = MomentumEngine(context: context)
    }

    engine?.updateToday()

    if let today = engine?.todayRecord() {
      momentumScore = Int(today.momentumScore)
    }

    streak = engine?.currentStreak() ?? 0
    totalXP = SharedStore.defaults.integer(forKey: "totalXP")

    // Sum screen time saved across the week
    switch BaselineCalculator.resolve(context: context) {
    case .tracking:
      weekTimeSaved = 0
    case .ready(let b):
      let weeklyRecords = engine?.weekRecords() ?? []
      weekTimeSaved = weeklyRecords.reduce(0.0) { acc, record in
        acc + max(0, b - record.totalScreenTime)
      }
    }

    // Re-read display name in case settings changed
    if let savedName = SharedStore.defaults.string(forKey: "displayName"), !savedName.isEmpty {
      displayName = savedName
    }
  }

  func saveNotifyEmail(_ email: String) {
    SharedStore.defaults.set(email, forKey: "notifySignupEmail")
    notifyEmail = email
    isNotifySignedUp = true
  }

  var formattedTimeSaved: String {
    let seconds = Int(weekTimeSaved)
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    if hours > 0 {
      return "\(hours)h \(minutes)m"
    }
    return "\(minutes)m"
  }
}
