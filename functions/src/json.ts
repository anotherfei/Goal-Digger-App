// functions/src/json.ts
//
// Safe JSON parser for Gemini model responses.
//
// Gemini occasionally wraps its JSON output in markdown fences even when
// responseMimeType: "application/json" is set (especially on the first few
// tokens of a stream). This utility strips those fences before parsing so
// callers never have to deal with it.

export function parseModelJson<T = Record<string, unknown>>(raw: string): T {
  let cleaned = raw.trim();

  // Strip ```json ... ``` or ``` ... ``` fences
  cleaned = cleaned
    .replace(/^```(?:json)?\s*/i, "")
    .replace(/\s*```\s*$/i, "")
    .trim();

  // If the model prefixed with a label like `json\n{...}`, strip the label
  if (cleaned.startsWith("json\n")) {
    cleaned = cleaned.slice(5).trim();
  }

  try {
    return JSON.parse(cleaned) as T;
  } catch (e) {
    throw new Error(
      `parseModelJson: invalid JSON from model.\nRaw (first 300 chars): ${raw.slice(0, 300)}\nError: ${e}`
    );
  }
}
