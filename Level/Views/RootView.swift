import SwiftData
import SwiftUI

struct RootView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.scenePhase) private var scenePhase
  @EnvironmentObject private var screenTime: ScreenTimeManager
  @Query private var profiles: [UserProfile]
  @Query private var settingsRecords: [AppSettings]
  @State private var showCountdown = false

  private var colorScheme: ColorScheme? {
    switch settingsRecords.first?.appearanceMode {
    case "light": .light
    case "dark": .dark
    default: nil
    }
  }

  var body: some View {
    ZStack {
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

      if showCountdown {
        CountdownView(
          onDismiss: {
            withAnimation(.easeInOut(duration: 0.3)) {
              showCountdown = false
            }
          }
        )
        .transition(.opacity)
        .zIndex(100)
      }
    }
    .preferredColorScheme(showCountdown ? .dark : colorScheme)
    .onChange(of: scenePhase) { _, phase in
      if phase == .active {
        checkPendingCountdown()
      }
    }
    .onAppear {
      checkPendingCountdown()
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
    guard screenTime.isAuthorized else { return }
    screenTime.syncReasonsToDefaults(profile.reasons)
    screenTime.startMonitoring()
  }

  private func checkPendingCountdown() {
    let unlockCount = SharedStore.defaults.integer(forKey: "todayUnlockCount")
    let unlockLimit = SharedStore.defaults.integer(forKey: "defaultUnlockLimit")
    let limit = unlockLimit > 0 ? unlockLimit : 10
    if unlockCount >= limit { return }

    let hasPendingUnlock: Bool = {
      guard let ts = SharedStore.defaults.object(forKey: "pendingUnlockTimestamp") as? Date else { return false }
      return Date().timeIntervalSince(ts) < 60
    }()

    if hasPendingUnlock {
      withAnimation(.easeInOut(duration: 0.3)) {
        showCountdown = true
      }
    }
  }
}
