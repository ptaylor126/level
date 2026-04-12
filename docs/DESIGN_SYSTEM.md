# Level — Design System

## Brand Identity

### Name
**Level** — styled as a bold italic wordmark. Never in all caps. Never with a logo mark separate from the text at this stage.

### Personality
Calm, warm, trustworthy, slightly playful. The app should feel like a deep breath. Not clinical, not techy, not preachy.

## Colour Palette

### Primary Colours
| Name | Hex | SwiftUI | Usage |
|------|-----|---------|-------|
| Vintage Grape | #473144 | Color(hex: "473144") | Primary dark, backgrounds (dark mode), text on light surfaces, headers |
| Pastel Pink | #FFCAD4 | Color(hex: "FFCAD4") | Accent surface — use sparingly, ONE card max on home screen |
| Tea Green | #DDF4C9 | Color(hex: "DDF4C9") | Progress, wins, positive indicators, momentum badges, goal-met bars |
| Cream | #FFF8F0 | Color(hex: "FFF8F0") | Background (light mode), neutral card surfaces, text on dark surfaces |

### Supporting Colours
| Name | Hex | Usage |
|------|-----|-------|
| Muted Grape | #6B5068 | Secondary text on dark backgrounds |
| Deep Grape | #2E1F2C | Darker shade for pressed states |
| Warm Grey | #E8DDD5 | Subtle borders on cream cards |
| Dark Green | #3A5A28 | Text on Tea Green surfaces |
| Rose | #6B3040 | Text on Pastel Pink surfaces |

### Colour Rules
1. **Pink is precious.** Use Pastel Pink on ONE card per screen maximum. It's the accent, not the default.
2. **Green means earned.** Tea Green only appears for positive outcomes — progress, goals met, momentum up.
3. **Cream is the workhorse.** Most cards and surfaces are Cream.
4. **Text on coloured surfaces** always uses the darkest shade from that colour family, never black.
5. **Dark mode:** Vintage Grape background, light cards on top.
6. **Light mode:** Cream background, same card colours, Vintage Grape text.

## Typography

### Font
**Plus Jakarta Sans** — Google Fonts, free for commercial use, OFL licence.

Include weights: 400 (Regular), 500 (Medium), 700 (Bold), 800 (ExtraBold).

### Type Scale
| Role | Size | Weight | Usage |
|------|------|--------|-------|
| Wordmark | 28pt | 800 Italic | App name "Level" only |
| Display | 36pt | 800 | Large stat numbers (screen time, momentum score) |
| Heading 1 | 20pt | 700 | Section headers |
| Heading 2 | 17pt | 700 | Card titles |
| Body | 15pt | 400 | General text, descriptions |
| Label | 11pt | 700, uppercase, 0.5pt tracking | Card category labels (e.g., "MOMENTUM SCORE") |
| Caption | 13pt | 400 | Secondary info, subtitles |

### Typography Rules
1. Never use system fonts. Always Plus Jakarta Sans.
2. The wordmark is the ONLY italic text in the entire app.
3. Labels are always uppercase with letter spacing.
4. Body text line height: 1.5
5. No text smaller than 11pt.

## Spacing

### Grid
- Base unit: 4pt
- Card padding: 16pt
- Card gap: 12pt
- Screen padding: 20pt horizontal
- Section spacing: 24pt

### Corner Radius
| Element | Radius |
|---------|--------|
| Cards | 16pt |
| Buttons | 12pt |
| Badges/pills | 8pt |
| Momentum score badge | 12pt |
| Input fields | 10pt |

## Components

### Cards
- Background: Cream (#FFF8F0), Pastel Pink (#FFCAD4), or Tea Green (#DDF4C9)
- Border: 0.5pt #E8DDD5 (on Cream cards only, optional)
- Corner radius: 16pt
- Padding: 16pt
- No shadows. No gradients. Flat.

### Buttons
- Primary: Vintage Grape background, Cream text
- Secondary: Cream background, Vintage Grape text, 1pt Vintage Grape border
- Corner radius: 12pt
- Height: 48pt minimum
- Font: 15pt, 700 weight

### Progress Bars
- Track: #E8DDD5 (warm grey)
- Fill (positive): Tea Green (#DDF4C9)
- Fill (warning/high usage): Pastel Pink (#FFCAD4)
- Fill (blocked): Vintage Grape (#473144)
- Height: 6pt
- Corner radius: 3pt (fully rounded)

### Bar Chart (Weekly)
- Bar colour (normal): Vintage Grape (#473144)
- Bar colour (goal met): Tea Green (#DDF4C9)
- Bar corner radius: 4pt top corners
- Bar width: proportional, with 8pt gaps
- Day labels: 11pt, Label style, Muted Grape

### Shield/Level Screen
- Full screen overlay
- Background: Vintage Grape (#473144)
- Personal reason text: Cream (#FFF8F0), 20pt, 400 weight, centred
- Countdown timer: 36pt, 800 weight, Tea Green (#DDF4C9)
- "Close" button: Ghost style, Cream border, Cream text
- "Open anyway" button: Appears only after timer completes, subtle, secondary style

## Layout

### Home Screen Structure (Bento Grid)
```
┌──────────────────────────┐
│     Level (wordmark)     │
│     Saturday, April 11   │
├──────────────────────────┤
│                          │
│   Screen Time Card       │
│   (full width)           │
│                          │
├────────────┬─────────────┤
│ Momentum   │ Unlocks     │
│ Score      │ Left        │
│ (pink)     │ (cream)     │
├────────────┴─────────────┤
│   This Week Chart        │
│   (full width, cream)    │
├──────────────────────────┤
│   App Limits             │
│   (progress bars)        │
├──────────────────────────┤
│   Why I'm Doing This     │
│   (cream, personal quote)│
└──────────────────────────┘
```

## Animation
- Keep animations minimal and functional
- Card transitions: 0.2s ease
- Momentum score changes: count up/down animation, 0.5s
- Progress bar fills: 0.3s ease-out
- No bounces, no springs, no playful animations. Calm.

## App Icon
- Two vertical bars (level symbol)
- Bars: Cream (#FFF8F0) or Tea Green (#DDF4C9)
- Background: Vintage Grape (#473144)
- Simple, recognisable at any size
- No text on the icon
