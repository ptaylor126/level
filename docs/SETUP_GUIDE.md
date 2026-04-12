# Pause — Claude Code Setup Guide

## Prerequisites
- macOS with Xcode 16+ installed
- Apple Developer account with active membership
- Node.js installed (for XcodeBuildMCP)
- Claude Code CLI installed

## Step 1: Install XcodeBuildMCP

This gives Claude Code the ability to build, run, test, and debug your app directly.

```bash
claude mcp add XcodeBuildMCP -s user -- npx -y xcodebuildmcp@latest mcp
```

Verify it's connected:
```bash
claude mcp list
```

You should see XcodeBuildMCP with 59 tools available.

## Step 2: Apply for Family Controls Entitlement

This is the most important non-coding step. Without it, you can develop and test locally but cannot distribute on the App Store.

1. Go to https://developer.apple.com/contact/request/family-controls-distribution
2. Fill out the form explaining your app
3. Apple typically responds within a few days
4. In the meantime, you can use the Development entitlement for testing

## Step 3: Create the Xcode Project

Start Claude Code in your project directory and use this initial prompt:

```
Create a new Xcode project called "Pause" with the following configuration:
- SwiftUI App lifecycle
- Deployment target iOS 16.0
- iPhone only
- Add two extension targets: "PauseMonitor" (DeviceActivityMonitor) and "PauseShield" (ShieldConfiguration)
- Set up an App Group "group.com.[yourid].pause" shared across all three targets
- Add FamilyControls capability to all targets
- Read the CLAUDE.md and all files in docs/ before starting

Set up the project structure as defined in docs/ARCHITECTURE.md.
```

## Step 4: Project CLAUDE.md

Copy the CLAUDE.md file from this package into the root of your Xcode project directory. Claude Code reads this automatically.

Copy the docs/ folder into your project as well.

## Step 5: Development Workflow

### Starting a session
```bash
cd /path/to/Pause
claude
```

### Recommended first prompt
```
Read CLAUDE.md and all files in docs/. Then start with Step 1 from the build order in ARCHITECTURE.md: set up the Xcode project with all three targets and App Group. Build and verify it compiles.
```

### Building and running
Claude Code with XcodeBuildMCP can:
- Build the project: uses `build_sim` tool
- Run on simulator: uses `build_and_run` tool
- Take screenshots: uses `screenshot` tool
- Run tests: uses `test` tool

### Tips for effective use
1. **Start in plan mode** — ask Claude to read docs and propose a plan before writing code
2. **One feature at a time** — follow the build order in ARCHITECTURE.md
3. **Build after every change** — tell Claude to compile and fix errors before moving on
4. **Commit frequently** — one commit per feature/fix
5. **Review the code** — Claude can take shortcuts; check for hardcoded values or hacks
6. **Test on device early** — simulator doesn't fully replicate FamilyControls behaviour

## Step 6: Testing

### Simulator limitations
- FamilyControls authorisation works in simulator but behaviour can be inconsistent
- Shield extensions may not trigger in simulator — test on a real device
- DeviceActivityReport data may be empty in simulator

### Real device testing
- Connect your iPhone
- Set up a Development provisioning profile with Family Controls (Development) entitlement
- Build and run on device using XcodeBuildMCP

## Common Issues

### "Family Controls entitlement not found"
- Ensure you've added the capability in Xcode's Signing & Capabilities tab for ALL THREE targets
- For development, use the Development entitlement
- For App Store, you need the Distribution entitlement (Step 2)

### Extensions crashing silently
- Extensions have ~6MB memory limit
- Keep extension code minimal — no heavy computation
- Use print statements and check Console.app for extension logs

### Token mismatch errors
- FamilyControls tokens can change unexpectedly
- Always store and reference FamilyActivitySelection, not individual tokens
- Re-read selection from shared UserDefaults on each extension callback

### Shield not appearing
- Verify ManagedSettingsStore has apps assigned to shield
- Check that DeviceActivityCenter monitoring is active
- Restart the device if shields stop appearing (known iOS behaviour)
