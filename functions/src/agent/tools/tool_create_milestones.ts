// functions/src/agent/tools/tool_create_milestones.ts
//
// Generates an AI milestone roadmap that adapts to the goal's duration AND to
// what the user explicitly asks for — an exact count ("10 milestones"), a
// cadence ("2 per day", "weekly"), or nothing at all.
//
// Feasibility: if a request would be unrealistic for a normal person in the
// available time, the tool scales it back to a sensible number and returns a
// `feasibilityNote` explaining why. If the user FORCES it (e.g. says "force"),
// the tool honors the full request (up to a hard safety ceiling) and warns
// that it will be demanding.

import { getAI, defaultModel } from "../../ai";
import { evaluateGoal, goalGuardMessage } from "../goal_guard";
import { parseModelJson } from "../../json";

// How many milestone-sized chunks a motivated person can realistically take on
// per day before it stops being achievable, and the absolute ceiling we will
// ever generate (protects the output-token budget even when forced).
const FEASIBLE_PER_DAY = 3;
const ABSOLUTE_MAX = 60;

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
    specialRequest?: string; // free-form user instructions, e.g. "2 milestones per day"
    force?: boolean; // user confirmed an unrealistic request
    notes?: string;
    [key: string]: unknown;
  };
}

interface MilestoneResult {
  milestones: string[];
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

// Default count range when the user gives no explicit count/cadence.
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

// Decide how many milestones to actually produce, and whether to warn the user.
function decideTarget(
  requestedCount: number | null,
  forced: boolean,
  durationDays: number | null
): { target: number; feasibilityNote: string | null; needsConfirmation: boolean } {
  const { min, max } = suggestedCount(durationDays);

  if (requestedCount === null) {
    return {
      target: Math.round((min + max) / 2),
      feasibilityNote: null,
      needsConfirmation: false,
    };
  }

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

// ── Tool ────────────────────────────────────────────────────────────────────

export const createMilestonesTool = {
  name: "createMilestones",
  description:
    "Generates an adaptive milestone roadmap for a goal. The count scales with " +
    "the goal's duration and honors explicit user requests (e.g. '10 milestones' " +
    "or '2 per day'). Unrealistic asks are scaled back with an explanation unless " +
    "the user forces them.",

  async execute(args: CreateMilestonesArgs): Promise<MilestoneResult> {
    const goal = String(args.goal ?? "the goal").trim();
    const goalReview = await evaluateGoal(
      goal,
      {
        ...(args.context ?? {}),
        ...(args.specialRequest ? { specialRequest: args.specialRequest } : {}),
      }
    );
    if (!goalReview.allowed) {
      return {
        milestones: [],
        count: 0,
        durationDays: resolveDurationDays(args),
        requestedCount: null,
        feasibilityNote: goalGuardMessage(goalReview),
        needsConfirmation: false,
        honoredRequest: false,
      };
    }

    const specialRequest = String(
      args.specialRequest ?? args.context?.specialRequest ?? args.context?.notes ?? ""
    ).trim();

    const durationDays = resolveDurationDays(args);
    const requestedCount = specialRequest
      ? parseRequest(specialRequest, durationDays)
      : null;
    const forced = args.force === true || args.context?.force === true;
    const { target, feasibilityNote, needsConfirmation } = decideTarget(
      requestedCount,
      forced,
      durationDays
    );

    const durationLine =
      durationDays !== null
        ? `The user has about ${durationDays} day(s) to complete this goal.`
        : `No deadline was given.`;

    const requestLine = specialRequest
      ? `The user's request was: "${specialRequest}".`
      : `The user gave no special instructions.`;

    try {
      const ai = getAI();
      const prompt = `
Create exactly ${target} clear, ordered milestones for this goal: "${goal}".

${durationLine}
${requestLine}

Rules:
- Produce EXACTLY ${target} milestones — no more, no fewer.
- Spread them evenly across the ${
        durationDays !== null ? `${durationDays}-day` : "overall"
      } window so each is a realistic chunk of progress.
- Each milestone must describe a VISIBLE, CONCRETE outcome (not a vague activity).
- Start each with an action verb. Use plain language. Do NOT number them.
- The final milestone should represent the goal being fully done.

Respond ONLY with valid JSON: { "milestones": ["...", "..."] }`.trim();

      const { text } = await ai.generate({
        model: defaultModel,
        prompt,
        config: {
          temperature: 0.5,
          // Scale the budget with how many milestones we asked for.
          maxOutputTokens: Math.min(4096, 400 + target * 50),
          responseMimeType: "application/json",
          thinkingConfig: { thinkingBudget: 0 },
        },
      });

      const parsed = parseModelJson<{ milestones: string[] }>(text);
      const cleaned = (parsed.milestones ?? [])
        .map((m: string) => m.trim())
        .filter((m: string) => m.length > 0);

      if (cleaned.length >= 2) {
        return {
          milestones: cleaned,
          count: cleaned.length,
          durationDays,
          requestedCount,
          feasibilityNote,
          needsConfirmation,
          honoredRequest: specialRequest.length > 0,
        };
      }
      console.warn("[createMilestones] AI returned <2 milestones, using static");
    } catch (e) {
      console.error("[createMilestones] LLM call failed, using static:", e);
    }

    return staticFallback(
      goal,
      durationDays,
      target,
      requestedCount,
      feasibilityNote,
      needsConfirmation,
      specialRequest
    );
  },
};

// Deterministic fallback that still produces the requested number of milestones.
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

  const milestones: string[] = [];
  for (let i = 0; i < target; i++) {
    if (target <= base.length) {
      milestones.push(base[i]);
    } else {
      // More milestones than the template — generate sequenced chunks.
      milestones.push(`Make concrete progress on ${goal} (part ${i + 1} of ${target})`);
    }
  }

  return {
    milestones,
    count: milestones.length,
    durationDays,
    requestedCount,
    feasibilityNote,
    needsConfirmation,
    honoredRequest: specialRequest.length > 0,
  };
}
