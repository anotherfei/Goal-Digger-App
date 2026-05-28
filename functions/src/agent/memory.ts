// functions/src/agent/memory.ts
//
// Thin typed helpers for reading/writing agent memory in Firestore.
// The runtime (runtime.ts) uses these directly; flows can also call them
// to hydrate context before calling Gemini.

import * as admin from "firebase-admin";

export interface AgentMemory {
  lastGoal?: string;
  lastAgentRun?: string;         // ISO timestamp
  totalAgentRuns?: number;
  reflectionCount?: number;
  recommendedDailyMinutes?: number;
  preferredWorkHours?: string[];  // e.g. ["09:00", "11:00"]
  preferredStartHour?: number;    // 0-23
  [key: string]: unknown;
}

const COLLECTION = "agent_memory";

export async function getMemory(userId: string): Promise<AgentMemory> {
  try {
    const snap = await admin.firestore().collection(COLLECTION).doc(userId).get();
    return snap.exists ? (snap.data() as AgentMemory) : {};
  } catch (e) {
    console.error(`[memory] getMemory failed for uid=${userId}:`, e);
    return {};
  }
}

export async function setMemory(
  userId: string,
  updates: Partial<AgentMemory>
): Promise<void> {
  try {
    await admin
      .firestore()
      .collection(COLLECTION)
      .doc(userId)
      .set(updates, { merge: true });
  } catch (e) {
    console.error(`[memory] setMemory failed for uid=${userId}:`, e);
  }
}

export async function clearMemory(userId: string): Promise<void> {
  try {
    await admin.firestore().collection(COLLECTION).doc(userId).delete();
  } catch (e) {
    console.error(`[memory] clearMemory failed for uid=${userId}:`, e);
  }
}
