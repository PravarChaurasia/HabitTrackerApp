# UI wireframes (low-fidelity)

Structural layouts only — regions, labels, and controls, not final visual design. Sample data is used so frames are never empty. The interactive canvas renders these as phone frames.

## Screen inventory

| Wireframe | Key UI elements |
|-----------|-----------------|
| Onboarding / templates | Starter habit templates with checkmarks, Add / Skip actions |
| Today | Date header, tag filter chip row (All + tags), habit rows with icon/color + checkbox + title + current streak, empty-state CTA + templates when no habits |
| Today — filtered | Same layout with one or more tags selected; list shows only matching, scheduled habits; clear-filter affordance |
| Habits | List of all habits (icon/color, status, tags), filter chips, `+` add button |
| Habits — filtered | Same with tag filter applied |
| Habit detail / edit | Title, notes, color + icon, start/end date pickers, frequency (daily / weekdays), reminder toggle + time, tag multi-select, current + longest streak, Pause, Delete |
| Tags manage | Tag list (name + color swatch), add / rename / delete |
| Settings | Notification permission status, appearance (system/light/dark), offline-only note, link to manage tags, about |

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
- Each row: habit icon in its color, checkbox (tap to complete, tap again to undo), habit title, current streak indicator
- Only habits scheduled for today (daily or matching weekday) within the date window appear
- Empty state: CTA to create the first habit plus the template picker

### Habits
- Full list independent of date window, showing icon/color, status (active/paused/ended) and tag chips per habit
- Filter chips identical to Today
- `+` opens Habit detail / edit in create mode

### Habit detail / edit
- Fields top to bottom: Title, Notes, Color + Icon, Start date, End date (optional), Frequency (daily or weekday multi-select), Reminder toggle + time picker, Tags (multi-select with inline "new tag"), Current + longest streak (read-only), Pause toggle, Delete (destructive, confirm)

### Tags manage
- List of tags with color swatch and name
- Add row at top or bottom; rename inline; delete with confirm (unassigns from habits)

### Settings
- Notification permission status with a button to open system settings when denied
- Link to Tags manage
- About / version placeholder
- Note that the app is offline-only (no account / no sync)
