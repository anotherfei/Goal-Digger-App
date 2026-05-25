// functions/src/json.ts
// Accepts strict JSON responses and also recovers from common model output
// wrappers such as ```json fences or short prose before/after the object.

export function parseModelJson<T>(rawText: string): T {
  const text = rawText.trim();

  try {
    return JSON.parse(text) as T;
  } catch {
    // Continue with recovery below.
  }

  const fenced = text.match(/```(?:json)?\s*([\s\S]*?)```/i);
  if (fenced?.[1]) {
    return JSON.parse(fenced[1].trim()) as T;
  }

  const firstObject = text.indexOf("{");
  const lastObject = text.lastIndexOf("}");
  if (firstObject !== -1 && lastObject > firstObject) {
    return JSON.parse(text.slice(firstObject, lastObject + 1)) as T;
  }

  throw new Error("Model did not return parseable JSON.");
}
