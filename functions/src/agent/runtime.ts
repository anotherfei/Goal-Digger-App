
import { plannerAgent } from './planner';
import { reflectionAgent } from './reflection';
import { memoryStore } from './memory';
import { toolRegistry } from './tools/registry';

export interface AgentRequest {
  userId: string;
  goal: string;
  context?: Record<string, any>;
}

export interface AgentResponse {
  plan: any;
  reflections: any[];
  memoryUpdated: boolean;
}

export async function runAgent(request: AgentRequest): Promise<AgentResponse> {
  const memory = await memoryStore.loadUserMemory(request.userId);

  const plan = await plannerAgent({
    goal: request.goal,
    memory,
    tools: toolRegistry.listTools(),
  });

  const executionResults = [];

  for (const step of plan.steps) {
    if (step.tool && toolRegistry.hasTool(step.tool)) {
      const result = await toolRegistry.execute(step.tool, step.args || {});
      executionResults.push(result);
    }
  }

  const reflections = await reflectionAgent({
    goal: request.goal,
    plan,
    executionResults,
    memory,
  });

  await memoryStore.saveReflection(request.userId, reflections);

  return {
    plan,
    reflections,
    memoryUpdated: true,
  };
}
