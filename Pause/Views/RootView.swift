import SwiftData
import SwiftUI

struct RootView: View {
  @Environment(\.modelContext) private var context
  @Query private var profiles: [UserProfile]

  var body: some View {
    Group {
      if let profile = profiles.first {
        if profile.onboardingComplete {
          HomeView()
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
}
