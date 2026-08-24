# Habit Tracker — Planning

Product planning and pre-development analysis for the Habit Tracker iOS app. This folder is the source of truth; the interactive canvas mirrors it for side-by-side viewing.

## Scope (locked)

- Habits with color/icon, reminder, start/end date, and a daily or weekday schedule
- Current + longest streaks, tags with filtering, first-launch templates
- **Fully offline:** no internet / network communication of any kind (hard constraint)
- This pass: requirements + step-by-step flows + low-fidelity UI wireframes
- Not in this pass: iOS project, accounts, cloud sync, or "Later/Inbox" todos

## Documents

| File | Contents |
|------|----------|
| [requirements.md](requirements.md) | MVP requirements (Must / Should / Later), non-goals |
| [user-flows.md](user-flows.md) | Flows A–F, step-by-step |
| [ui-wireframes.md](ui-wireframes.md) | Screen inventory + wireframe specs |
| [data-model.md](data-model.md) | Habit / Tag / Completion fields and relationships |
| [competitor-gap-analysis.md](competitor-gap-analysis.md) | Comparison vs leading apps and decisions taken |
| [phase-2.md](phase-2.md) | Backlog and later tech stack notes |
| [canvas/habit-tracker-requirements.canvas.tsx](canvas/habit-tracker-requirements.canvas.tsx) | Source of the interactive visual board (portable copy) |

## Interactive canvas

The same content is rendered as an interactive canvas — requirements table, step-by-step flow cards, and low-fidelity phone wireframes for all MVP screens.

- **Portable copy (committed here):** [canvas/habit-tracker-requirements.canvas.tsx](canvas/habit-tracker-requirements.canvas.tsx)
- **Live location Cursor renders from:** `~/.cursor/projects/<workspace-id>/canvases/habit-tracker-requirements.canvas.tsx`

Cursor only compiles `.canvas.tsx` files inside its managed canvases directory, so the copy in this repo is the portable source and the managed directory holds the running instance.

### Restoring the canvas on a new machine

1. Open this project in Cursor so the workspace project folder is created.
2. Copy the canvas into the managed directory:

```sh
cp plan/canvas/habit-tracker-requirements.canvas.tsx \
  ~/.cursor/projects/<workspace-id>/canvases/
```

Replace `<workspace-id>` with the folder matching this workspace path (for example `Users-pravar-Habit-Tracker`); list `~/.cursor/projects/` to find it.

3. Open the copied file in Cursor to view the canvas beside chat.

Keep the two copies in sync: after editing the live canvas, copy it back into `plan/canvas/` so the committed version stays current.

## Convention

Any new analysis, decisions, or pre-development work from this project is written into this `plan/` folder (new markdown files or updates to the files above), not left only in chat.
