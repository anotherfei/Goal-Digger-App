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
  } catch {
    // Defensive recovery: models sometimes emit a trailing comma, or wrap the
    // object in extra prose. Extract the outermost {...} / [...] span and strip
    // trailing commas before retrying once.
    const recovered = recoverJson(cleaned);
    if (recovered !== null) {
      try {
        return JSON.parse(recovered) as T;
      } catch {
        /* fall through to the thrown error below */
      }
    }
    throw new Error(
      `parseModelJson: invalid JSON from model.\nRaw (first 300 chars): ${raw.slice(0, 300)}`
    );
  }
}

/** Best-effort cleanup for slightly-malformed model JSON. Returns null if no
 *  recognizable object/array span is found. */
function recoverJson(text: string): string | null {
  const firstObj = text.indexOf("{");
  const firstArr = text.indexOf("[");
  const starts = [firstObj, firstArr].filter((i) => i >= 0);
  if (starts.length === 0) return null;
  const start = Math.min(...starts);

  const lastObj = text.lastIndexOf("}");
  const lastArr = text.lastIndexOf("]");
  const end = Math.max(lastObj, lastArr);
  if (end <= start) return null;

  // Slice the outermost span, then remove trailing commas before } or ].
  return text.slice(start, end + 1).replace(/,(\s*[}\]])/g, "$1");
}
