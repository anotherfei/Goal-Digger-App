import * as admin from "firebase-admin";

export const memoryStore = {
  async loadUserMemory(userId: string) {
    const snap = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("aiMemory")
      .doc("profile")
      .get();

    if (!snap.exists) {
      return {
        productivityPatterns: [],
        preferredWorkHours: [],
        burnoutSignals: [],
      };
    }

    return snap.data() ?? {};
  },

  async saveReflection(userId: string, reflections: unknown[]) {
    const ref = admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("aiMemory")
      .doc("profile");

    await ref.set(
      {
        lastReflections: reflections,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return true;
  },
};
