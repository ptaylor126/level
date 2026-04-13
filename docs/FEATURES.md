# Level — Feature Specifications

## F1: Onboarding

### Flow
1. **Welcome** → "Level helps you take back your time" → single CTA button "Get Started"
2. System requests FamilyControls authorisation (iOS system dialog)
3. **App Picker** → App selection screen using FamilyActivityPicker → "Choose the apps you want to manage"
4. **Reasons** → "Why do you want to spend less time on your phone?" → unlimited text inputs with placeholder examples (skippable — no minimum required)
5. **Unlock Limit** → "How many times can you open each app per day?" → numeric picker, default 10, skippable
6. **Session Length** → "How long can you use an app before the shield returns?" → duration picker, default 5 minutes, skippable
7. **Momentum Intro** → brief explanation of the momentum system → informational, single CTA to continue
8. **Summary** → recap of the user's chosen settings → CTA "Looks good"
9. **Done** → "You're all set" → CTA "Start using Level"

### Acceptance Criteria
- Onboarding completes in under 90 seconds
- User must authorise FamilyControls to proceed (explain why if denied)
- At least 1 app must be selected
- Reasons step is skippable — zero reasons is valid at onboarding time
- Unlock Limit step is skippable — defaults to 10 if skipped
- Session Length step is skippable — defaults to 5 minutes if skipped
- Onboarding state persisted — never shown again after completion
- Placeholder reason examples: "Be more present with my family", "Read more books", "Sleep better", "Get more work done"

## F2: Level Screen (Shield)

### Behaviour
- Triggered by iOS when user tries to open a managed app
- Displays a personal reason from the user's list using a shuffled playlist — cycles through all reasons before any repeats
- If the user has not entered any reasons, falls back to built-in default reasons
- Shows countdown timer
- Timer duration = base delay + (increment × number of times this app opened today)
- Default base: 10 seconds, default increment: 10 seconds
- After timer completes, "Open anyway" button appears
- "Not now" button always visible
- After tapping "Open anyway" and using the app, the shield returns automatically once the configured session length has elapsed (default: 5 minutes)

### Reason Playlist Logic
- Reasons are displayed in a shuffled order; the full list is exhausted before any reason repeats
- Shuffle state persists across shield appearances within the same day and resets at midnight
- If the user has no saved reasons, fallback defaults are used: "Is this worth your time?", "Take a breath — do you really need this?", "What could you do instead?", "You set this limit for a reason."

### UI
- Full screen, Vintage Grape (#473144) background
- Personal reason: centred, Cream (#FFF8F0), 20pt, regular weight
- Timer: centred below reason, Tea Green (#DDF4C9), 36pt, extra bold
- "Not now" button: bottom of screen, ghost style (Cream border + text)
- "Open anyway": appears after timer, subtle, secondary style, below "Not now"

### Acceptance Criteria
- Reasons cycle through a shuffled playlist; no reason repeats until all have been shown
- Fallback default reasons are used when the user has saved zero personal reasons
- Timer counts down accurately
- "Open anyway" is NOT visible until timer reaches zero
- Tapping "Not now" dismisses shield, does NOT count as an unlock
- Tapping "Open anyway" counts as an unlock, opens the app, and schedules the shield to return after the configured session length
- Shield returns after session length elapses (default 5 minutes), regardless of whether the user is still in the app
- If daily unlock limit reached, "Open anyway" is replaced with "You've used all your unlocks today. Come back tomorrow."
- Shield works in both light and dark mode (always dark regardless of system setting)

## F3: Daily Unlock Limits

### Behaviour
- Each managed app has a daily unlock limit (default: 10, configurable during onboarding or in settings)
- An "unlock" = user waited through the level timer and tapped "Open anyway"
- Closing the shield without opening ("Not now") does NOT count
- Counter resets at midnight local time
- When limit reached, app is fully blocked until midnight
- After each unlock, the shield will automatically return once the configured session length has elapsed (default: 5 minutes); this session return does NOT consume an additional unlock

### Session Length
- Configurable per-user (set during onboarding or in Settings → Timing)
- Default: 5 minutes
- Range: 1–60 minutes
- When the session length elapses after an "Open anyway", the shield reappears and the user must wait through the timer again to continue using the app

### Acceptance Criteria
- Unlock count persists through app backgrounding and device restart
- Counter is accurate across multiple opens
- Block is enforced even if user closes and reopens the managed app rapidly
- Remaining unlocks displayed on home screen
- Session length setting persists through app updates
- Shield re-appearance after session length does not decrement the unlock counter

## F4: Home Screen

### Layout
Bento grid layout as specified in DESIGN_SYSTEM.md. Scrollable vertically.

### Cards

**Screen Time Card (full width)**
- Shows today's tracked screen time in "Xh Ym" format
- Comparison: "X% less/more than yesterday"
- Background: Tea Green if improving (less than yesterday), Cream if same or worse
- Icon: phone outline

**Momentum Card (left, half width)**
- Shows momentum score as large number
- Score inside a Tea Green rounded badge
- Streak count below: "X day streak"
- Background: Pastel Pink

**Unlocks Card (right, half width)**
- Shows remaining unlocks as large number
- "of X today" subtitle
- Background: Cream with subtle border

**Weekly Chart Card (full width)**
- 7 bars for Mon-Sun
- Bar height proportional to screen time
- Vintage Grape bars for normal days
- Tea Green bars for days goal was met
- Background: Cream

**App Limits Card (full width)**
- Progress bar per managed app category
- Shows category name, time remaining
- Tea Green fill for usage, warm grey track
- Background: Cream

**Reason Card (full width)**
- Heart icon + "Why I'm Doing This" label
- Displays one of the user's reasons (rotates)
- Background: Cream

### Acceptance Criteria
- All data refreshes when app comes to foreground
- Cards animate in on first load (subtle fade, 0.2s)
- Screen time data comes from DeviceActivityReport
- Momentum score is calculated and updated daily
- Pulling down triggers refresh

## F5: Momentum System

### Score Rules
- Range: 0-100
- Starting score for new users: 50
- Daily adjustments (applied at end of day or when app opens next day):
  - Screen time under daily goal: +3
  - Unlocks used < 50% of limit: +2
  - Each "Not now" close (declined open): +1 (max +5 per day)
  - Screen time over daily goal: -2
  - All unlocks used: -1
- Score uses exponential moving average: new = (0.7 × calculated) + (0.3 × previous)
- Clamped to 0-100 after calculation

### Acceptance Criteria
- Score cannot go below 0 or above 100
- A single bad day reduces score by 2-3 points maximum
- Recovery from a bad day takes 1-2 good days
- Score is visible on home screen at all times
- Score changes are animated (count up/down over 0.5s)

## F6: Trigger Tracking

### Behaviour
- Prompt appears after the 3rd time a user closes the shield without opening the app in a single session
- A "session" resets after 30 minutes of no shield interactions
- Prompt: "What were you looking for?"
- Options displayed as tappable pills: Bored, Anxious, Avoiding something, Habit, Just checking
- Dismiss button (X) always available — answering is optional
- Response logged with timestamp

### Data
- Stored locally in TriggerLog model
- Aggregated into weekly/monthly patterns
- Viewable in Settings → "Your Patterns"
- Simple display: "This week you mostly reached for your phone when you were bored (62%)"

### Acceptance Criteria
- Prompt appears only after 3rd declined open, not before
- Prompt never appears more than once per session
- Dismissing without answering is always possible
- User can view their trigger history in settings
- Data never leaves the device

## F7: Notifications

### Types
| Type | Default | Timing | Content Example |
|------|---------|--------|-----------------|
| Weekly recap | ON | Sunday 7pm | "This week: 12h screen time (down 18%). Momentum: 78." |
| Morning summary | OFF | 9am | "Yesterday: 1h 45m. You saved 45 minutes." |
| Streak at risk | OFF | 8pm | "You're on day 12. Today's looking close — you've got this." |

### Acceptance Criteria
- All notification types individually toggleable
- Notifications use local scheduling only (no push server)
- Tone is encouraging, never guilt-based
- Tapping notification opens the app to home screen
- Notifications respect Do Not Disturb

## F8: Settings

### Sections
1. **Manage Apps** — opens FamilyActivityPicker to add/remove managed apps
2. **My Reasons** — edit, add, delete personal reasons (no minimum — zero reasons is valid; fallback defaults are used when empty)
3. **Timing** — adjust default delay (5-60s), increment (5-30s), daily unlock limit (1-50), session length (1-60 min)
4. **Notifications** — toggles for each type
5. **Your Patterns** — trigger tracking summary and chart
6. **Appearance** — light / dark / system
7. **About** — privacy info, version, "Your data never leaves your phone"

### Acceptance Criteria
- Changes to managed apps take effect immediately
- Reasons can be reduced to zero; shield will use fallback default reasons when no personal reasons exist
- Timing changes apply from next app open, not retroactively
- Settings persist through app updates
