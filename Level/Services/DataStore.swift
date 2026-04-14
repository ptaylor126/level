import Foundation
import SwiftData

final class DataStore {
  static let shared = DataStore()

  let container: ModelContainer

  private init() {
    let schema = Schema([
      UserProfile.self,
      DailyRecord.self,
      TriggerLog.self,
      AppSettings.self,
      ScheduleBlock.self
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    do {
      self.container = try ModelContainer(for: schema, configurations: [config])
    } catch {
      fatalError("Failed to create ModelContainer: \(error)")
    }
  }
}
