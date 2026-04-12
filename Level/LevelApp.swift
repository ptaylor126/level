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
    }
    .modelContainer(DataStore.shared.container)
  }
}
