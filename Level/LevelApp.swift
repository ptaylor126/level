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
        .task {
          schedule.configure(screenTime: screenTime)
        }
    }
    .modelContainer(DataStore.shared.container)
  }
}
