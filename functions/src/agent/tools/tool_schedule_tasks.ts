
export const scheduleTasksTool = {
  name: 'scheduleTasks',
  description: 'Schedules tasks into available time blocks.',
  async execute(args: any) {
    return {
      scheduled: true,
      sessionsCreated: 5,
    };
  },
};
