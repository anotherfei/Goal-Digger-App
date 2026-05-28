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
  _ai = genkit({
    plugins: [googleAI()],
  });
  return _ai;
}

// Default model used by all flows and tools.
// Gemini 2.0 Flash gives the best latency/quality trade-off for this workload.
export const defaultModel = "googleai/gemini-2.0-flash";
