import SwiftUI
import SwiftData

@main
struct PauseApp: App {
  var body: some Scene {
    WindowGroup {
      HomeView()
        .tint(Color.vintageGrape)
    }
    .modelContainer(DataStore.shared.container)
  }
}
