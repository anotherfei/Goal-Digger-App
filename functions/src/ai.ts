// functions/src/ai.ts
//
// Singleton Genkit AI instance shared across all flows and tools.
//
// Why singleton?
//   genkit() registers plugins once. Calling it multiple times (e.g. once per
//   request) causes duplicate plugin warnings and wastes initialisation time.
//   One instance per Cloud Function worker process is the correct pattern.

import { genkit } from "genkit";
import { googleAI } from "@genkit-ai/google-genai";

let _ai: ReturnType<typeof genkit> | null = null;

export function getAI(): ReturnType<typeof genkit> {
  if (_ai) return _ai;

  // GEMINI_API_KEY is a Firebase secret injected into process.env at runtime.
  // Do NOT throw here — this function is called at module-load time when flows
  // are registered, and throwing would prevent all functions from deploying.
  // Each flow already has a try/catch that returns a safe fallback if generate()
  // fails. We log a warning so the issue is visible in Cloud Functions logs.
  const apiKey = process.env.GEMINI_API_KEY;
  
  const isRuntime = !!process.env.K_SERVICE || !!process.env.FUNCTIONS_EMULATOR;
  if (!apiKey && isRuntime) {
    console.warn(
      "[Goal Digger] GEMINI_API_KEY is not set — AI calls will fail at runtime. " +
      "Fix: firebase functions:secrets:set GEMINI_API_KEY  then redeploy."
    );
  }

  _ai = genkit({
    // Pass the key explicitly when available; fall back to env-var lookup otherwise.
    plugins: [googleAI(apiKey ? { apiKey } : undefined)],
  });
  return _ai;
}

// Default model used by all flows and tools.
// Gemini 2.5 Flash gives the best latency/quality trade-off for this workload.

export const defaultModel = "googleai/gemini-2.5-flash";
