import { genkit, type Genkit } from "genkit";
import { googleAI } from "@genkit-ai/google-genai";
import { enableFirebaseTelemetry } from '@genkit-ai/firebase';

enableFirebaseTelemetry();
let _ai: Genkit | null = null;

export function getAI(): Genkit {
  if (!_ai) {
    _ai = genkit({
      plugins: [
        googleAI({
          apiKey: process.env.GEMINI_API_KEY,
        }),
      ],
    });
  }

  return _ai;
}

// Good default for Goal Digger:
// cheap/fast enough for task generation, coaching, mood advice.
export const defaultModel = googleAI.model("gemini-2.5-flash-lite");