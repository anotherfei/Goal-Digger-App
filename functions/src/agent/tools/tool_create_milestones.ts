// functions/src/agent/tools/tool_create_milestones.ts
//
// Task Generation Agent (architecture §6.2). Produces a fully structured,
// AI-decided milestone roadmap for a goal: the MODEL decides how many
// milestones the goal genuinely needs, and for each one it decides the
// title, the realistic duration, the load, and which day to schedule it on.
//
// What stays deterministic (and why): hard SAFETY RAILS only —
//   • ABSOLUTE_MAX caps the count so a bad model response can't blow the
//     output-token budget or flood the user with tasks;
//   • durations are clamped to 5–90 min and dayOffsets to the deadline window
//     (§9.5) so nothing the model returns can land past the deadline;
//   • an explicit user count ("10 milestones") is honored/scaled with a
//     yes/no confirmation when unrealistic — UX, not a generation decision;
//   • staticFallback() runs only when the model is unavailable.
// Everything that is a judgement call — count, sizing, load, day placement —
// is the model's.

import { getAI, defaultModel } from "../../ai";
import { evaluateGoal, goalGuardMessage } from "../goal_guard";
import { parseModelJson } from "../../json";

// Soft guidance for how many milestone-sized chunks a motivated person can
// take on per day, and the absolute ceiling we will ever generate (protects
// the output-token budget even when the user forces a large request).
const FEASIBLE_PER_DAY = 3;
const ABSOLUTE_MAX = 60;

export type MilestoneLoad = "light" | "focus" | "stretch";

export interface MilestoneTask {
  title: string;
  durationMinutes: number;
  load: MilestoneLoad;
  dayOffset: number; // 0 = today
}

interface CreateMilestonesArgs {
  goal?: string;
  durationDays?: number;
  specialRequest?: string;
  // Set true when the user has explicitly confirmed an unrealistic request
  // (answered "yes" to the feasibility question). Honors the full ask.
  force?: boolean;
  context?: {
    deadline?: string; // ISO date string
    startDate?: string; // ISO date string
    durationDays?: number;
    deadlineDays?: number; // days-until-deadline (convention used by the other tools)
    category?: string;
    priority?: number; // 1–5
    mood?: string;
    specialRequest?: string; // free-form user instructions, e.g. "2 milestones per day"
    force?: boolean; // user confirmed an unrealistic request
    notes?: string;
    [key: string]: unknown;
  };
}

interface MilestoneResult {
  milestones: string[]; // titles only — kept for backward compatibility
  tasks: MilestoneTask[]; // structured, AI-decided tasks (title + duration + load + day)
  count: number;
  durationDays: number | null;
  requestedCount: number | null;
  feasibilityNote: string | null;
  // True when we scaled the request back and are asking the user to confirm
  // (yes/no) whether they still want the full, unrealistic amount.
  needsConfirmation: boolean;
  honoredRequest: boolean;
}

// ── Duration resolution ─────────────────────────────────────────────────────

function resolveDurationDays(args: CreateMilestonesArgs): number | null {
  const ctx = args.context ?? {};

  // deadlineDays is the field analyzeHabits / scheduleTasks already read.
  const explicit = args.durationDays ?? ctx.durationDays ?? ctx.deadlineDays;
  if (typeof explicit === "number" && isFinite(explicit) && explicit > 0) {
    return Math.round(explicit);
  }

  if (ctx.deadline) {
    const end = new Date(String(ctx.deadline)).getTime();
    const start = ctx.startDate ? new Date(String(ctx.startDate)).getTime() : Date.now();
    if (isFinite(end) && isFinite(start) && end > start) {
      const days = Math.ceil((end - start) / (1000 * 60 * 60 * 24));
      return Math.max(1, days);
    }
  }

  return null;
}

// Soft count band used ONLY as guidance to the model (when the user gave no
// explicit number) and as the deterministic offline-fallback count.
function suggestedCount(durationDays: number | null): { min: number; max: number } {
  if (durationDays === null) return { min: 3, max: 3 };
  if (durationDays <= 3) return { min: 2, max: 3 };
  if (durationDays <= 7) return { min: 3, max: 4 };
  if (durationDays <= 21) return { min: 4, max: 5 };
  if (durationDays <= 60) return { min: 5, max: 6 };
  return { min: 6, max: 8 };
}

// ── Request parsing ─────────────────────────────────────────────────────────

// Pull an explicit count or cadence out of the user's free-form request.
function parseRequest(req: string, durationDays: number | null): number | null {
  const s = req.toLowerCase();

  // "N per day" / "N a day" — multiply by the available days.
  const perDay = s.match(
    /(\d+(?:\.\d+)?)\s*(?:tasks?|milestones?|steps?|items?|things?)?\s*(?:per|a|each|every)\s*day/
  );
  if (perDay) {
    const rate = parseFloat(perDay[1]);
    if (durationDays) return Math.round(rate * durationDays);
  } else if (/\b(daily|every\s*day|each\s*day)\b/.test(s) && durationDays) {
    return durationDays;
  }

  // "N per week" / "weekly".
  const perWeek = s.match(
    /(\d+(?:\.\d+)?)\s*(?:tasks?|milestones?|steps?|items?)?\s*(?:per|a|each|every)\s*week/
  );
  if (perWeek) {
    const rate = parseFloat(perWeek[1]);
    if (durationDays) return Math.round(rate * Math.ceil(durationDays / 7));
  } else if (/\bweekly\b/.test(s) && durationDays) {
    return Math.max(1, Math.ceil(durationDays / 7));
  }

  // Explicit total with a unit word: "10 milestones", "8 steps".
  const withUnit = s.match(
    /(\d+)\s*(?:milestones?|steps?|tasks?|parts?|phases?|chunks?|stages?|items?|points?)/
  );
  if (withUnit) return parseInt(withUnit[1], 10);

  // Bare number anywhere ("give me 10", "make it 12").
  const bare = s.match(/\b(\d+)\b/);
  if (bare) return parseInt(bare[1], 10);

  return null;
}

// Honor or scale back an EXPLICIT user count, asking for confirmation when the
// ask is unrealistic. (Only runs when the user named a number.)
function decideTarget(
  requestedCount: number,
  forced: boolean,
  durationDays: number | null
): { target: number; feasibilityNote: string | null; needsConfirmation: boolean } {
  const { min } = suggestedCount(durationDays);
  const wanted = Math.max(1, requestedCount);
  const feasibleMax =
    durationDays !== null ? Math.max(min, durationDays * FEASIBLE_PER_DAY) : 12;

  // Within reach — just give them what they asked for.
  if (wanted <= feasibleMax && wanted <= ABSOLUTE_MAX) {
    return { target: wanted, feasibilityNote: null, needsConfirmation: false };
  }

  const rate = durationDays ? (wanted / durationDays).toFixed(1) : null;

  // Unrealistic, but the user confirmed — honor it (up to the hard ceiling).
  if (forced) {
    const target = Math.min(wanted, ABSOLUTE_MAX);
    let note = `Okay — I created ${target} milestones as you wanted`;
    if (wanted > ABSOLUTE_MAX) {
      note += ` (capped at ${ABSOLUTE_MAX}, the most I can generate at once)`;
    }
    note += ".";
    if (rate) {
      note += ` That's about ${rate} per day across ${durationDays} day(s) — a heavy load, so plan in buffer time and rest.`;
    }
    return { target, feasibilityNote: note, needsConfirmation: false };
  }

  // Unrealistic and not yet confirmed — scale back and ASK the user.
  const target = Math.max(min, Math.min(feasibleMax, ABSOLUTE_MAX));
  let note = `You asked for ${wanted} milestones`;
  if (durationDays) {
    note += ` in ${durationDays} day(s) (~${rate} per day), which isn't realistic for most people`;
  } else {
    note += `, but without a deadline I can't pace that many`;
  }
  note += `, so I planned ${target} for now. Are you sure you still want all ${wanted}? (yes / no)`;
  return { target, feasibilityNote: note, needsConfirmation: true };
}

// ── Sanitisation (safety rails) ──────────────────────────────────────────────

function loadFromDuration(duration: number): MilestoneLoad {
  if (duration <= 15) return "light";
  if (duration <= 35) return "focus";
  return "stretch";
}

const VALID_LOADS = new Set<MilestoneLoad>(["light", "focus", "stretch"]);

// Clamp anything the model returns into safe bounds. Never trusts the model
// for the deadline rule (§9.5) or the duration ceiling.
function sanitiseTasks(
  raw: Array<Partial<MilestoneTask>>,
  durationDays: number | null,
  cap: number
): MilestoneTask[] {
  const maxDay = durationDays !== null ? Math.max(0, durationDays - 1) : 365;
  const out: MilestoneTask[] = [];

  raw.forEach((m, index) => {
    const title = typeof m.title === "string" ? m.title.trim() : "";
    if (!title) return;

    let duration = Math.round(Number(m.durationMinutes));
    if (!Number.isFinite(duration)) duration = 20;
    duration = Math.min(90, Math.max(5, duration));

    const load: MilestoneLoad = VALID_LOADS.has(m.load as MilestoneLoad)
      ? (m.load as MilestoneLoad)
      : loadFromDuration(duration);

    let dayOffset = Math.round(Number(m.dayOffset));
    if (!Number.isFinite(dayOffset)) {
      // Model omitted a day — spread evenly across the window by position.
      dayOffset = maxDay > 0 ? Math.round((index / Math.max(1, raw.length - 1)) * maxDay) : 0;
    }
    dayOffset = Math.min(maxDay, Math.max(0, dayOffset));

    out.push({ title, durationMinutes: duration, load, dayOffset });
  });

  return out.slice(0, cap);
}

// ── Tool ────────────────────────────────────────────────────────────────────

export const createMilestonesTool = {
  name: "createMilestones",
  description:
    "Generates an adaptive milestone roadmap for a goal. The AI decides how many " +
    "milestones the goal needs and, for each, its title, duration, load, and day. " +
    "Explicit user counts (e.g. '10 milestones') are honored, with unrealistic " +
    "asks scaled back and confirmed.",

  async execute(args: CreateMilestonesArgs): Promise<MilestoneResult> {
    const goal = String(args.goal ?? "the goal").trim();
    const ctx = args.context ?? {};
    const goalReview = await evaluateGoal(goal, {
      ...ctx,
      ...(args.specialRequest ? { specialRequest: args.specialRequest } : {}),
    });
    if (!goalReview.allowed) {
      return {
        milestones: [],
        tasks: [],
        count: 0,
        durationDays: resolveDurationDays(args),
        requestedCount: null,
        feasibilityNote: goalGuardMessage(goalReview),
        needsConfirmation: false,
        honoredRequest: false,
      };
    }

    const specialRequest = String(
      args.specialRequest ?? ctx.specialRequest ?? ctx.notes ?? ""
    ).trim();

    const durationDays = resolveDurationDays(args);
    const explicitCount = specialRequest
      ? parseRequest(specialRequest, durationDays)
      : null;
    const forced = args.force === true || ctx.force === true;

    // Count: honor/scale an explicit request (with confirmation); otherwise let
    // the model choose within a sane band capped by ABSOLUTE_MAX.
    let target: number | null;
    let feasibilityNote: string | null;
    let needsConfirmation: boolean;
    let cap: number;
    if (explicitCount !== null) {
      const decided = decideTarget(explicitCount, forced, durationDays);
      target = decided.target;
      feasibilityNote = decided.feasibilityNote;
      needsConfirmation = decided.needsConfirmation;
      cap = decided.target;
    } else {
      target = null; // model decides
      feasibilityNote = null;
      needsConfirmation = false;
      cap =
        durationDays !== null
          ? Math.min(ABSOLUTE_MAX, Math.max(3, durationDays * FEASIBLE_PER_DAY))
          : 8;
    }

    const band = suggestedCount(durationDays);
    const countInstruction =
      target !== null
        ? `Produce EXACTLY ${target} milestone(s) — no more, no fewer.`
        : `Decide the RIGHT number of milestones yourself from the goal's real scope — usually ${band.min}–${band.max}, and never more than ${cap}. Use only as many as the goal genuinely needs; a simple goal needs few.`;

    const durationLine =
      durationDays !== null
        ? `The user has about ${durationDays} day(s) to reach this goal (day 0 = today, last day = ${durationDays - 1}).`
        : `No deadline was given; schedule everything on day 0.`;

    const category = ctx.category ? String(ctx.category) : null;
    const priorityRaw = Number(ctx.priority);
    const priority = Number.isFinite(priorityRaw) ? priorityRaw : null;
    const mood = ctx.mood ? String(ctx.mood) : null;
    const profileLine = [
      category ? `Category: ${category}.` : "",
      priority !== null ? `Priority: ${priority}/5.` : "",
      mood ? `The user's current mood is "${mood}" — keep early days lighter if it is low.` : "",
    ]
      .filter(Boolean)
      .join(" ");

    const requestLine = specialRequest
      ? `The user's request was: "${specialRequest}".`
      : `The user gave no special instructions.`;

    try {
      const ai = getAI();
      const prompt = `
You are the Task Generation Agent for a productivity app. Build a concrete, scheduled milestone roadmap for this goal: "${goal}".

${durationLine}
${profileLine}
${requestLine}

First, reason privately about what real work this goal actually requires — the concrete activities, in a sensible order, and how long each realistically takes — then output the roadmap.

Count:
- ${countInstruction}

For EACH milestone decide and return:
- "title": a DOABLE action the user can sit down and finish themselves (≤10 words, start with a verb). A reader must know exactly what to do from the title alone.
- "durationMinutes": the realistic focused time it takes (integer 5–90), sized to that specific milestone — not a fixed number.
- "load": "light" (≤15 min, easy), "focus" (16–35 min, needs concentration), or "stretch" (>35 min, demanding). Must match the durationMinutes.
- "dayOffset": the day to schedule it on (integer, 0 = today, max ${durationDays !== null ? durationDays - 1 : 0}). Order milestones logically and spread them across the available days so the load is sustainable; put lighter, momentum-building work earlier.

Hard rules:
- NEVER write outcome targets or metrics that depend on other people or luck — no "reach N subscribers/followers/views/sales", no "get X by day Y", no "hit"/"achieve" a number. Describe the WORK that drives the outcome instead (e.g. for a YouTube goal: "Script and record the first video", not "Reach 20 subscribers").
- The final milestone should finish or ship the goal's actual work — still an action, not a metric.

Respond ONLY with valid JSON:
{ "milestones": [ { "title": "...", "durationMinutes": 20, "load": "focus", "dayOffset": 0 } ] }`.trim();

      const { text } = await ai.generate({
        model: defaultModel,
        prompt,
        config: {
          temperature: 0.5,
          // Room for the model to reason about the real work before writing,
          // plus the structured output (thinking counts toward this budget on
          // Gemini 2.5, so the cap leaves headroom for both).
          maxOutputTokens: Math.min(8192, 2000 + cap * 80),
          responseMimeType: "application/json",
          thinkingConfig: { thinkingBudget: 1024 },
        },
      });

      const parsed = parseModelJson<{ milestones: Array<Partial<MilestoneTask>> }>(text);
      const tasks = sanitiseTasks(parsed.milestones ?? [], durationDays, cap);

      if (tasks.length >= 2) {
        return {
          milestones: tasks.map((t) => t.title),
          tasks,
          count: tasks.length,
          durationDays,
          requestedCount: explicitCount,
          feasibilityNote,
          needsConfirmation,
          honoredRequest: specialRequest.length > 0,
        };
      }
      console.warn("[createMilestones] AI returned <2 milestones, using static");
    } catch (e) {
      console.error("[createMilestones] LLM call failed, using static:", e);
    }

    const fallbackCount =
      target ?? Math.round((band.min + band.max) / 2);
    return staticFallback(
      goal,
      durationDays,
      fallbackCount,
      explicitCount,
      feasibilityNote,
      needsConfirmation,
      specialRequest
    );
  },
};

// Deterministic fallback (model unavailable). Still returns fully structured
// tasks so the client never has to invent durations/loads/days itself.
function staticFallback(
  goal: string,
  durationDays: number | null,
  target: number,
  requestedCount: number | null,
  feasibilityNote: string | null,
  needsConfirmation: boolean,
  specialRequest: string
): MilestoneResult {
  const base = [
    `Define what "done" looks like for ${goal} and list the biggest blockers`,
    `Complete the first working version or first visible deliverable`,
    `Expand and refine the core of ${goal}`,
    `Test the result against your "done" definition and fix the weakest part`,
    `Polish the details and prepare to share or submit`,
    `Do a final review of ${goal}, then share it or submit it`,
  ];

  const count = Math.max(2, Math.min(target, ABSOLUTE_MAX));
  const maxDay = durationDays !== null ? Math.max(0, durationDays - 1) : 0;
  const tasks: MilestoneTask[] = [];

  for (let i = 0; i < count; i++) {
    const title =
      count <= base.length
        ? base[i]
        : `Make concrete progress on ${goal} (part ${i + 1} of ${count})`;
    // Lighter, shorter early; heavier later — a safe deterministic ramp.
    const duration = i === 0 ? 10 : Math.min(60, 15 + i * 5);
    const load: MilestoneLoad =
      i === 0 ? "light" : i === count - 1 ? "stretch" : "focus";
    const dayOffset =
      maxDay > 0 ? Math.round((i / Math.max(1, count - 1)) * maxDay) : 0;
    tasks.push({ title, durationMinutes: duration, load, dayOffset });
  }

  return {
    milestones: tasks.map((t) => t.title),
    tasks,
    count: tasks.length,
    durationDays,
    requestedCount,
    feasibilityNote,
    needsConfirmation,
    honoredRequest: specialRequest.length > 0,
  };
}
