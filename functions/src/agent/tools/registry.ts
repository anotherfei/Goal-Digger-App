// functions/src/agent/tools/registry.ts
//
// Central registry of all agent tools.
// Each tool exposes: name, description, execute(args).
// The planner chooses tool names from this list; the runtime looks them up here.

import { analyzeHabitsTool }    from "./tool_analyze_habits";
import { createMilestonesTool } from "./tool_create_milestones";
import { scheduleTasksTool }    from "./tool_schedule_tasks";

// Tool interface — execute can be async (AI-enriched) or sync (pure logic)
export interface AgentTool {
  name: string;
  description: string;
  execute(args: Record<string, unknown>): unknown | Promise<unknown>;
}

export const toolRegistry: AgentTool[] = [
  analyzeHabitsTool  as AgentTool,
  createMilestonesTool as AgentTool,
  scheduleTasksTool  as AgentTool,
];
