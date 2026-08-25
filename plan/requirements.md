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
| Must | Custom **start time** (clock picker), not Morning / Afternoon / Evening buckets |
| Must | Local start notification at that time on every scheduled day |
| Must | Optional **duration**; when set, a second notification fires at `effective start + duration` |
| Must | Duration/end notification **always fires**, even if the habit was already completed |
| Must | Request notification permission on first reminder enable |
| Must | Updating the usual start time reschedules future days; delete/pause cancels pending notifications |
| Must | Completing the habit cancels remaining **start** reminders for that day, not the duration-end reminder |
| Must | From the start notification: Complete; Delay 15 min; Delay 1 hour; Change Time (opens app) |
| Must | Delay / Change Time apply to **today only**; tomorrow uses the usual start time |
| Must | Changing today’s start also shifts today’s duration-end by the same offset |

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
- Time-of-day list sections (Morning / Afternoon / Evening) — replaced by custom clock times
- Advanced recurrence (N times/week, every N days, monthly) — Phase 2
- Quantified habits, avoidance habits, per-day notes, heatmap — Phase 2
- One-off todos / Later inbox
- High-fidelity visual design / brand polish (wireframes are structural only)

## Screens (MVP)

1. **Today** — chronological checklist by effective start time; streak; complete; Delay / Change Time Today
2. **Habits** — all habits (color/icon, status, tags), tag filter chips, add habit
3. **Habit detail / edit** — title, notes, color/icon, dates, frequency, **start time**, optional **duration**, tags, streaks, pause, delete
4. **Same-day reschedule** — sheet: usual vs today’s time, delay chips, custom picker, restore usual
5. **Tags manage** — create/rename/delete tags
6. **Settings** — notification status, appearance, offline note, app preferences
7. **Onboarding / templates** — first-launch starter habit picker (skippable)
