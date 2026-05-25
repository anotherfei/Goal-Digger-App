
export const memoryStore = {
  async loadUserMemory(userId: string) {
    return {
      productivityPatterns: [],
      preferredWorkHours: [],
      burnoutSignals: [],
    };
  },

  async saveReflection(userId: string, reflections: any[]) {
    return true;
  },
};
