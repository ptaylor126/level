import SwiftData
import SwiftUI

@main
struct LevelApp: App {
  @StateObject private var screenTime = ScreenTimeManager()
  @StateObject private var schedule = ScheduleManager()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(screenTime)
        .environmentObject(schedule)
        .tint(Color.teaGreen)
        .onOpenURL { url in
          if url.scheme == "level" && url.host == "timer" {
            SharedStore.defaults.set(Date(), forKey: "pendingCountdownTimestamp")
          }
        }
        .task {
          schedule.configure(screenTime: screenTime)
        }
    }
    .modelContainer(DataStore.shared.container)
  }
}
