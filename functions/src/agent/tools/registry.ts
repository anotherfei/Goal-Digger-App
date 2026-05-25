
import { analyzeHabitsTool } from './tool_analyze_habits';
import { scheduleTasksTool } from './tool_schedule_tasks';
import { createMilestonesTool } from './tool_create_milestones';

const tools = {
  analyzeHabits: analyzeHabitsTool,
  scheduleTasks: scheduleTasksTool,
  createMilestones: createMilestonesTool,
};

export const toolRegistry = {
  listTools() {
    return Object.keys(tools);
  },

  hasTool(name: string) {
    return !!tools[name as keyof typeof tools];
  },

  async execute(name: string, args: any) {
    return tools[name as keyof typeof tools].execute(args);
  },
};
