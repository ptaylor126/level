# Level — iOS Screen Time App

## Project Overview
Level is a screen time management app for iOS. It helps people reduce phone usage through intentional friction, self-awareness, and positive reinforcement — not lectures or guilt.

**Business model:** One-time purchase, $4.99. No subscription, no server, no data collection. Everything runs on-device.

**Core philosophy:** The app is a calm companion, not a drill sergeant. It should feel like a deep breath, not a scolding. Progress is celebrated, setbacks are handled gracefully.

## Tech Stack
- **Language:** Swift
- **UI Framework:** SwiftUI
- **Minimum iOS:** 16.0
- **Target devices:** iPhone only
- **Architecture:** MVVM
- **Data persistence:** SwiftData (on-device only)
- **Screen Time APIs:** FamilyControls, ManagedSettings, DeviceActivity
- **No external dependencies** unless absolutely necessary

## Key Documents
Read these before starting any work:
- `docs/PRD.md` — Product requirements and feature specs
- `docs/DESIGN_SYSTEM.md` — Colours, typography, spacing, component patterns
- `docs/ARCHITECTURE.md` — Technical architecture, data models, app extensions
- `docs/FEATURES.md` — Detailed feature specifications with acceptance criteria

## Development Rules
1. Always build and verify compilation after changes using XcodeBuildMCP
2. Use SwiftUI previews to validate UI changes
3. Follow the design system exactly — colours, fonts, spacing are specified in hex/pt values
4. Keep all data on-device. No network calls. No analytics. No tracking.
5. The app must work offline — it should never need an internet connection after download
6. Every user-facing string should be warm and encouraging, never judgmental
7. Test on iPhone 15 simulator as the default device
8. Use App Groups for sharing data between the main app and extensions

## Project Structure
```
Level/
├── LevelApp.swift
├── Models/
├── Views/
│   ├── Home/
│   ├── Onboarding/
│   ├── Settings/
│   └── Components/
├── ViewModels/
├── Services/
│   ├── ScreenTimeManager.swift
│   ├── MomentumEngine.swift
│   └── DataStore.swift
├── Extensions/
│   ├── DeviceActivityMonitor/
│   └── ShieldConfiguration/
├── Resources/
│   └── Assets.xcassets
└── docs/
    ├── PRD.md
    ├── DESIGN_SYSTEM.md
    ├── ARCHITECTURE.md
    └── FEATURES.md
```

## Entitlements Required
- Family Controls (must apply for Distribution entitlement via Apple — do this early)
- App Groups (for extension data sharing)

## Build Notes
- The app requires a DeviceActivityMonitor extension target
- The app requires a ShieldConfiguration extension target
- Both extensions must share the same App Group
- FamilyControls authorisation must be requested before any Screen Time features work
