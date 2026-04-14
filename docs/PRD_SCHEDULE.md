# Level — Schedule Section PRD

## Overview
The Schedule tab lets users set different restriction levels for different parts of the day. Instead of one-size-fits-all blocking, users can be strict during work, lighter in the evening, and fully blocked at bedtime. The modes are branded using the Level name.

## Modes

### Boss Level (Strict)
- Maximum friction — highest delays, lowest unlock count
- Default settings: 30 second base delay, 15 second increment, 3 unlocks
- Intended for: work hours, study sessions, deep focus
- Visual: Tea Green accent to signal "this is productive time"

### Base Level (Standard)
- Normal friction — default delays and unlocks
- Default settings: 10 second base delay, 10 second increment, 10 unlocks
- Intended for: general daytime use, weekends
- Visual: Cream accent, neutral

### Rest Level (Wind down)
- Full block — no unlocks available, all managed apps completely blocked
- No timer, no "Open anyway" — apps are fully shielded
- Intended for: bedtime, early morning, family time
- Shield message: "Rest Level is on. See you in the morning." (or whenever the mode ends)
- Visual: Pastel Pink accent to signal calm/rest

### Off
- No restrictions active — all apps accessible
- Should feel intentional, not like they've given up
- Copy: "Taking a break from Level. That's fine."

## Schedule Setup

### Daily Timeline
- Visual timeline showing 24 hours as a horizontal or vertical bar
- Users drag to set blocks of time for each mode
- Each mode is colour coded (Tea Green, Cream, Pastel Pink)
- Default schedule suggested during setup:
  - 7am - 9am: Boss Level (morning focus)
  - 9am - 5pm: Base Level (work day)
  - 5pm - 9pm: Base Level (evening)
  - 9pm - 7am: Rest Level (sleep)
- Users can fully customise

### Per-Day Customisation
- Different schedules for weekdays vs weekends
- Toggle: "Same schedule every day" or "Customise by day"
- If customised, show day tabs (Mon-Sun) with independent timelines

### Quick Actions
- "Boss Level now" — instantly activates Boss Level until the user turns it off or the next scheduled mode kicks in
- "Rest Level now" — same but for full block
- These should be prominent buttons on the Schedule tab, not buried in settings
- Quick actions override the schedule temporarily

## Schedule Display

### Main View
- Today's schedule shown as a visual timeline with the current mode highlighted
- Current mode displayed prominently at top: "Boss Level until 5pm"
- Next mode preview: "Base Level starts at 5pm"
- Quick action buttons below the timeline

### Visual Timeline
- Horizontal bar divided into coloured segments
- Current time indicated with a small marker
- Mode labels inside each segment if wide enough, icons if not
- Tappable segments to edit that time block

## Interaction with Shield

- When Boss Level is active, shield delay and unlock limits use Boss Level settings
- When Rest Level is active, shield shows no unlock option at all — just "Rest Level is on" + "I'm good" button
- When Off is active, shields are removed entirely
- Mode changes should apply immediately when the scheduled time arrives

## Notifications
- Optional notification when a mode changes: "Boss Level is on. Time to focus."
- Optional reminder before Rest Level: "Rest Level starts in 15 minutes. Finish up."
- Both toggleable in settings

## Empty State
- First visit: "Set up your daily schedule to automatically adjust your restrictions throughout the day."
- Show the suggested default schedule and a "Use this schedule" button for quick setup
- "Or build your own" link below

## Data Storage
- Schedules stored in SwiftData on device
- Schedule settings shared with extensions via App Group UserDefaults
- DeviceActivityCenter schedules updated when the user modifies their schedule

## Tone
- "Boss Level" should feel empowering, not restrictive
- "Rest Level" should feel like self-care, not punishment
- The schedule is them being strategic about their time, not limiting themselves
