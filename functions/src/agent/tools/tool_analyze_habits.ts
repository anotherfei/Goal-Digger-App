
export const analyzeHabitsTool = {
  name: 'analyzeHabits',
  description: 'Analyzes productivity and behavioral trends.',
  async execute(args: any) {
    return {
      burnoutRisk: 'medium',
      strongestHours: ['08:00', '11:00'],
    };
  },
};
