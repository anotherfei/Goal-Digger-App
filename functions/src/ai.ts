// functions/src/ai.ts
//
// Single Genkit instance shared across all flows.
// Created lazily so GEMINI_API_KEY is available (Firebase injects secrets
// into process.env at function startup — not at module import time).

import { genkit, type Genkit } from "genkit";
import { googleAI, gemini15Flash } from "@genkit-ai/googleai";

let _ai: Genkit | null = null;

/**
 * Returns the cached Genkit instance, creating it on first call.
 * Must be called inside a function handler (after secrets are injected).
 */
export function getAI(): Genkit {
  if (!_ai) {
    _ai = genkit({
      plugins: [
        googleAI({
          apiKey: process.env.GEMINI_API_KEY,
          // To switch to Gemma 4 once available on your API tier:
          //   model: 'gemma-4-it'
          // For Vertex AI instead of AI Studio:
          //   import { vertexAI } from '@genkit-ai/vertexai'; use that plugin.
        }),
      ],
    });
  }
  return _ai;
}

// Re-export the model so flows don't import @genkit-ai/googleai directly.
// Swap this one line to change the model for all flows at once.
export { gemini15Flash as defaultModel };
