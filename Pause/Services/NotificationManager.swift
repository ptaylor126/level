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
    content.title = "Your week in review"
    content.body = "See how you did this week."
    content.sound = .default

    var components = DateComponents()
    components.weekday = 1
    components.hour = 19
    components.minute = 0

    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    let request = UNNotificationRequest(identifier: "weekly-recap", content: content, trigger: trigger)
    center.add(request)
  }

  private func scheduleMorningSummary() {
    let content = UNMutableNotificationContent()
    content.title = "Yesterday's screen time"
    content.body = "Check how you did."
    content.sound = .default

    var components = DateComponents()
    components.hour = 9
    components.minute = 0

    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    let request = UNNotificationRequest(identifier: "morning-summary", content: content, trigger: trigger)
    center.add(request)
  }

  private func scheduleStreakAtRisk() {
    let content = UNMutableNotificationContent()
    content.title = "Today's looking close"
    content.body = "You've still got time to keep the streak going."
    content.sound = .default

    var components = DateComponents()
    components.hour = 20
    components.minute = 0

    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
    let request = UNNotificationRequest(identifier: "streak-at-risk", content: content, trigger: trigger)
    center.add(request)
  }
}
