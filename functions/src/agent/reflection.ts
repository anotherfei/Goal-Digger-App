
export async function reflectionAgent(input: any) {
  return [
    {
      type: "schedule-analysis",
      insight: "User underestimates engineering task duration.",
      recommendation: "Increase future estimates by 30%.",
    },
  ];
}
