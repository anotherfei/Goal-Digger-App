// functions/src/flows/socialSuggestionFlow.ts
//
// AI ranking for social discovery. Firestore supplies live candidates; this
// flow decides which communities or public profiles fit the user's current
// goals, tasks, mood, and streak context.

import { z } from "genkit";
import { getAI, defaultModel } from "../ai";
import { parseModelJson } from "../json";

const UserContextSchema = z.object({
  mood: z.string().default("Okay"),
  streak: z.number().min(0).default(0),
  completedToday: z.number().min(0).default(0),
  totalToday: z.number().min(0).default(0),
  remainingMinutes: z.number().min(0).default(0),
  goals: z.array(z.string()).default([]),
  categories: z.array(z.string()).default([]),
  todayTasks: z.array(z.string()).default([]),
  taskLoads: z.array(z.string()).default([]),
});

const SocialSuggestionCandidateSchema = z.object({
  id: z.string(),
  title: z.string(),
  subtitle: z.string().default(""),
  description: z.string().default(""),
  category: z.string().default(""),
  streak: z.number().min(0).default(0),
  memberCount: z.number().min(0).default(0),
  activeToday: z.number().min(0).default(0),
  searchText: z.string().default(""),
});

const SocialSuggestionInputSchema = z.object({
  kind: z.enum(["communities", "friends"]),
  userContext: UserContextSchema,
  candidates: z.array(SocialSuggestionCandidateSchema).max(50).default([]),
});

const SocialSuggestionMatchSchema = z.object({
  id: z.string(),
  score: z.number().min(0).max(100),
  reason: z.string().default("Good accountability fit."),
});

const SocialSuggestionOutputSchema = z.object({
  matches: z.array(SocialSuggestionMatchSchema),
  degraded: z.boolean().default(false),
});

type SocialSuggestionInput = z.infer<typeof SocialSuggestionInputSchema>;
type SocialSuggestionCandidate = z.infer<typeof SocialSuggestionCandidateSchema>;
type SocialSuggestionMatch = z.infer<typeof SocialSuggestionMatchSchema>;

export function defineSocialSuggestionFlow() {
  const ai = getAI();

  return ai.defineFlow(
    {
      name: "socialSuggestions",
      inputSchema: SocialSuggestionInputSchema,
      outputSchema: SocialSuggestionOutputSchema,
    },
    async (input) => {
      const candidates = input.candidates
        .filter((candidate) => candidate.id.trim().length > 0)
        .slice(0, 50);

      if (candidates.length === 0) {
        return { matches: [], degraded: false };
      }

      const fallback = fallbackMatches({ ...input, candidates });
      const prompt = buildPrompt({ ...input, candidates });

      try {
        const { text } = await ai.generate({
          model: defaultModel,
          prompt,
          config: {
            temperature: 0.25,
            maxOutputTokens: 2048,
            responseMimeType: "application/json",
            thinkingConfig: { thinkingBudget: 256 },
          },
        });

        const parsed = parseModelJson<{ matches?: SocialSuggestionMatch[] }>(text);
        const matches = mergeMatches(candidates, parsed.matches ?? [], fallback);

        if (matches.length > 0) {
          return { matches, degraded: false };
        }
      } catch (e) {
        console.error("[socialSuggestionFlow] AI ranking failed:", e);
      }

      return { matches: fallback, degraded: true };
    }
  );
}

function buildPrompt(input: SocialSuggestionInput): string {
  const user = input.userContext;
  const candidates = input.candidates.map((candidate) => ({
    id: candidate.id,
    title: candidate.title,
    category: candidate.category,
    subtitle: candidate.subtitle,
    description: candidate.description,
    streak: candidate.streak,
    members: candidate.memberCount,
    activeToday: candidate.activeToday,
  }));

  const target =
    input.kind === "communities"
      ? "communities the user should join"
      : "people the user should add as accountability friends";

  const fitRules =
    input.kind === "communities"
      ? "Prefer topic overlap, active community streaks, and groups that match the user's current goals."
      : "Prefer similar productivity rhythm, useful accountability, and compatible goal/task themes.";

  return `
You are ranking ${target} in a productivity app.

User context:
${JSON.stringify(user, null, 2)}

Candidates:
${JSON.stringify(candidates, null, 2)}

Scoring rules:
- Score each candidate from 0 to 100 for real fit with the user.
- ${fitRules}
- Do not rank by name alone.
- Keep reasons specific, friendly, and max 12 words.
- Return each candidate id at most once.

Respond ONLY with valid JSON:
{
  "matches": [
    { "id": "candidate id", "score": 88, "reason": "Short reason" }
  ]
}`.trim();
}

function mergeMatches(
  candidates: SocialSuggestionCandidate[],
  modelMatches: SocialSuggestionMatch[],
  fallback: SocialSuggestionMatch[]
): SocialSuggestionMatch[] {
  const candidateIds = new Set(candidates.map((candidate) => candidate.id));
  const fallbackById = new Map(fallback.map((match) => [match.id, match]));
  const modelById = new Map<string, SocialSuggestionMatch>();

  for (const match of modelMatches) {
    if (!candidateIds.has(match.id) || modelById.has(match.id)) continue;
    modelById.set(match.id, {
      id: match.id,
      score: clampScore(Number(match.score)),
      reason: cleanReason(match.reason),
    });
  }

  return candidates
    .map((candidate) => modelById.get(candidate.id) ?? fallbackById.get(candidate.id))
    .filter((match): match is SocialSuggestionMatch => match !== undefined)
    .sort((a, b) => b.score - a.score || a.id.localeCompare(b.id));
}

function fallbackMatches(input: SocialSuggestionInput): SocialSuggestionMatch[] {
  const userText = [
    input.userContext.mood,
    ...input.userContext.goals,
    ...input.userContext.categories,
    ...input.userContext.todayTasks,
    ...input.userContext.taskLoads,
  ].join(" ");
  const userWords = wordSet(userText);
  const userStreak = input.userContext.streak;

  return input.candidates
    .map((candidate) => {
      const candidateWords = wordSet([
        candidate.title,
        candidate.subtitle,
        candidate.description,
        candidate.category,
        candidate.searchText,
      ].join(" "));
      const overlap = [...candidateWords].filter((word) => userWords.has(word)).length;
      const overlapScore = Math.min(28, overlap * 7);
      const streakScore = Math.min(18, Math.round(candidate.streak * 0.6));
      const activityScore =
        input.kind === "communities"
          ? Math.min(14, candidate.activeToday * 7 + Math.min(5, candidate.memberCount))
          : friendRhythmScore(userStreak, candidate.streak);
      const score = clampScore(48 + overlapScore + streakScore + activityScore);

      return {
        id: candidate.id,
        score,
        reason:
          overlap > 0
            ? "Matches your current goal themes."
            : input.kind === "communities"
            ? "Active group for steady accountability."
            : "Useful accountability rhythm.",
      };
    })
    .sort((a, b) => b.score - a.score || a.id.localeCompare(b.id));
}

function friendRhythmScore(userStreak: number, candidateStreak: number): number {
  if (candidateStreak <= 0) return userStreak <= 1 ? 6 : 2;
  const gap = Math.abs(candidateStreak - userStreak);
  if (gap <= 2) return 16;
  if (gap <= 7) return 11;
  return Math.min(14, 6 + Math.round(candidateStreak * 0.2));
}

function wordSet(text: string): Set<string> {
  return new Set(
    text
      .toLowerCase()
      .split(/[^a-z0-9]+/)
      .map((word) => word.trim())
      .filter((word) => word.length >= 3)
  );
}

function clampScore(score: number): number {
  if (!Number.isFinite(score)) return 50;
  return Math.max(0, Math.min(100, Math.round(score)));
}

function cleanReason(reason: string): string {
  const trimmed = String(reason ?? "").trim();
  if (!trimmed) return "Good accountability fit.";
  return trimmed.split(/\s+/).slice(0, 12).join(" ");
}
