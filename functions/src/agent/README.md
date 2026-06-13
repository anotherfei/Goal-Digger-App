# Agentic AI — Code Map

This folder implements the agent layer described in
`intended_system_architecture_agentic_ai.md`. The deployment flow is unchanged:

```text
Flutter
  →
Firebase Functions  (functions/src/index.ts — auth, validation, routing)
  →
Genkit Flows / Agents  (this folder + ../flows)
  →
Gemini API  (../ai.ts singleton, gemini-2.5-flash)
```

## Agents (architecture §6)

| Architecture agent | Code | Callable | Notes |
|---|---|---|---|
| §6.1 Planning Agent | `goal_guard.ts` + `planner.ts` + `runtime.ts` | `agentPlanner` | `goal_guard.ts` is the first gate: it rejects unclear / too-broad / impossible / **negative** / harmful goals. `positiveGoal: false` (§9.1) means the goal failed the positive-framing filter — the client shows the reason and asks the user to re-input the goal. `planner.ts` then selects tools; `runtime.ts` orchestrates execution, chaining, memory. |
| §6.2 Task Generation Agent | `tools/tool_create_milestones.ts`, `tools/tool_analyze_habits.ts`, `tools/tool_schedule_tasks.ts` (+ `../flows/taskGeneratorFlow.ts` fallback) | via `agentPlanner` | Milestone count adapts to duration and user requests, with feasibility scaling and confirmation questions. |
| §6.3 Task Modification Agent | `modification.ts` | `agentModify` | Sees the CURRENT draft + the change request. Verdicts: `applied` / `clarify` (§9.3) / `confirm` (§9.4) / `rejected` (§9.2). Deterministic sanitisation clamps durations and never lets a task land past the deadline (§9.5). |
| §6.4 Task Reassignment Agent | `reassignment.ts` | `agentReassign` | Reacts to `moodChanged`, `routineAdded`, `deadlineApproaching`, `priorityChanged`, `manual`. Gemini proposes moves; `validateProposals()` enforces the deadline rule (§9.5), mood-aware daily-capacity limits (§3.4), and importance weighting (§9.6) before anything is accepted. Falls back to a deterministic overload-relief heuristic when the model is unavailable. |

Shared memory (`memory.ts`, Firestore `agent_memory/{uid}`) stores learned
preferences, mood history, and reassignment audit data (§10).

## Client triggers (Flutter)

- Goal creation dialog → `agentPlanner` (Planning + Task Generation Agents).
- Chat adjustments inside the dialog → `agentModify` (falls back to a full
  replan if the modification agent is unreachable).
- Mood change and new routine → `agentReassign`; validated changes update
  `MicroTask.scheduledDate` and sync to Firestore, with the agent's
  explanation surfaced as an in-app notification.

Wrappers live in `lib/genkit/` (`genkit_service.dart`, `flows/`, `models/`).

## Hard rules (architecture §9)

- **§9.1 positive goal filtering** — negatively framed goals are rejected with
  a reason and a prompt to re-enter the goal positively (`positiveGoal=false`).
- **Deadline feasibility** — the guard also judges the user's chosen deadline
  against the goal, category, priority, and `existingDailyMinutes` (minutes
  already booked per day until the deadline). A deadline is unrealistic when
  the timeframe is too short for the work OR the runway is already full of
  existing tasks. The goal stays allowed; `deadlineSuggestion
  { suggestedDays, reason }` is returned and the client asks the user to
  agree (move the deadline + re-plan) or decline (keep it as chosen).
- **§9.3 / §9.4 clarify & confirm** — risky or ambiguous modifications never
  apply silently; the agent asks first and only proceeds on `force=true`.
- **§9.5 deadline rule** — enforced in code, not just in prompts: both
  `modification.ts` and `reassignment.ts` clamp/drop anything that would land
  past a deadline, regardless of what the model returns.
- **§9.6 importance rule** — reassignment proposals are applied in descending
  goal importance, so important work claims capacity first.
- **§3.4 human limits** — per-day minute caps derived from mood
  (`capacityForDay`) bound every accepted schedule change.
