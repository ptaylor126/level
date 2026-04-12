import SwiftData
import SwiftUI

struct RootView: View {
  @Environment(\.modelContext) private var context
  @EnvironmentObject private var screenTime: ScreenTimeManager
  @Query private var profiles: [UserProfile]

  var body: some View {
    Group {
      if let profile = profiles.first {
        if profile.onboardingComplete {
          HomeView()
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
  }

  private func seedProfile() {
    guard profiles.isEmpty else { return }
    context.insert(UserProfile())
    try? context.save()
  }

  private func resumeMonitoring(profile: UserProfile) {
    guard screenTime.isAuthorized else { return }
    screenTime.syncReasonsToDefaults(profile.reasons)
    screenTime.startMonitoring()
  }
}
