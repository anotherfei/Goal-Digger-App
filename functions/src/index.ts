// functions/src/index.ts
//
// Exports every Firebase Cloud Function for Goal Digger.
//
// Auth strategy:
//   • onCall functions  → Firebase verifies the ID token automatically.
//                         Any signed-in user is allowed (authPolicy below).
//   • goalCoachStream   → onRequest (SSE), token verified manually via Admin SDK
//                         because onCall doesn't support streaming responses.
//
// Secret:
//   GEMINI_API_KEY is declared once here and automatically injected into
//   process.env for every function at startup — never in source code.

import * as admin from "firebase-admin";
import { onCall, onRequest, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";

import { defineGoalCoachFlow }     from "./flows/goalCoachFlow";
import { defineTaskGeneratorFlow } from "./flows/taskGeneratorFlow";
import { defineMoodAdvisorFlow }   from "./flows/moodAdvisorFlow";
import { defineFocusInsightFlow }  from "./flows/focusInsightFlow";
import { getAI, defaultModel }     from "./ai";

// ── Initialise Admin SDK ──────────────────────────────────────────────────────
admin.initializeApp();

// ── Secret declaration ────────────────────────────────────────────────────────
// Declare once — all functions below inherit it via the shared `secrets` option.
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

// ── Callable functions (Flutter uses cloud_functions package) ─────────────────

export const goalCoach = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  const flow = defineGoalCoachFlow();
  return await flow(req.data);
});

export const taskGenerator = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  const flow = defineTaskGeneratorFlow();
  return await flow(req.data);
});

export const moodAdvisor = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  const flow = defineMoodAdvisorFlow();
  return await flow(req.data);
});

export const focusInsight = onCall(fnOptions, async (req) => {
  requireAuth(req.auth);
  const flow = defineFocusInsightFlow();
  return await flow(req.data);
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
