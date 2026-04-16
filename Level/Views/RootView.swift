import SwiftData
import SwiftUI

struct RootView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.scenePhase) private var scenePhase
  @EnvironmentObject private var screenTime: ScreenTimeManager
  @EnvironmentObject private var schedule: ScheduleManager
  @Query private var profiles: [UserProfile]
  @Query private var settingsRecords: [AppSettings]

  private var colorScheme: ColorScheme? {
    switch settingsRecords.first?.appearanceMode {
    case "light": .light
    case "dark": .dark
    default: nil
    }
  }

  var body: some View {
    Group {
      if let profile = profiles.first {
        if profile.onboardingComplete {
          MainTabView()
            .onAppear { resumeMonitoring(profile: profile) }
        } else {
          OnboardingFlow(profile: profile)
        }
      } else {
        Color.vintageGrape
          .ignoresSafeArea()
          .task { seedProfile() }
      }
    }
    .preferredColorScheme(colorScheme)
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        screenTime.checkSessionExpiry()
        screenTime.checkFocusSessionExpiry()
      }
    }
    .onAppear {
      screenTime.checkSessionExpiry()
      screenTime.checkFocusSessionExpiry()
    }
  }

  private func seedProfile() {
    guard profiles.isEmpty else { return }
    context.insert(UserProfile())
    try? context.save()
  }

  #if DEBUG
  private func seedProfileCompleted() {
    guard profiles.isEmpty else { return }
    let profile = UserProfile(
      reasons: ["Read more books", "Stop scrolling in bed", "Actually get work done"],
      onboardingComplete: true,
      createdAt: .now
    )
    context.insert(profile)
    try? context.save()
  }
  #endif

  private func resumeMonitoring(profile: UserProfile) {
    screenTime.refreshAuthorizationStatus()
    guard screenTime.isAuthorized else { return }
    screenTime.syncReasonsToDefaults(profile.reasons)
    screenTime.startMonitoring()
  }
}
