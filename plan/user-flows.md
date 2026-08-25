# User flows

Step-by-step flows for the MVP. Each references the screens in [ui-wireframes.md](ui-wireframes.md).

## A. First launch (with templates)

1. Open app → onboarding shows 4–6 built-in starter templates (e.g. Drink water, Walk, Read)
2. User taps templates to add, edits any details, or taps Skip
3. Land on Today; if reminders are enabled → system permission prompt
4. Empty Today (if all skipped) shows a "Add your first habit" CTA plus the template picker

## B. Create habit

1. Habits → `+` Add
2. Enter title; pick color and icon
3. Set start date (default today); optional end date
4. Choose frequency: daily or specific weekdays (Mon–Sun)
5. Toggle reminder → pick **custom start time** → optional duration (end reminder always fires) → permission if needed
6. Attach existing tags and/or create a new tag
7. Save → appears on Today if in the date window, scheduled today, and active

## C. Daily check-in

1. Open Today (optionally apply a tag filter); rows are sorted by effective start time, showing start–end window
2. Tap habit → mark complete (undo supported); streak updates
3. Completing cancels remaining **start** reminders for today; **duration-end still fires**
4. Start notification actions: Complete · Delay 15 min · Delay 1 hour · Change Time (opens same-day sheet)
5. Delay / Change Time shift today’s start and end; tomorrow uses the usual start time

## D. Filter by tag

1. On Today or Habits, tap filter chips
2. Select one or more tags
3. List shows habits with any of those tags
4. Clear filter → All

## E. Edit / end habit

1. Open habit → edit fields, tags, reminder
2. Set an end date or Pause → drops off Today and cancels future reminders
3. Delete → confirm → removes habit + completions + notifications

## F. Manage tags

1. From the habit editor or the Tags screen → create / rename / delete
2. Deleting a tag unassigns it from habits (habits remain)

## G. Delay / Change Time today

1. From the start notification or Today, choose Delay 15 min, Delay 1 hour, or Change Time
2. Change Time opens the same-day reschedule sheet (usual vs today; restore usual)
3. Today’s start and duration-end shift by the same offset
4. Tomorrow uses the usual start time again (override is not reused)

## Flow-to-screen map

| Flow | Primary screen(s) |
|------|-------------------|
| A. First launch | Onboarding / templates, Today |
| B. Create habit | Habit detail / edit |
| C. Daily check-in | Today, Same-day reschedule, notifications |
| D. Filter by tag | Today (filtered), Habits (filtered) |
| E. Edit / end habit | Habit detail / edit |
| F. Manage tags | Tags manage, Habit detail / edit |
| G. Delay / Change Time today | Same-day reschedule, start notification |
