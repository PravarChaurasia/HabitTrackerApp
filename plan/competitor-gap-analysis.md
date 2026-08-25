# Competitor gap analysis

Comparison of our plan against leading habit trackers (Streaks, Habitify, Productive, Loop Habit Tracker, Habitica, Way of Life, Strides, HabitNow) and the decisions taken. Everything below respects the hard rule: the app is **fully offline** — no internet, accounts, cloud sync, analytics, ads, or remote APIs.

## Decision

Fold all competitive **Must-have** functionality into the MVP where it can work offline. Keep offline-compatible extras in Phase 2. Never adopt cloud/social/gamification-cloud features.

## Feature matrix

| Feature | Leaders | Our decision |
|---------|---------|--------------|
| One-tap today complete | All | MVP Must (already) |
| Local reminders | Streaks, Loop, Habitify | MVP Must (already) |
| Categories / tags / areas | Habitify, HabitNow | MVP Must — tags (already) |
| Start / end date window | Less common | MVP Must (our strength) |
| Fully offline / no account | Loop-like | MVP Must (our differentiator) |
| Current + longest streak | Universal | MVP Must (promoted) |
| Weekday frequency (Mon/Wed/Fri) | Streaks, Habitify, Loop | MVP Must (promoted) |
| Habit color + icon | Streaks, Productive | MVP Must (added) |
| Onboarding templates | Most | MVP Must (added) |
| Cancel start reminder when done | Best practice | Must — start only; duration-end still fires |
| Custom start time + optional duration | Requested | Must (replaces time-of-day buckets) |
| Same-day delay / Change Time | Requested | Must — today only |
| Nx per week / monthly recurrence | Habitify, Strides | Phase 2 |
| Calendar heatmap / history | Loop, Habitify, Way of Life | Phase 2 |
| Stats (rate, trends) | Habitify, Loop, Strides | Phase 2 (on-device) |
| Skip / vacation / flexible streak | Streaks | Phase 2 |
| Time-of-day routine sections | Productive, Habitify | **Out** — use clock times instead |
| Widgets (Home / Lock Screen) | Streaks, Productive | Phase 2 (local data) |
| Siri Shortcuts | Streaks | Phase 2 (offline OK) |
| Apple Watch | Streaks | Phase 2 (peer/local) |
| Appearance (light/dark), haptics | Modern iOS | Phase 2 |
| Quantified habits (count/duration) | Strides, Done | Phase 2 |
| Avoidance / negative habits | Loop, Habitica | Phase 2 |
| Per-day completion note | Way of Life, Habitify | Phase 2 |
| Local export / import (AirDrop/file) | Way of Life | Phase 2 |
| Accounts, cloud sync, analytics, ads | Habitify, Productive | Never (offline rule) |
| Social / RPG (parties, battles) | Habitica | Never (offline rule) |
| Health / Fit cloud sync, Zapier/API | Habitify | Never (offline rule) |

## MVP Must additions (summary)

1. Current + longest streak, shown on Today and habit detail; derived from completions.
2. Weekday frequency: daily or specific weekdays (Mon–Sun multi-select).
3. Habit color + simple icon for visual identity.
4. First-launch templates: 4–6 offline starter presets, skippable.
5. Completing cancels remaining **start** reminders for that day; duration-end still fires.
6. Local calendar day boundary (DST-safe) for "today" and streak math.
7. Custom start time, optional duration-end (always), today-only delay / Change Time.

## Intentionally excluded (breaks offline rule)

- Accounts, iCloud / CloudKit, any SaaS backend
- Analytics, crash reporting, ads, remote config
- Social / gamification cloud, leaderboards
- Apple Health / Google Fit cloud sync, Zapier / public APIs

## Bottom line

With these Must additions the MVP matches Streaks/Loop-style core value (streaks, flexible schedules, visual identity, templates, smart local reminders) while staying fully offline. Cloud, social, and gamification-cloud remain out by design.
