import {
  Stack,
  Row,
  Grid,
  Divider,
  Spacer,
  H1,
  H2,
  H3,
  Text,
  Code,
  Pill,
  Stat,
  Table,
  Callout,
  Card,
  CardHeader,
  CardBody,
  CollapsibleSection,
  useHostTheme,
  type CanvasHostTheme,
} from "cursor/canvas";
import type { CSSProperties, ReactNode } from "react";

const MUST = "Must";
const SHOULD = "Should";
const LATER = "Later";

function priorityTone(p: string): "success" | "warning" | "info" {
  if (p === MUST) return "success";
  if (p === SHOULD) return "warning";
  return "info";
}

function SectionLabel({ children }: { children: ReactNode }) {
  const t = useHostTheme();
  return (
    <Text
      size="small"
      weight="semibold"
      style={{ color: t.text.tertiary, letterSpacing: 0.6, textTransform: "uppercase" }}
    >
      {children}
    </Text>
  );
}

// ---------- Wireframe primitives ----------

function PhoneFrame({
  title,
  caption,
  children,
}: {
  title: string;
  caption?: string;
  children: ReactNode;
}) {
  const t = useHostTheme();
  return (
    <Stack gap={6} style={{ width: 240 }}>
      <Row gap={6} align="center">
        <Text weight="semibold" size="small">
          {title}
        </Text>
      </Row>
      <div
        style={{
          border: `1px solid ${t.stroke.secondary}`,
          borderRadius: 18,
          background: t.bg.editor,
          padding: 10,
          height: 380,
          display: "flex",
          flexDirection: "column",
        }}
      >
        <div
          style={{
            width: 44,
            height: 4,
            borderRadius: 999,
            background: t.stroke.secondary,
            margin: "2px auto 8px",
          }}
        />
        <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: 6, overflow: "hidden" }}>
          {children}
        </div>
      </div>
      {caption ? (
        <Text size="small" tone="tertiary">
          {caption}
        </Text>
      ) : null}
    </Stack>
  );
}

function WBar({ w = "100%", h = 12, tone }: { w?: number | string; h?: number; tone?: "accent" | "fill" }) {
  const t = useHostTheme();
  const bg = tone === "accent" ? t.accent.primary : t.fill.tertiary;
  return <div style={{ width: w, height: h, borderRadius: 4, background: bg }} />;
}

function WChips({ theme, chips }: { theme: CanvasHostTheme; chips: { label: string; active?: boolean }[] }) {
  return (
    <Row gap={4} wrap>
      {chips.map((c) => (
        <span
          key={c.label}
          style={{
            fontSize: 10,
            lineHeight: "14px",
            padding: "2px 7px",
            borderRadius: 999,
            border: `1px solid ${c.active ? theme.accent.primary : theme.stroke.secondary}`,
            background: c.active ? theme.accent.primary : "transparent",
            color: c.active ? theme.text.onAccent : theme.text.secondary,
          }}
        >
          {c.label}
        </span>
      ))}
    </Row>
  );
}

function WHabitRow({
  theme,
  label,
  done,
  meta,
  color,
}: {
  theme: CanvasHostTheme;
  label: string;
  done?: boolean;
  meta?: string;
  color?: string;
}) {
  return (
    <Row gap={8} align="center">
      <div
        style={{
          width: 16,
          height: 16,
          borderRadius: 5,
          border: `1.5px solid ${done ? theme.accent.primary : theme.stroke.secondary}`,
          background: done ? theme.accent.primary : "transparent",
          flexShrink: 0,
        }}
      />
      {color ? (
        <div style={{ width: 8, height: 8, borderRadius: 999, background: color, flexShrink: 0 }} />
      ) : null}
      <Stack gap={2} style={{ flex: 1, minWidth: 0 }}>
        <Text
          size="small"
          truncate
          style={done ? { color: theme.text.tertiary, textDecoration: "line-through" } : undefined}
        >
          {label}
        </Text>
        {meta ? (
          <Text size="small" tone="tertiary" style={{ fontSize: 10 }}>
            {meta}
          </Text>
        ) : null}
      </Stack>
    </Row>
  );
}

function WField({ theme, label, value, accent }: { theme: CanvasHostTheme; label: string; value: string; accent?: boolean }) {
  return (
    <Stack gap={3}>
      <Text size="small" tone="tertiary" style={{ fontSize: 10 }}>
        {label}
      </Text>
      <div
        style={{
          border: `1px solid ${theme.stroke.secondary}`,
          borderRadius: 6,
          padding: "5px 8px",
          background: theme.fill.quaternary,
        }}
      >
        <Text size="small" style={accent ? { color: theme.accent.primary } : undefined}>
          {value}
        </Text>
      </div>
    </Stack>
  );
}

function SmallCaps({ children }: { children: ReactNode }) {
  const t = useHostTheme();
  return (
    <Text size="small" weight="semibold" style={{ color: t.text.tertiary, fontSize: 10, letterSpacing: 0.4 }}>
      {children}
    </Text>
  );
}

// ---------- Wireframe screens ----------

function TodayFrame({ filtered }: { filtered?: boolean }) {
  const t = useHostTheme();
  return (
    <PhoneFrame
      title={filtered ? "Today — filtered" : "Today"}
      caption={filtered ? "Tag filter: Health selected" : "Daily checklist + tag filter"}
    >
      <Row align="center">
        <Text weight="semibold" size="small">
          Today
        </Text>
        <Spacer />
        <Text size="small" tone="tertiary" style={{ fontSize: 10 }}>
          Fri, Aug 7
        </Text>
      </Row>
      <WChips
        theme={t}
        chips={[
          { label: "All", active: !filtered },
          { label: "Health", active: filtered },
          { label: "Work" },
          { label: "Personal" },
        ]}
      />
      <Divider />
      <WHabitRow theme={t} label="Drink water" meta="07:30 · 15 min · streak 4" color="#4f9dde" done />
      <WHabitRow theme={t} label="Morning walk" meta="07:30–08:15 · Today 08:00 · streak 2" color="#a3be8c" />
      {!filtered ? <WHabitRow theme={t} label="Read 20 min" meta="21:00 · streak 9" color="#b48ead" /> : null}
      {!filtered ? <WHabitRow theme={t} label="Standup notes" meta="09:00–09:30 · streak 1" color="#d08770" /> : null}
      <Spacer />
      <SmallCaps>{filtered ? "Showing habits tagged Health" : "Sorted by start time · Delay / Change Time Today"}</SmallCaps>
    </PhoneFrame>
  );
}

function HabitsFrame({ filtered }: { filtered?: boolean }) {
  const t = useHostTheme();
  return (
    <PhoneFrame title={filtered ? "Habits — filtered" : "Habits"} caption="All habits + add">
      <Row align="center">
        <Text weight="semibold" size="small">
          Habits
        </Text>
        <Spacer />
        <div
          style={{
            width: 20,
            height: 20,
            borderRadius: 6,
            background: t.accent.primary,
            color: t.text.onAccent,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 13,
          }}
        >
          +
        </div>
      </Row>
      <WChips
        theme={t}
        chips={[
          { label: "All", active: !filtered },
          { label: "Work", active: filtered },
          { label: "Health" },
        ]}
      />
      <Divider />
      <WHabitRow theme={t} label="Morning walk" meta="07:30 · 45 min · Health" color="#a3be8c" />
      {!filtered ? <WHabitRow theme={t} label="Drink water" meta="07:30 · Health" color="#4f9dde" /> : null}
      <WHabitRow theme={t} label="Standup notes" meta="09:00 · Work" color="#d08770" />
      <WHabitRow theme={t} label="Inbox zero" meta="paused · Work" color="#d08770" />
      {!filtered ? <WHabitRow theme={t} label="Read 20 min" meta="21:00 · Personal" color="#b48ead" /> : null}
      <Spacer />
      <SmallCaps>{filtered ? "Filter: Work" : "Filter view-only — data unchanged"}</SmallCaps>
    </PhoneFrame>
  );
}

function EditFrame() {
  const t = useHostTheme();
  return (
    <PhoneFrame title="Habit detail / edit" caption="Create & edit fields">
      <Row align="center">
        <Text size="small" tone="tertiary">
          Cancel
        </Text>
        <Spacer />
        <Text weight="semibold" size="small">
          New habit
        </Text>
        <Spacer />
        <Text size="small" style={{ color: t.accent.primary }}>
          Save
        </Text>
      </Row>
      <Divider />
      <Row gap={8} align="center">
        <div style={{ width: 22, height: 22, borderRadius: 6, background: "#4f9dde", flexShrink: 0 }} />
        <div style={{ flex: 1 }}>
          <WField theme={t} label="Title · color + icon" value="Morning walk" />
        </div>
      </Row>
      <Row gap={6}>
        <div style={{ flex: 1 }}>
          <WField theme={t} label="Start" value="Aug 7" />
        </div>
        <div style={{ flex: 1 }}>
          <WField theme={t} label="End (optional)" value="—" />
        </div>
      </Row>
      <Stack gap={3}>
        <Text size="small" tone="tertiary" style={{ fontSize: 10 }}>
          Frequency
        </Text>
        <WChips
          theme={t}
          chips={[
            { label: "Daily" },
            { label: "M", active: true },
            { label: "W", active: true },
            { label: "F", active: true },
          ]}
        />
      </Stack>
      <Row align="center">
        <Text size="small">Start time</Text>
        <Spacer />
        <span style={{ fontSize: 10, color: t.accent.primary }}>07:30</span>
      </Row>
      <Row gap={6}>
        <div style={{ flex: 1 }}>
          <WField theme={t} label="Duration (optional)" value="45 min" />
        </div>
        <div style={{ flex: 1 }}>
          <WField theme={t} label="End reminder" value="08:15 always" accent />
        </div>
      </Row>
      <Stack gap={3}>
        <Text size="small" tone="tertiary" style={{ fontSize: 10 }}>
          Tags
        </Text>
        <WChips theme={t} chips={[{ label: "Health", active: true }, { label: "+ New" }]} />
      </Stack>
      <Spacer />
      <Row align="center">
        <Text size="small" style={{ color: t.text.tertiary }}>
          Streak 12 · best 21
        </Text>
        <Spacer />
        <Text size="small" style={{ color: t.text.tertiary }}>
          Pause · Delete
        </Text>
      </Row>
    </PhoneFrame>
  );
}

function TemplatesFrame() {
  const t = useHostTheme();
  const tpl = (label: string, on?: boolean) => (
    <Row gap={8} align="center">
      <div
        style={{
          width: 16,
          height: 16,
          borderRadius: 5,
          border: `1.5px solid ${on ? t.accent.primary : t.stroke.secondary}`,
          background: on ? t.accent.primary : "transparent",
          flexShrink: 0,
        }}
      />
      <Text size="small">{label}</Text>
    </Row>
  );
  return (
    <PhoneFrame title="Onboarding / templates" caption="First launch · skippable">
      <Text weight="semibold" size="small">
        Start with a few habits
      </Text>
      <Divider />
      {tpl("Drink water", true)}
      {tpl("Morning walk", true)}
      {tpl("Read 20 min")}
      {tpl("Meditate")}
      {tpl("Stretch")}
      <Spacer />
      <Row gap={6} align="center">
        <div
          style={{
            padding: "4px 10px",
            borderRadius: 6,
            background: t.accent.primary,
            color: t.text.onAccent,
            fontSize: 11,
          }}
        >
          Add selected
        </div>
        <Text size="small" tone="tertiary">
          Skip
        </Text>
      </Row>
    </PhoneFrame>
  );
}

function TagsFrame() {
  const t = useHostTheme();
  const swatch = (c: string) => (
    <div style={{ width: 12, height: 12, borderRadius: 4, background: c, flexShrink: 0 }} />
  );
  return (
    <PhoneFrame title="Tags manage" caption="Create / rename / delete">
      <Row align="center">
        <Text weight="semibold" size="small">
          Tags
        </Text>
        <Spacer />
        <Text size="small" style={{ color: t.accent.primary }}>
          + Add
        </Text>
      </Row>
      <Divider />
      <Row gap={8} align="center">
        {swatch("#4f9dde")}
        <Text size="small">Health</Text>
      </Row>
      <Row gap={8} align="center">
        {swatch("#d08770")}
        <Text size="small">Work</Text>
      </Row>
      <Row gap={8} align="center">
        {swatch("#a3be8c")}
        <Text size="small">Focus</Text>
      </Row>
      <Row gap={8} align="center">
        {swatch("#b48ead")}
        <Text size="small">Personal</Text>
      </Row>
      <Spacer />
      <SmallCaps>Delete unassigns from habits</SmallCaps>
    </PhoneFrame>
  );
}

function SettingsFrame() {
  const t = useHostTheme();
  const row = (label: string, value: string, accent?: boolean) => (
    <Row align="center">
      <Text size="small">{label}</Text>
      <Spacer />
      <Text size="small" style={{ color: accent ? t.accent.primary : t.text.tertiary, fontSize: 11 }}>
        {value}
      </Text>
    </Row>
  );
  return (
    <PhoneFrame title="Settings" caption="Permissions & prefs">
      <Text weight="semibold" size="small">
        Settings
      </Text>
      <Divider />
      <SmallCaps>Notifications</SmallCaps>
      {row("Permission", "Allowed", true)}
      {row("Open system settings", "›")}
      <Divider />
      <SmallCaps>Organize</SmallCaps>
      {row("Manage tags", "›")}
      <Divider />
      <SmallCaps>About</SmallCaps>
      {row("Version", "0.1.0")}
      <Spacer />
      <SmallCaps>Offline · on-device only</SmallCaps>
    </PhoneFrame>
  );
}

function NotificationFrame() {
  const t = useHostTheme();
  return (
    <PhoneFrame title="Start notification" caption="Actions on the lock screen">
      <SmallCaps>7:30 AM</SmallCaps>
      <Text weight="semibold" size="small">
        Morning walk
      </Text>
      <Text size="small" tone="tertiary">
        Start now · ends 8:15 even if you check off
      </Text>
      <Divider />
      <WChips
        theme={t}
        chips={[
          { label: "Complete", active: true },
          { label: "Delay 15 min" },
          { label: "Delay 1 hour" },
          { label: "Change Time" },
        ]}
      />
      <Spacer />
      <SmallCaps>Delay / Change Time = today only</SmallCaps>
    </PhoneFrame>
  );
}

function RescheduleFrame() {
  const t = useHostTheme();
  return (
    <PhoneFrame title="Change Time Today" caption="Does not change tomorrow">
      <Text weight="semibold" size="small">
        Morning walk
      </Text>
      <WField theme={t} label="Usual start" value="07:30" />
      <WField theme={t} label="Today" value="08:00" accent />
      <WField theme={t} label="End today" value="08:45 (shifted)" />
      <WChips theme={t} chips={[{ label: "+15 min" }, { label: "+1 hour" }, { label: "Restore 07:30" }]} />
      <Spacer />
      <SmallCaps>Tomorrow returns to 07:30</SmallCaps>
    </PhoneFrame>
  );
}

// ---------- Flows ----------

const FLOWS: { id: string; title: string; steps: string[] }[] = [
  {
    id: "A",
    title: "A. First launch",
    steps: [
      "Open app → Today (empty)",
      'CTA: "Add your first habit"',
      "Enabling a reminder later → system permission prompt",
    ],
  },
  {
    id: "B",
    title: "B. Create habit",
    steps: [
      "Habits → + Add",
      "Enter title; set start date (default today); optional end date",
      "Toggle reminder → pick custom start time → optional duration (end always fires)",
      "Attach existing tags and/or create a new tag",
      "Save → appears on Today if start ≤ today ≤ end and active",
    ],
  },
  {
    id: "C",
    title: "C. Daily check-in",
    steps: [
      "Open Today — habits sorted by start time",
      "Tap habit → mark complete (undo supported)",
      "Start notification: Complete · Delay 15 · Delay 1h · Change Time",
      "Complete cancels start reminders; duration-end still fires",
    ],
  },
  {
    id: "D",
    title: "D. Filter by tag",
    steps: [
      "On Today or Habits, tap filter chips",
      "Select one or more tags",
      "List shows habits with any of those tags",
      "Clear filter → All",
    ],
  },
  {
    id: "E",
    title: "E. Edit / end habit",
    steps: [
      "Open habit → edit fields, tags, reminder",
      "Set an end date or Pause → drops off Today, cancels future reminders",
      "Delete → confirm → removes habit + completions + notifications",
    ],
  },
  {
    id: "F",
    title: "F. Manage tags",
    steps: [
      "From the habit editor or Tags screen → create / rename / delete",
      "Deleting a tag unassigns it from habits (habits remain)",
    ],
  },
  {
    id: "G",
    title: "G. Delay / Change Time today",
    steps: [
      "From notification or Today, Delay 15 / Delay 1 hour or pick a custom time",
      "Today’s start and duration-end shift by the same offset",
      "Tomorrow uses the usual start time again",
    ],
  },
];

function FlowCard({ flow }: { flow: (typeof FLOWS)[number] }) {
  const t = useHostTheme();
  return (
    <Card>
      <CardHeader>{flow.title}</CardHeader>
      <CardBody>
        <Stack gap={6}>
          {flow.steps.map((s, i) => (
            <div key={i}>
              <Row gap={8} align="start">
                <div
                  style={{
                    width: 18,
                    height: 18,
                    borderRadius: 999,
                    background: t.fill.tertiary,
                    color: t.text.secondary,
                    fontSize: 11,
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    flexShrink: 0,
                  }}
                >
                  {i + 1}
                </div>
                <Text size="small">{s}</Text>
              </Row>
            </div>
          ))}
        </Stack>
      </CardBody>
    </Card>
  );
}

// ---------- Requirements data ----------

const REQ_ROWS: [string, string, string][] = [
  ["Offline", "No internet / network communication of any kind", MUST],
  ["Offline", "No accounts, cloud APIs, analytics, ads, iCloud, or remote config", MUST],
  ["Offline", "All data on-device; reminders are local notifications only", MUST],
  ["Habits", "Create / edit / delete; title + start date required", MUST],
  ["Habits", "Color + simple icon for visual identity", MUST],
  ["Habits", "Optional end date, notes, reminder, tags", MUST],
  ["Schedule", "Daily or specific weekdays (Mon–Sun)", MUST],
  ["Schedule", "Local calendar day boundary; DST-safe streak math", MUST],
  ["Streaks", "Current streak on Today; current + longest on detail", MUST],
  ["Streaks", "Derived from completion history (recompute on edit)", MUST],
  ["Onboarding", "First-launch starter templates (local, skippable)", MUST],
  ["Reminders", "Custom start time on every scheduled day (not AM/PM buckets)", MUST],
  ["Reminders", "Optional duration; end reminder at start + duration always fires", MUST],
  ["Reminders", "Permission on first enable; reschedule on edit; cancel on pause/delete", MUST],
  ["Reminders", "Complete cancels start reminders only; duration-end still fires", MUST],
  ["Reminders", "Delay 15 / Delay 1h / Change Time apply to today only", MUST],
  ["Tags & filter", "Create tags; assign 0..n per habit; filter (match any)", MUST],
  ["Today", "Scheduled + filtered checklist; complete / undo", MUST],
  ["Habits", "Complete past days in range; pause / resume", SHOULD],
  ["Tracking", "Done-this-week count; calendar / heatmap history", LATER],
];

const DATA_ROWS: [string, string][] = [
  ["Habit", "title, color, icon, dates, frequency, startTime, durationMinutes?, status"],
  ["Tag", "name, color"],
  ["Completion", "habitId, date, done"],
  ["DayOverride", "habitId, date, overrideTime (today only)"],
];

const PHASE2 = [
  "Advanced recurrence (every N days, N×/week, monthly)",
  "Calendar heatmap + on-device insights",
  "Skip / vacation days (streak forgiveness)",
  "Widgets, Siri Shortcuts, Apple Watch (all offline)",
  "Appearance (light/dark) + haptics on complete",
  "Quantified & avoidance habits; per-day notes",
  "Local data export / import (file share / AirDrop)",
];

// ---------- Page ----------

export default function HabitTrackerPlan() {
  const t = useHostTheme();
  const panel: CSSProperties = {
    border: `1px solid ${t.stroke.tertiary}`,
    borderRadius: 8,
    padding: 14,
    background: t.bg.chrome,
  };

  return (
    <Stack gap={24} style={{ padding: 24, maxWidth: 1120, margin: "0 auto" }}>
      {/* Header */}
      <Stack gap={10}>
        <Row gap={10} align="center" wrap>
          <H1>Habit Tracker — Product Plan</H1>
          <Pill active>iOS · MVP</Pill>
        </Row>
        <Text tone="secondary" style={{ maxWidth: 720 }}>
          A fully offline iOS habit tracker: custom start time, optional duration with an end
          reminder that always fires, same-day delay or Change Time, tags, and streaks. Morning /
          Afternoon / Evening buckets are not used. The app never communicates with the internet.
        </Text>
        <Row gap={8} wrap>
          <Pill active>Custom start · duration-end · today-only delay</Pill>
          <Pill active>Hard rule: no internet</Pill>
          <Pill>Canonical repo: /Users/pravar/Apps/HabitTrackerApp</Pill>
        </Row>
        <Callout tone="warning" title="Offline-only (hard constraint)">
          The app must never communicate with the internet — no accounts, analytics, ads, iCloud /
          CloudKit, or remote APIs. All habit data stays on-device; reminders use local notifications
          only. Phase 2 stays offline as well.
        </Callout>
      </Stack>

      {/* Stats */}
      <Grid columns={4} gap={12}>
        <Stat value="10" label="Wireframes" />
        <Stat value="4" label="Data entities" />
        <Stat value="18" label="Must-have reqs" tone="success" />
        <Stat value="7" label="User flows" tone="info" />
      </Grid>

      <Divider />

      {/* Wireframes */}
      <Stack gap={12}>
        <Stack gap={4}>
          <SectionLabel>Pre-development UI</SectionLabel>
          <H2>Low-fidelity wireframes</H2>
          <Text tone="secondary">
            Structure and hierarchy only — regions, labels, and controls, not final visual design.
            Sample data shown so nothing renders empty.
          </Text>
        </Stack>
        <Row gap={20} wrap align="start">
          <TemplatesFrame />
          <TodayFrame />
          <TodayFrame filtered />
          <HabitsFrame />
          <HabitsFrame filtered />
          <EditFrame />
          <NotificationFrame />
          <RescheduleFrame />
          <TagsFrame />
          <SettingsFrame />
        </Row>
        <Callout tone="info" title="Reminders (locked)">
          Start at a custom clock time every scheduled day. Optional duration fires an end reminder at
          start + duration even if already complete. Delay 15 min, Delay 1 hour, and Change Time apply
          to today only.
        </Callout>
      </Stack>

      <Divider />

      {/* Requirements */}
      <Stack gap={12}>
        <Stack gap={4}>
          <SectionLabel>What we build</SectionLabel>
          <H2>Requirements</H2>
        </Stack>
        <Table
          headers={["Area", "Requirement", "Priority"]}
          columnAlign={["left", "left", "left"]}
          rowTone={REQ_ROWS.map(([, , p]) => priorityTone(p))}
          rows={REQ_ROWS.map(([area, req, p]) => [
            area,
            req,
            <Pill active={p === MUST}>{p}</Pill>,
          ])}
        />
        <Row gap={16} wrap>
          <Text size="small" tone="tertiary">
            Priority: Must = MVP required · Should = if time allows · Later = Phase 2+
          </Text>
        </Row>
      </Stack>

      {/* Flows */}
      <Stack gap={12}>
        <Stack gap={4}>
          <SectionLabel>How it's used</SectionLabel>
          <H2>Step-by-step flows</H2>
        </Stack>
        <Grid columns={3} gap={12}>
          {FLOWS.map((f) => (
            <div key={f.id}>
              <FlowCard flow={f} />
            </div>
          ))}
        </Grid>
      </Stack>

      <Divider />

      {/* Data model + Phase 2 */}
      <Grid columns="1fr 1fr" gap={20}>
        <Stack gap={12}>
          <Stack gap={4}>
            <SectionLabel>Structure</SectionLabel>
            <H3>Data model</H3>
          </Stack>
          <Table
            headers={["Entity", "Fields (MVP)"]}
            columnAlign={["left", "left"]}
            rows={DATA_ROWS.map(([e, f]) => [<Code>{e}</Code>, f])}
          />
          <Text size="small" tone="tertiary">
            Habit 1—* Completion · Habit 1—* DayOverride · Habit *—* Tag. Completing cancels start
            reminders only; duration-end still fires.
          </Text>
        </Stack>

        <Stack gap={12}>
          <Stack gap={4}>
            <SectionLabel>Backlog</SectionLabel>
            <H3>Phase 2</H3>
          </Stack>
          <div style={panel}>
            <Stack gap={8}>
              {PHASE2.map((item) => (
                <div key={item}>
                  <Row gap={8} align="start">
                    <div
                      style={{
                        width: 5,
                        height: 5,
                        borderRadius: 999,
                        background: t.accent.primary,
                        marginTop: 7,
                        flexShrink: 0,
                      }}
                    />
                    <Text size="small">{item}</Text>
                  </Row>
                </div>
              ))}
            </Stack>
          </div>
          <CollapsibleSection title="Tech direction (for later build)">
            <Stack gap={4}>
              <Text size="small">SwiftUI + SwiftData (or Core Data) + UserNotifications</Text>
              <Text size="small">On-device storage only — no iCloud, CloudKit, or remote APIs</Text>
              <Text size="small">MVVM with a HabitStore and a ReminderScheduler; no networking</Text>
            </Stack>
          </CollapsibleSection>
        </Stack>
      </Grid>

      <Divider />
      <Text size="small" tone="tertiary">
        Source of truth: /Users/pravar/Apps/HabitTrackerApp/plan · Custom start + duration-end ·
        Hard rule: no internet communication
      </Text>
    </Stack>
  );
}
