# Phase 2 backlog & tech direction

## Hard constraint (all phases)

The app **must never communicate with the internet**. Phase 2 features stay on-device / offline-only. No iCloud, CloudKit, accounts, analytics, or remote APIs — ever, unless this constraint is explicitly revised.

## Backlog (post-MVP)

- Advanced recurrence: every N days, N times per week, monthly (weekday selection ships in MVP)
- Calendar / heatmap history view per habit
- On-device insights: completion rate, weekly/monthly trends
- Skip / vacation days that do not break a streak (streak forgiveness)
- Home screen and Lock Screen widgets (local data only)
- Siri Shortcuts / App Intents to log a habit without opening the app (offline)
- Apple Watch companion (local / WatchConnectivity peer transfer only — no cloud)
- Appearance options (system / light / dark) and haptic feedback on completion
- Quantified habits (target count or duration, e.g. 8 glasses, 30 min)
- Avoidance / negative habits ("did not do X")
- Per-day completion note / short journal entry
- Extra reminder times beyond start + duration-end
- Habit archiving and reordering
- Local data export/import (file share / AirDrop — not cloud upload)

Custom start time, duration-end reminder, and today-only delay/change-time are **current product rules** (not Phase 2). Time-of-day buckets (Morning / Afternoon / Evening) are **removed**.

## Explicitly out of scope (violates offline rule)

- iCloud / CloudKit sync
- Any SaaS backend, account system, or remote analytics

## Technical direction (for later build — documented only)

- **Stack:** SwiftUI + SwiftData (or Core Data) + UserNotifications
- **Storage:** on-device only for all phases; no network-backed persistence
- **Architecture:** simple MVVM with a `HabitStore` and a `ReminderScheduler`
- **Notifications:** `UNUserNotificationCenter` with per-habit calendar triggers; reschedule on edit, cancel on pause/delete
- **Networking:** none — no `URLSession` feature use, no third-party network SDKs
