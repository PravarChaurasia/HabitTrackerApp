# Data model

Local-first, on-device storage only. No backend and no internet communication — habit, tag, and completion data never leave the device via the network.

## Entities

### Habit

| Field | Type | Notes |
|-------|------|-------|
| id | string | Unique identifier |
| title | string | Required |
| notes | string | Optional |
| color | string | Swatch color for visual identity (required) |
| icon | string | Symbol/icon name (required; from a bundled local set) |
| startDate | date | Required |
| endDate | date? | Optional; open-ended if absent |
| frequencyType | string | `daily` or `weekdays` for MVP |
| weekdays | int[] | Selected weekdays (1–7) when `frequencyType = weekdays` |
| reminderEnabled | bool | Whether a local notification is scheduled |
| reminderTime | time? | Time of day for the reminder |
| status | string | `active` / `paused` / `ended` |

### Tag

| Field | Type | Notes |
|-------|------|-------|
| id | string | Unique identifier |
| name | string | Required |
| color | string | Swatch color |

### Completion

| Field | Type | Notes |
|-------|------|-------|
| id | string | Unique identifier |
| habitId | string | Owning habit |
| date | date | The day completed |
| done | bool | Completed or not |

## Relationships

- A Habit has many Completions (one per completed day).
- A Habit has many Tags; a Tag applies to many Habits (many-to-many).
- Deleting a Habit deletes its Completions and cancels its notifications.
- Deleting a Tag unassigns it from Habits but does not delete the Habits.

```
Habit 1 ── * Completion
Habit * ── * Tag
```

## Derived values

- Current streak, longest streak, and "done this week" are computed from Completions, not stored, so edits and back-filled entries recompute correctly.
- A habit is shown on Today when it is `active`, the local day is within `[startDate, endDate]` (or no end date), and the weekday matches its schedule (`daily`, or `weekdays` contains today's weekday).

## Time & day boundary

- "Today" is the device's local calendar day; the app does not read network time.
- Streak and scheduling math use local day boundaries and are DST-safe (a day may be 23 or 25 hours).
- Completions are keyed by local calendar date.

## Storage & privacy

- All entities persist on-device only (SwiftData / Core Data). No data leaves the device over the network.
- Any future export/import is via local files or AirDrop, never cloud upload.
