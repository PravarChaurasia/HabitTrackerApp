# UI wireframes (low-fidelity)

Structural layouts only — regions, labels, and controls, not final visual design. Sample data is used so frames are never empty. The interactive canvas renders these as phone frames.

## Screen inventory

| Wireframe | Key UI elements |
|-----------|-----------------|
| Onboarding / templates | Starter habit templates with checkmarks, Add / Skip actions |
| Today | Date header, tag filter chips, habits sorted by **custom start time**, start–end window, streak, Delay / Change Time Today, empty-state CTA |
| Today — filtered | Same with tag filter applied |
| Habits | List of all habits (icon/color, status, tags), filter chips, `+` add button |
| Habits — filtered | Same with tag filter applied |
| Habit detail / edit | Title, notes, color + icon, dates, frequency, **Start time**, optional **Duration** (end reminder always fires), tags, streaks, Pause, Delete |
| Same-day reschedule | Usual time vs today’s time; Delay 15 / Delay 1h; custom picker; Restore usual time |
| Tags manage | Tag list (name + color swatch), add / rename / delete |
| Settings | Notification permission status, appearance (system/light/dark), offline-only note, about |

## Fidelity rules

- Flat blocks and text labels only; no gradients, mock photos, or branded styling
- Goal is structure and hierarchy for review before SwiftUI work

## Screen notes

### Onboarding / templates
- Shown on first launch; grid/list of 4–6 starter habits with icon + color
- Tap to select; primary "Add selected" and secondary "Skip" actions
- Fully local — no network, no account

### Today
- Top: current date, optional weekday strip
- Filter chips: `All` selected by default, then one chip per tag
- Each row: habit icon in its color, checkbox, title, **07:30–08:15** (or start only), current streak
- Sorted by effective start (usual time or today’s override). No Morning/Afternoon/Evening sections
- “Today changed” when delayed or custom time applied
- Empty state: CTA to create the first habit plus the template picker

### Habits
- Full list independent of date window, showing icon/color, status (active/paused/ended) and tag chips per habit
- Filter chips identical to Today
- `+` opens Habit detail / edit in create mode

### Habit detail / edit
- Fields: Title, Notes, Color + Icon, Start date, End date (optional), Frequency, **Start time**, optional **Duration** (hours/minutes; copy: end reminder always fires), Tags, Current + longest streak, Pause, Delete

### Same-day reschedule
- Shown from Today or from the notification **Change Time** action
- Usual start vs today’s effective start
- Delay 15 min, Delay 1 hour, custom time picker
- Restore usual time (clears today’s override)

### Tags manage
- List of tags with color swatch and name
- Add row at top or bottom; rename inline; delete with confirm (unassigns from habits)

### Settings
- Notification permission status with a button to open system settings when denied
- Link to Tags manage
- About / version placeholder
- Note that the app is offline-only (no account / no sync)
