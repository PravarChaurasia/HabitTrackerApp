# Requirements

## Product summary

A local-first, **fully offline** iOS habit tracker where users create recurring habits, attach tags, get reminders, and check off completions within a defined date window. Tags organize habits and drive list filtering. The app must never communicate with the internet.

## Priority legend

- **Must** — required for MVP
- **Should** — desired in MVP if time allows
- **Later** — Phase 2+

## Privacy & offline (hard constraint)

| Priority | Requirement |
|----------|-------------|
| Must | No network / internet communication of any kind |
| Must | No accounts, cloud APIs, analytics SDKs, crash reporters, ads, or remote config |
| Must | No iCloud / CloudKit sync, no third-party backends |
| Must | All habit, tag, and completion data stays on-device |
| Must | Reminders use local notifications only (`UserNotifications`) |
| Must | Optional device-to-device transfer only via offline means (e.g. AirDrop / local export file) if ever added — never via the public internet |

When building: do not enable the App Transport / network capabilities beyond what the OS needs for local notifications; do not link networking SDKs; do not call `URLSession` or similar for app features.

## Functional requirements

### Habits

| Priority | Requirement |
|----------|-------------|
| Must | Create / edit / delete a habit |
| Must | Required fields: title, start date |
| Must | Optional fields: end date, notes, reminder, tags |
| Must | Habit has a color and a simple icon for visual identity in lists |
| Must | Habit is completable only within `[startDate, endDate]` (or from startDate onward if no end) |
| Must | Mark complete / incomplete for today |
| Should | Mark complete / incomplete for past days within range |
| Should | Pause / resume (paused habits skip reminders and the daily checklist) |

### Schedule / frequency

| Priority | Requirement |
|----------|-------------|
| Must | Frequency is either daily or specific weekdays (Mon–Sun multi-select) |
| Must | A habit only appears on Today on its scheduled weekdays within the date window |
| Must | "Today" uses the device local calendar day; streak math is DST-safe |
| Later | Every N days, N times per week, and monthly recurrence |

### Streaks & progress

| Priority | Requirement |
|----------|-------------|
| Must | Current streak shown per habit on Today and habit detail |
| Must | Longest streak shown on habit detail |
| Must | Streaks derived from completion history (recompute on edit/back-fill), not a stored counter |
| Should | "Done this week" / completion count per habit |

### Onboarding templates

| Priority | Requirement |
|----------|-------------|
| Must | First launch offers 4–6 built-in starter habit templates (e.g. Drink water, Walk, Read) |
| Must | Templates are fully local; user can pick, edit, or skip entirely |

### Reminders

| Priority | Requirement |
|----------|-------------|
| Must | Local notification at chosen time on active, scheduled habit days |
| Must | Request notification permission on first reminder enable |
| Must | Updating reminder time reschedules; delete/pause cancels pending notifications |
| Must | Reminder is cancelled / suppressed once the habit is completed for that day |
| Must | No more than one reminder per habit per day |

### Tags & filter

| Priority | Requirement |
|----------|-------------|
| Must | Create tags; assign 0..n tags per habit |
| Must | Filter list: All or specific tag(s) |
| Must | Multi-select filter: habit matches if it has any selected tag |
| Must | Filtering is view-only and does not change data |

### Tracking / history

| Priority | Requirement |
|----------|-------------|
| Must | Today checklist of active habits (after tag filter) |
| Should | Simple streak or "done this week" count per habit (derived from completions) |
| Later | Calendar / history detail view |

## Non-goals (this product pass)

- Any internet communication (hard product rule — forever, not only MVP)
- Accounts, cloud sync, social/gamification cloud, analytics, ads, remote config
- Apple Health / Google Fit cloud sync, Zapier / public APIs
- Widgets, Siri Shortcuts, Apple Watch (Phase 2 candidates; still offline-only)
- Advanced recurrence (N times/week, every N days, monthly) — Phase 2
- Quantified habits, avoidance habits, per-day notes, heatmap — Phase 2
- One-off todos / Later inbox
- High-fidelity visual design / brand polish (wireframes are structural only)

## Screens (MVP)

1. **Today** — scheduled + tag-filtered checklist with per-habit streak, mark done, empty state with templates
2. **Habits** — all habits (color/icon, status, tags), tag filter chips, add habit
3. **Habit detail / edit** — title, notes, color/icon, dates, frequency (weekdays), reminder, tags, streaks, pause, delete
4. **Tags manage** — create/rename/delete tags
5. **Settings** — notification status, appearance, offline note, app preferences
6. **Onboarding / templates** — first-launch starter habit picker (skippable)
