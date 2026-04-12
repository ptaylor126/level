# Level — Technical Architecture

## Overview
Level is a native iOS app built with SwiftUI. It uses Apple's Screen Time API (FamilyControls, ManagedSettings, DeviceActivity) to monitor and manage app usage. All data is stored on-device using SwiftData. No server, no network calls, no analytics.

## Targets
The app requires three targets:
1. **Level** — Main app target
2. **LevelMonitor** — DeviceActivityMonitor extension (monitors usage events)
3. **LevelShield** — ShieldConfiguration extension (customises the shield/level screen)

All three targets must belong to the same App Group for shared data access.

## App Group
- Identifier: `group.com.yourcompany.level`
- Used for: Sharing UserDefaults, SwiftData store, and FamilyActivitySelection tokens between the main app and extensions
- Both extensions MUST have this App Group configured

## Frameworks

### FamilyControls
- Request authorisation: `AuthorizationCenter.shared.requestAuthorization(for: .individual)`
- Use `.individual` (not `.child`) — this is a self-management app
- Provides `FamilyActivityPicker` for app selection
- Returns opaque `ApplicationToken` values (you cannot see app names/bundle IDs for privacy)

### ManagedSettings
- `ManagedSettingsStore` — apply shields to selected apps
- `ShieldSettings` — configure which apps are shielded
- Shields are applied/removed by the DeviceActivityMonitor extension

### DeviceActivity
- `DeviceActivityCenter` — start/stop monitoring schedules
- `DeviceActivityMonitor` — extension that receives callbacks for interval start/end and usage thresholds
- `DeviceActivityReport` — SwiftUI view for rendering usage data

## Data Models (SwiftData)

### UserProfile
```swift
@Model class UserProfile {
    var reasons: [String]           // Personal reasons for reducing screen time
    var onboardingComplete: Bool
    var createdAt: Date
}
```

### DailyRecord
```swift
@Model class DailyRecord {
    var date: Date
    var totalScreenTime: TimeInterval  // Seconds
    var unlockCount: Int
    var unlockLimit: Int
    var momentumScore: Double          // 0-100
    var goalMet: Bool
}
```

### TriggerLog
```swift
@Model class TriggerLog {
    var timestamp: Date
    var trigger: String               // "bored", "anxious", "avoiding", "habit", "checking"
}
```

### AppSettings
```swift
@Model class AppSettings {
    var defaultDelaySeconds: Int       // Default: 10
    var delayIncrementSeconds: Int     // Default: 10
    var defaultUnlockLimit: Int        // Default: 10
    var notifyWeeklyRecap: Bool        // Default: true
    var notifyMorningSummary: Bool     // Default: false
    var notifyStreakAtRisk: Bool       // Default: false
    var appearanceMode: String         // "system", "light", "dark"
}
```

## Momentum Engine

### Calculation
- Base score starts at 50
- Daily adjustment based on:
  - Stayed under screen time goal: +3
  - Used fewer unlocks than limit: +2
  - Closed app during level (didn't wait): +1 per close
  - Exceeded screen time goal: -2
  - Used all unlocks: -1
  - No usage data (didn't open app): no change
- Score clamped to 0-100
- Smoothed with exponential moving average to prevent spikes

### Key Principle
A bad day costs 2-3 points. A good day gains 2-5 points. This means recovery from a bad day takes 1-2 good days, not starting from zero. This is NOT a streak — it's momentum.

## Shield Flow
1. User tries to open a managed app
2. iOS shows the shield (LevelShield extension)
3. Shield displays: random personal reason, countdown timer
4. Timer starts at base delay + (increment × opens today for this app)
5. User can:
   - Close and walk away → unlock count NOT incremented, momentum +1
   - Wait for timer, tap "Open anyway" → unlock count incremented
   - If unlocks exhausted → "Come back tomorrow" message, no open option
6. After 3rd declined open in a session → trigger prompt appears

## Notification System
- Use UNUserNotificationCenter
- Schedule local notifications only (no push server)
- Weekly recap: Sunday evening
- Morning summary: 9am showing yesterday's stats
- Streak at risk: 8pm if today's usage is trending high
- All individually toggleable, defaults specified in AppSettings

## Privacy
- No network calls whatsoever
- No analytics, no crash reporting, no telemetry
- App Store privacy label: "Data Not Collected"
- FamilyControls tokens are opaque — the app literally cannot see which apps the user selected (Apple's privacy design)
- This is a genuine selling point: "Your data never leaves your phone"

## Known API Issues
Based on developer reports, be aware of:
1. **Token instability:** FamilyControls tokens can randomly change. Store selections using FamilyActivitySelection, not raw tokens.
2. **Extension memory limits:** DeviceActivityMonitor and ShieldConfiguration extensions have very low memory limits (~6MB). Keep extension code minimal.
3. **DeviceActivityReport blank on return:** The report view can go blank when returning from background. May need to force refresh.
4. **Family Controls entitlement:** Requires Apple approval for distribution. Apply early via Apple Developer portal.
5. **Shield customisation limits:** ShieldConfiguration has limited customisation options. Test early to understand constraints.

## File Structure
```
Level/
├── LevelApp.swift                    # App entry point
├── Models/
│   ├── UserProfile.swift
│   ├── DailyRecord.swift
│   ├── TriggerLog.swift
│   └── AppSettings.swift
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift            # Main bento grid
│   │   ├── ScreenTimeCard.swift
│   │   ├── MomentumCard.swift
│   │   ├── UnlocksCard.swift
│   │   ├── WeeklyChartCard.swift
│   │   ├── AppLimitsCard.swift
│   │   └── ReasonCard.swift
│   ├── Onboarding/
│   │   ├── OnboardingFlow.swift
│   │   ├── WelcomeView.swift
│   │   ├── AppPickerView.swift
│   │   └── ReasonsView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── ManageAppsView.swift
│   │   ├── EditReasonsView.swift
│   │   ├── TriggerPatternsView.swift
│   │   └── NotificationSettingsView.swift
│   └── Components/
│       ├── LevelCard.swift           # Reusable card component
│       ├── ProgressBar.swift
│       ├── BarChart.swift
│       └── MomentumBadge.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── OnboardingViewModel.swift
│   └── SettingsViewModel.swift
├── Services/
│   ├── ScreenTimeManager.swift       # FamilyControls + ManagedSettings wrapper
│   ├── MomentumEngine.swift          # Score calculation
│   ├── NotificationManager.swift
│   └── DataStore.swift               # SwiftData container setup
├── Utilities/
│   ├── Color+Hex.swift               # Hex colour extension
│   └── Date+Extensions.swift
├── Resources/
│   └── Assets.xcassets/
│       └── AppIcon.appiconset/
├── LevelMonitor/                     # DeviceActivityMonitor extension target
│   └── LevelMonitorExtension.swift
└── LevelShield/                      # ShieldConfiguration extension target
    └── LevelShieldExtension.swift
```

## Build Order
1. Set up Xcode project with all three targets and App Group
2. Implement FamilyControls authorisation and app selection
3. Build the shield/level screen (extension)
4. Build the DeviceActivityMonitor extension
5. Build the home screen UI
6. Implement momentum engine
7. Add trigger tracking
8. Add notifications
9. Add settings
10. Polish, test, submit
