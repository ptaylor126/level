# Level — Social Section PRD

## Overview
The Social tab adds accountability and competition through friends, leaderboards, and group challenges. This is the feature that turns Level from a solo tool into something people talk about and recommend. Social features use CloudKit so data stays within Apple's ecosystem and the user's iCloud account — no custom server needed.

## Architecture

### CloudKit Setup
- Use CloudKit public and private databases
- Private database: user's own records (momentum, streaks, XP)
- Public database: leaderboard entries, group memberships, friend connections
- Users create a Level profile linked to their iCloud account — no separate account creation
- Profile data: display name (required), optional avatar (initials-based, not photo)
- Privacy: users share only momentum score, streak count, XP, and display name — never screen time data, app names, or reasons

### What Is Shared (and what is NOT)
**Shared with friends/leaderboards:**
- Display name
- Momentum score (number only)
- Current streak count
- Total XP
- Level/rank

**Never shared:**
- Which apps they've restricted
- Their personal reasons
- Screen time amounts
- Trigger tracking data
- Unlock counts

## Features

### 1. Friends
- Add friends via a unique Level code (6 character alphanumeric, generated for each user)
- Share code via text/iMessage — "Add me on Level: ABC123"
- Friend list shows each friend's: display name, momentum score, streak, XP
- Tappable to see their profile card with trend (up/down/steady)
- Maximum 20 friends to keep it manageable
- Remove friend option (no notification sent to the other person)

### 2. Leaderboards

**Friends Leaderboard**
- Default view — ranked list of user + their friends
- Sorted by: momentum score (default), XP (toggle), streak (toggle)
- Top 3 highlighted with subtle Tea Green/Pastel Pink/Cream accents (not gold/silver/bronze — stay on brand)
- User's own position always visible, highlighted
- Updates in real time when the app is opened (CloudKit fetch)
- "Level-headed leaders" as the header

**Group Leaderboards**
- Users can create or join groups (max 30 members)
- Groups have a name and a 6 character join code
- Same ranking as friends leaderboard but within the group
- Group types suggested: "Family", "Work", "Friends", "Study group"
- Group creator can remove members
- Anyone can leave a group

### 3. Accountability Partners
- Select 1-3 friends as accountability partners
- If the user breaks their streak or momentum drops below a threshold they set, the partner gets a notification: "[Name] could use some backup. Their momentum dipped today."
- The user chooses what triggers the alert: streak broken, momentum below X, all unlocks used
- Must opt in — not automatic
- Partner receives a simple notification, no detailed data
- Copy: "Your accountability crew"

### 4. Challenges (v2 — placeholder for now)
- Weekly challenges between friends or groups
- "Who can save the most time this week?"
- "7-day streak challenge — who makes it?"
- Winner gets bonus XP
- Show as a card on the Social tab: "Challenge active: 3 days left"
- For MVP: show "Challenges coming soon" placeholder

### 5. Share Progress
- Share button on home screen and stats
- Generates a shareable image card showing: momentum score, streak, time saved this week, XP
- Branded with Level wordmark and colours
- Shareable via iOS share sheet (iMessage, Instagram stories, etc.)
- No private data included — just the summary numbers
- "Share your level" as the button text

## Social Tab Layout

### Top Section
- User's profile card: display name, momentum, streak, XP, Level code
- "Share your code" button
- "Add friend" button (enter a code)

### Friends Section
- List of friends with momentum scores and streaks
- Sorted by momentum (highest first)
- "Level-headed leaders" header
- Toggle between: Momentum / XP / Streak ranking

### Groups Section
- List of groups the user belongs to
- Tappable to see group leaderboard
- "Create group" and "Join group" buttons
- "Join a group to compete with others" empty state

### Accountability Section
- List of accountability partners
- Status: "Active" or "Add a partner"
- Settings for what triggers alerts

## Empty States
- No friends: "Add friends to see how you stack up. Share your code: [ABC123]"
- No groups: "Create or join a group to compete together."
- No accountability partners: "Pick a friend to keep you honest."

## Onboarding for Social
- Don't show during initial onboarding — the user has enough to set up
- Show a prompt after 3 days of use: "Want to add friends? It helps."
- Social tab shows the setup flow on first visit

## Privacy Controls (in Settings)
- Toggle: "Show me on leaderboards" (default: on)
- Toggle: "Allow accountability notifications" (default: off until they set up partners)
- "Delete my social profile" — removes all shared data from CloudKit

## Tone
- Competitive but friendly — "Level-headed leaders" not "Rankings"
- Accountability should feel supportive not surveillance — "could use some backup" not "failed today"
- Groups should feel casual — "Study Buds" not "Accountability Group #1"

## Technical Notes
- CloudKit operations should be async and not block the UI
- Cache friend/leaderboard data locally for offline viewing
- Refresh on pull-to-refresh and on tab selection
- Handle CloudKit errors gracefully — "Couldn't load leaderboard. Pull to retry."
- CloudKit is free up to generous limits (10GB asset storage, 100MB database, 2GB transfer per day) — more than enough for this use case
