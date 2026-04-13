import SwiftUI

struct MainTabView: View {
  init() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor(Color.deepGrape)
    appearance.shadowColor = .clear

    UITabBar.appearance().standardAppearance = appearance
    UITabBar.appearance().scrollEdgeAppearance = appearance
  }

  var body: some View {
    TabView {
      HomeView()
        .tabItem {
          Image(systemName: "house.fill")
          Text("Home")
        }
        .tag(0)

      StatsView()
        .tabItem {
          Image(systemName: "chart.bar.fill")
          Text("Stats")
        }
        .tag(1)

      ScheduleView()
        .tabItem {
          Image(systemName: "calendar")
          Text("Schedule")
        }
        .tag(2)

      SocialView()
        .tabItem {
          Image(systemName: "person.2.fill")
          Text("Social")
        }
        .tag(3)

      SettingsView()
        .tabItem {
          Image(systemName: "gearshape.fill")
          Text("Settings")
        }
        .tag(4)
    }
    .tint(Color.cream)
    .onAppear {
      UITabBar.appearance().unselectedItemTintColor = UIColor(Color.mutedGrape)
    }
  }
}
