
export const createMilestonesTool = {
  name: 'createMilestones',
  description: 'Creates milestone dependency graphs.',
  async execute(args: any) {
    return {
      milestones: [
        'Foundation',
        'Projects',
        'Interview Prep',
      ],
    };
  },
};
