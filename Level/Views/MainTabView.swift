import SwiftUI

enum Tab: Int, CaseIterable {
  case home, stats, schedule, social, settings

  var icon: String {
    switch self {
    case .home: return "house.fill"
    case .stats: return "chart.bar.fill"
    case .schedule: return "calendar"
    case .social: return "person.2.fill"
    case .settings: return "gearshape.fill"
    }
  }

  var label: String {
    switch self {
    case .home: return "Home"
    case .stats: return "Stats"
    case .schedule: return "Schedule"
    case .social: return "Social"
    case .settings: return "Settings"
    }
  }
}

struct MainTabView: View {
  @State private var selectedTab: Tab = .home

  init() {
    UITabBar.appearance().isHidden = true
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      TabView(selection: $selectedTab) {
        HomeView()
          .tag(Tab.home)
        StatsView()
          .tag(Tab.stats)
        ScheduleView()
          .tag(Tab.schedule)
        SocialView()
          .tag(Tab.social)
        SettingsView()
          .tag(Tab.settings)
      }

      pillTabBar
    }
  }

  private var pillTabBar: some View {
    HStack(spacing: 0) {
      ForEach(Tab.allCases, id: \.self) { tab in
        Button {
          selectedTab = tab
        } label: {
          VStack(spacing: 4) {
            Image(systemName: tab.icon)
              .font(.system(size: 20, weight: .medium))
            Text(tab.label)
              .font(LevelFont.medium(10))
          }
          .foregroundStyle(tab == selectedTab ? Color.teaGreen : Color.vintageGrape)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(
      Capsule(style: .continuous)
        .fill(Color.cream)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
    )
    .padding(.horizontal, 20)
    .padding(.bottom, 8)
  }
}
