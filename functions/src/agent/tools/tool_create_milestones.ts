interface CreateMilestonesArgs {
  goal?: string;
}

export const createMilestonesTool = {
  name: "createMilestones",
  description: "Creates milestone dependency graphs.",
  async execute(args: CreateMilestonesArgs) {
    const goal = args.goal ?? "the goal";
    return {
      milestones: [
        `Clarify success criteria for ${goal}`,
        "Complete the first visible draft",
        "Review feedback and improve the weakest part",
      ],
    };
  },
};
