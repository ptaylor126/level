import Foundation
import UserNotifications

final class NotificationManager {
  static let shared = NotificationManager()

  private let center = UNUserNotificationCenter.current()

  private init() {}

  func requestPermission() async -> Bool {
    do {
      return try await center.requestAuthorization(options: [.alert, .sound, .badge])
    } catch {
      return false
    }
  }

  func scheduleAll(settings: AppSettings) {
    center.removeAllPendingNotificationRequests()

    if settings.notifyWeeklyRecap {
      scheduleWeeklyRecap()
    }
    if settings.notifyMorningSummary {
      scheduleMorningSummary()
    }
    if settings.notifyStreakAtRisk {
      scheduleStreakAtRisk()
    }
  }

  func cancelAll() {
    center.removeAllPendingNotificationRequests()
  }

  private func scheduleWeeklyRecap() {
    let content = UNMutableNotificationContent()
    content.title = "Your week"
    content.body = "See how you did. Might be good news."
    content.sound = .default

    var components = DateComponents()
    components.weekday = 1
    components.hour = 19

    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    let request = UNNotificationRequest(identifier: "weekly-recap", content: content, trigger: trigger)
    center.add(request)
  }

  private func scheduleMorningSummary() {
    let content = UNMutableNotificationContent()
    content.title = "Yesterday"
    content.body = "Here's how your screen time looked."
    content.sound = .default

    var components = DateComponents()
    components.hour = 9

    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    let request = UNNotificationRequest(identifier: "morning-summary", content: content, trigger: trigger)
    center.add(request)
  }

  private func scheduleStreakAtRisk() {
    let content = UNMutableNotificationContent()
    content.title = "Heads up"
    content.body = "Today's looking close. You've still got time."
    content.sound = .default

    var components = DateComponents()
    components.hour = 20

    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    let request = UNNotificationRequest(identifier: "streak-at-risk", content: content, trigger: trigger)
    center.add(request)
  }
}
