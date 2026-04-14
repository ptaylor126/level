# Level — Stats Section PRD

## Overview
The Stats tab gives users a detailed breakdown of their screen time, app usage, trigger patterns, and progress over time. It should feel like a game stats screen — satisfying to look at, rewarding when trends are positive, and honest without being punishing when they're not.

## Layout
Scrollable vertical layout on Vintage Grape background. Cards in Cream and Tea Green. Same design system as home screen.

## Sections

### 1. Time Saved Summary
- Top card, full width, Tea Green when positive
- Large number: "Xh Ym saved this week"
- Comparison: "That's X% better than last week" or "Same as last week — keep at it"
- If no improvement: Cream card, no negative language

### 2. Screen Time Breakdown
- Full width Cream card
- Horizontal bar chart showing per-app usage for today
- Each bar shows: app icon, app name, time used, time remaining
- Bars use Tea Green for used portion, warm grey for remaining
- Tappable — tapping an app shows a 7-day mini chart for that specific app
- Only show managed/restricted apps, not all apps

### 3. Weekly Overview
- Full width Cream card
- 7-day bar chart (Mon-Sun)
- Vintage Grape bars for total screen time each day
- Tea Green bars for days where the user stayed under their goal
- Today's bar is highlighted/larger
- Below the chart: "Best day: Thursday (1h 12m)" and "Toughest day: Saturday (4h 30m)"

### 4. Momentum Trend
- Full width Cream card
- Line chart showing momentum score over the last 30 days
- Tea Green line on a light grid
- Score labels on the Y axis (0, 25, 50, 75, 100)
- Current score shown as a dot at the end of the line with the number
- Below the chart: "Trending up" / "Holding steady" / "Dipping — you've got this" based on the 7-day direction

### 5. Trigger Patterns
- Full width Cream card
- Title: "Be on the level. Here's what drives you."
- Simple donut or pie chart showing trigger distribution
- Categories: Bored, Anxious, Avoiding something, Habit, Just checking
- Each slice uses a different shade from the palette (Tea Green, Pastel Pink, Cream tints, Muted Grape)
- Below the chart: "You mostly reach for your phone when you're [top trigger]"
- Only shows if they have 5+ logged triggers, otherwise: "Keep using Level and we'll show you your patterns here"

### 6. XP History
- Full width Cream card
- Title: "XP earned"
- Show total XP and a simple breakdown: "X from walking away, X from unlocks through Level, X from staying under goals"
- Current level indicator if levelling system is implemented

## Data Sources
- Screen time data from DeviceActivityReport
- Trigger data from TriggerLog (SwiftData)
- Momentum data from DailyRecord (SwiftData)
- XP data from stored XP records (SwiftData)
- All on-device, no network calls

## Tone
- Positive framing always. "Saved" not "used." "Best day" not "worst day" (use "toughest" instead).
- When stats are bad, be honest but kind: "Tough week. It happens. New week starts Monday."
- Short labels, no paragraphs of text on the stats screen.

## Empty States
- First day: "Check back tomorrow. We need a day of data to show you something useful."
- No trigger data yet: "Keep using Level and we'll show your patterns here."
