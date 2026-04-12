# Level — Product Requirements Document

## Vision
Level helps people take back their time from their phones. It creates a moment of friction before mindless app usage, tracks progress through a forgiving momentum system, and helps users understand their own triggers — all without guilt or lecturing.

## Target User
Adults who know they use their phone too much and want to change, but have tried Apple's Screen Time or other apps and found them too easy to bypass, too expensive (subscriptions), or too preachy. They want something that works, looks good, and doesn't cost a fortune.

## Business Model
- One-time purchase: $4.99
- No subscription, no in-app purchases, no ads
- No server infrastructure — everything on-device
- Revenue comes from volume, not recurring billing
- This is a key differentiator: most competitors charge $50-100/year

## Competitive Positioning
- **vs ScreenZen:** ScreenZen is free and donation-supported with strong features. Level differentiates through design quality, momentum system (not binary streaks), and trigger tracking.
- **vs Opal:** Opal charges ~$100/year and has known bugs with inconsistent blocking. Level is 20x cheaper as a one-time fee with a focus on reliability.
- **vs Be Present:** Be Present forces category-level blocking. Level offers per-app control.
- **vs Apple Screen Time:** Too easy to bypass ("Ignore for today"), no behavioural insights.

## MVP Features (v1.0)

### 1. Onboarding (3 screens max)
- Screen 1: Welcome, request FamilyControls authorization
- Screen 2: Select apps to manage (using FamilyActivityPicker)
- Screen 3: Write 1-3 personal reasons for reducing screen time
- No account creation. No tutorials. No feature tours.

### 2. Level Screen (Shield)
- Appears when user tries to open a managed app
- Shows one of their personal reasons (randomly selected)
- Countdown timer starting at 10 seconds (configurable)
- Delay increases by 10 seconds with each subsequent open of the same app that day
- User can close and walk away, or wait and proceed
- Dark, calm design — Vintage Grape background with Cream text

### 3. Daily Unlock Limits
- Users set a daily unlock limit per app (default: 10)
- Each time they wait through the level and open the app, it counts as an unlock
- When unlocks are exhausted, the app is fully blocked for the rest of the day
- Reset at midnight

### 4. Home Screen (Bento Grid)
- App name "Level" as bold italic wordmark
- Today's screen time card (Tea Green when improving, Cream when neutral)
- Momentum score card (Pastel Pink)
- Unlocks remaining card (Cream with subtle border)
- Weekly usage bar chart (Cream card, Vintage Grape bars, Tea Green for goal-met days)
- Per-app category progress bars showing time remaining
- Personal reason card (Cream)
- All on Vintage Grape background (dark mode) or Cream background (light mode)

### 5. Momentum System
- Score from 0-100
- Increases when user stays under their goals, declines open counts, or closes apps during the level
- Decreases gradually on bad days — NOT binary like streaks
- A bad day reduces momentum by a few points, not to zero
- Displayed prominently on home screen
- Streak counter shown alongside but secondary to momentum

### 6. Trigger Tracking
- After the 3rd declined app open in a session, show an optional prompt: "What were you looking for?"
- Options: Bored, Anxious, Avoiding something, Habit, Just checking
- One tap to select, one tap to dismiss without answering
- Data builds over time into a simple chart in settings showing trigger patterns
- Weekly summary: "You mostly reach for your phone when you're bored"

### 7. Per-App Control
- Individual app selection (not categories)
- Per-app unlock limits
- Per-app delay settings
- Ability to add/remove apps at any time

### 8. Screen Time Stats
- Today's total screen time (distracting apps only, not Maps/utilities)
- Comparison to yesterday and last week
- Weekly bar chart
- Per-app time remaining against limits

### 9. Notifications (all individually toggleable)
- Weekly recap (default: ON)
- Morning summary of yesterday (default: OFF)
- Streak at risk reminder (default: OFF)
- No more than these three types. No nagging.

### 10. Settings
- Manage tracked apps
- Edit personal reasons
- Adjust delay times and unlock limits
- Toggle notifications
- View trigger patterns
- Light/dark mode toggle
- Privacy info ("Your data never leaves your phone")

## Post-MVP Features (v1.1+)
- Time squares visualisation (memento mori style showing time spent/saved)
- "What you could have done" reframes (positive, not guilt-based)
- Widget for home screen showing momentum and unlocks
- Gamification expansion (levels, achievements)
- iPad support
- Android version

## Tone of Voice
- Warm, not clinical
- Encouraging, not judgmental
- Brief, not verbose
- "You spent 2 hours less this week" not "You wasted 5 hours"
- "That's enough time to cook a meal from scratch" not "You should have been cooking"
- The app is on your side. It's the friend who gently reminds you, not the parent who lectures.

## Success Metrics
- User opens the app daily
- Screen time decreases week over week
- Momentum score trends upward over time
- User retains for 30+ days
- 4.5+ star App Store rating
