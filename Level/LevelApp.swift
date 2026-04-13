import SwiftData
import SwiftUI

@main
struct LevelApp: App {
  @StateObject private var screenTime = ScreenTimeManager()

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(screenTime)
        .tint(Color.teaGreen)
        .onOpenURL { url in
          if url.scheme == "level" && url.host == "timer" {
            SharedStore.defaults.set(Date(), forKey: "pendingCountdownTimestamp")
          }
        }
    }
    .modelContainer(DataStore.shared.container)
  }
}
