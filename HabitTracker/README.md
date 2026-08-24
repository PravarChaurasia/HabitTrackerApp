# Habit Tracker (iOS)

Fully offline SwiftUI + SwiftData habit tracker (MVP + Phase 2). Product requirements: [`../plan/`](../plan/).

## Requirements

- **Xcode 15+** with iOS 17 SDK (full Xcode.app from the Mac App Store)
- For **widgets / App Groups**: set a Development Team in Signing so `group.com.local.HabitTracker` can provision (simulator may still work with fallbacks)

## Open & run

1. Open `HabitTracker.xcodeproj` in Xcode.
2. Select the **HabitTracker** scheme and an iPhone simulator.
3. Set your **Team** under Signing & Capabilities (app + widget targets) if needed.
4. Press Run (⌘R).

## What’s included

### MVP
- Today checklist, tags + filter, streaks, color/icon, templates
- Daily or weekday schedules, local reminders, cancel-on-complete
- On-device SwiftData (`cloudKitDatabase: .none`)

### Phase 2 (this build)
- Advanced recurrence: every N days, N×/week, monthly
- Heatmap + Insights tab (completion rate, streaks)
- Skip / vacation days (streak forgiveness)
- Time-of-day sections (Morning / Afternoon / Evening / Anytime)
- Quantified habits (count / duration) and avoidance habits
- Per-day completion notes; multi-reminder times + snooze
- Archive + reorder habits
- Appearance (system / light / dark) + haptics on complete
- Local JSON export/import (Files / AirDrop)
- App Intents / Siri phrase: “Complete \<habit\> in Habit Tracker”
- Home Screen widget (reads App Group snapshot; offline)

### Not in this build
- **Apple Watch** companion (separate target — deferred)
- Cloud sync / accounts / analytics (forever out of scope)

## Offline rule

No networking APIs, no CloudKit, no analytics. Reminders are local notifications only.

## Layout

```
HabitTracker/
  HabitTracker.xcodeproj
  HabitTracker/          # app sources
  HabitTrackerWidget/    # WidgetKit extension
  README.md
  project.yml
```
