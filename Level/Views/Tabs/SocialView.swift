import SwiftData
import SwiftUI

struct SocialView: View {
  @Environment(\.modelContext) private var context
  @StateObject private var viewModel = SocialViewModel()

  // Shared notify state — one sign-up covers all three coming-soon cards
  @State private var isNotifySignedUp: Bool = false
  @State private var notifyEmailInput: String = ""

  // Share sheet
  @State private var shareImage: UIImage? = nil
  @State private var showShareSheet: Bool = false
  @State private var isGeneratingShare: Bool = false

  var body: some View {
    ZStack {
      Color.vintageGrape.ignoresSafeArea()

      ScrollView(showsIndicators: false) {
        VStack(spacing: 24) {
          topBar

          SocialProfileCard(
            displayName: viewModel.displayName,
            momentum: viewModel.momentumScore,
            streak: viewModel.streak,
            xp: viewModel.totalXP
          )

          shareButton

          friendsSection

          groupsSection

          accountabilitySection
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 32)
      }
    }
    .onAppear {
      viewModel.refresh(context: context)
      // Sync shared notify state from viewModel
      isNotifySignedUp = viewModel.isNotifySignedUp
      notifyEmailInput = viewModel.notifyEmail ?? ""
    }
    .onChange(of: notifyEmailInput) { _, newEmail in
      guard !newEmail.isEmpty else { return }
      viewModel.saveNotifyEmail(newEmail)
    }
    .sheet(isPresented: $showShareSheet) {
      if let img = shareImage {
        ShareSheet(items: [img])
      }
    }
  }

  // MARK: - Top bar

  private var topBar: some View {
    HStack(alignment: .center) {
      LevelWordmark(size: 28, color: .cream)
      Spacer()
      Text("Social")
        .font(.levelLabel)
        .tracking(0.5)
        .foregroundStyle(Color.mutedGrape)
    }
    .padding(.vertical, 8)
  }

  // MARK: - Share button

  private var shareButton: some View {
    LevelButton(
      title: isGeneratingShare ? "Generating..." : "Share your level",
      style: .primaryOnDark,
      isEnabled: !isGeneratingShare
    ) {
      generateAndShare()
    }
  }

  // MARK: - Friends section

  private var friendsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader("Level-headed leaders", icon: "person.2")

      ComingSoonCard(
        title: "Invite friends",
        description: "Coming soon — invite friends to Level and see how you stack up.",
        iconName: "person.badge.plus",
        isSignedUp: $isNotifySignedUp,
        emailInput: $notifyEmailInput
      )
    }
  }

  // MARK: - Groups section

  private var groupsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader("Groups", icon: "person.3")

      ComingSoonCard(
        title: "Team up",
        description: "Coming soon — team up with friends and compete on a shared leaderboard.",
        iconName: "person.3.sequence",
        isSignedUp: $isNotifySignedUp,
        emailInput: $notifyEmailInput
      )
    }
  }

  // MARK: - Accountability section

  private var accountabilitySection: some View {
    VStack(alignment: .leading, spacing: 12) {
      sectionHeader("Accountability", icon: "shield.checkerboard")

      ComingSoonCard(
        title: "Your crew",
        description: "Coming soon — pick friends to keep you honest. They'll hear from us if your momentum dips.",
        iconName: "heart.circle",
        isSignedUp: $isNotifySignedUp,
        emailInput: $notifyEmailInput
      )
    }
  }

  // MARK: - Helpers

  private func sectionHeader(_ title: String, icon: String) -> some View {
    HStack(spacing: 8) {
      Image(systemName: icon)
        .font(LevelFont.bold(13))
        .foregroundStyle(Color.mutedGrape)
      Text(title)
        .font(.levelH1)
        .foregroundStyle(Color.cream)
      Spacer()
    }
  }

  private func generateAndShare() {
    isGeneratingShare = true
    let image = ShareProgressHelper.renderImage(
      momentum: viewModel.momentumScore,
      streak: viewModel.streak,
      xp: viewModel.totalXP,
      timeSavedLabel: viewModel.formattedTimeSaved
    )
    shareImage = image
    isGeneratingShare = false
    if image != nil {
      showShareSheet = true
    }
  }
}

#Preview {
  SocialView()
    .modelContainer(DataStore.shared.container)
}
