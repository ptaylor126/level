import DeviceActivity
import Foundation
import ManagedSettings

final class PauseMonitorExtension: DeviceActivityMonitor {
  let store = ManagedSettingsStore(named: .init("PauseMain"))

  override func intervalDidStart(for activity: DeviceActivityName) {
    super.intervalDidStart(for: activity)
  }

  override func intervalDidEnd(for activity: DeviceActivityName) {
    super.intervalDidEnd(for: activity)
  }

  override func eventDidReachThreshold(
    _ event: DeviceActivityEvent.Name,
    activity: DeviceActivityName
  ) {
    super.eventDidReachThreshold(event, activity: activity)
  }
}
