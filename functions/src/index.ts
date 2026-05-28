// functions/src/index.ts
//
// Exports every Firebase Cloud Function for Goal Digger.
//
// Auth strategy:
//   • onCall functions  → Firebase verifies the ID token automatically.
//   • goalCoachStream   → onRequest (SSE), token verified manually via Admin SDK
//                         because onCall doesn't support streaming responses.
//
// Flow instances are created ONCE at module load time (not inside each request
// handler). Re-creating Genkit flows on every invocation is wasteful and can
// cause name-collision warnings in Genkit's flow registry.

import * as admin from "firebase-admin";
import { onCall, onRequest, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

import { defineGoalCoachFlow }     from "./flows/goalCoachFlow";
import { defineTaskGeneratorFlow } from "./flows/taskGeneratorFlow";
import { defineMoodAdvisorFlow }   from "./flows/moodAdvisorFlow";
import { defineFocusInsightFlow }  from "./flows/focusInsightFlow";
import { getAI, defaultModel }     from "./ai";
import { runAgent }                from "./agent/runtime";

// ── Initialise Admin SDK ──────────────────────────────────────────────────────
admin.initializeApp();

// ── Secret declaration ────────────────────────────────────────────────────────
const geminiApiKey = defineSecret("GEMINI_API_KEY");

const fnOptions = {
  region: "asia-east1",
  secrets: [geminiApiKey],
  timeoutSeconds: 60,
  memory: "256MiB" as const,
};

// Only allow authenticated Firebase users
const requireAuth = (auth: { uid?: string } | undefined) => {
  if (!auth?.uid) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }
};

// ── Define flows ONCE at module load ──────────────────────────────────────────
// Genkit registers flows by name internally. Calling defineFlow() on every
// request creates duplicate registrations and leaks memory. Define once here.
const goalCoachFlowFn     = defineGoalCoachFlow();
const taskGeneratorFlowFn = defineTaskGeneratorFlow();
const moodAdvisorFlowFn   = defineMoodAdvisorFlow();
const focusInsightFlowFn  = defineFocusInsightFlow();

// ── Callable functions (Flutter uses cloud_functions package) ─────────────────

export const goalCoach = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  return await goalCoachFlowFn(req.data);
});

export const taskGenerator = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  return await taskGeneratorFlowFn(req.data);
});

export const moodAdvisor = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  return await moodAdvisorFlowFn(req.data);
});

export const focusInsight = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  return await focusInsightFlowFn(req.data);
});

export const agentPlanner = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  const goal = String(req.data?.goal ?? "").trim();
  if (!goal) {
    throw new HttpsError("invalid-argument", "goal is required.");
  }
  return await runAgent({
    userId: req.auth!.uid,
    goal,
    context: req.data?.context ?? {},
  });
});

// ── Streaming endpoint (SSE) ──────────────────────────────────────────────────
// onCall doesn't support streaming, so goalCoachStream is an onRequest function.
// The Flutter GenkitClient verifies the token manually for this endpoint.

export const goalCoachStream = onRequest(
  { ...fnOptions, cors: true },
  async (req, res) => {
    // 1. Verify Firebase ID token
    const authHeader = req.headers.authorization ?? "";
    if (!authHeader.startsWith("Bearer ")) {
      res.status(401).json({ error: "Missing Bearer token" });
      return;
    }
    try {
      await admin.auth().verifyIdToken(authHeader.slice(7));
    } catch {
      res.status(401).json({ error: "Invalid or expired token" });
      return;
    }

    // 2. Parse input
    const input = req.body as {
      userMessage: string;
      goalTitle: string;
      progressPercent: number;
      history?: { role: string; content: string }[];
    };

    // 3. Stream SSE
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.setHeader("X-Accel-Buffering", "no");

    try {
      const ai = getAI();
      const historyBlock = (input.history ?? [])
        .map((m) => `${m.role === "user" ? "User" : "Coach"}: ${m.content}`)
        .join("\n");

      const prompt = `
You are the Goal Digger AI coach — supportive, concise, and action-oriented.
Goal: "${input.goalTitle}" (${Math.round(input.progressPercent)}% complete).
${historyBlock ? `\n${historyBlock}\n` : ""}
User: ${input.userMessage}

Reply conversationally (1–3 sentences). Be warm and specific.`.trim();

      const { stream } = await ai.generateStream({
        model: defaultModel,
        prompt,
        config: { temperature: 0.7, maxOutputTokens: 512 },
      });

      for await (const chunk of stream) {
        const text = chunk.text;
        if (text) {
          res.write(`data: ${JSON.stringify({ chunk: text })}\n\n`);
        }
      }

      res.write("data: [DONE]\n\n");
    } catch (err) {
      res.write(`data: ${JSON.stringify({ error: String(err) })}\n\n`);
    } finally {
      res.end();
    }
  }
);
