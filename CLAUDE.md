# NaiviSense Claude Code Guide

## Session Start

1. Read `tasks/lessons.md` before starting project work.
2. Read `PROJECT_OVERVIEW.md` and the README for the subsystem being changed.
3. Check `git status --short`. Preserve all unrelated and pre-existing changes.
4. Inspect the relevant implementation before proposing or editing code.

## Planning and Task Tracking

- Treat work with three or more meaningful steps, cross-module changes, or architectural decisions as non-trivial.
- For non-trivial work, enter plan mode and write a decision-complete checklist in `tasks/todo.md` before implementation.
- Include the objective, implementation steps, verification commands, and acceptance criteria.
- Confirm the plan with the user before implementation when Claude Code's interaction mode permits it.
- Keep exactly one checklist item in progress and mark items complete as work is verified.
- If an assumption fails, requirements change, or verification exposes a design problem, stop implementation and revise the plan before continuing.
- Keep `tasks/todo.md` concise. Replace completed task details when starting a new task, or archive them only when history is useful.

## Delegation

- Use project subagents when independent exploration or review will reduce ambiguity or protect the main context.
- Give each subagent one focused objective and the minimum context it needs.
- Use `codebase-explorer` for read-only architecture, dependency, and implementation tracing.
- Use `debugger` for evidence-driven diagnosis of errors, failing tests, and regressions.
- Use `code-reviewer` after non-trivial changes for an independent regression, security, simplicity, and test review.
- Subagents analyze and report. The primary session owns final edits, integration decisions, and verification.

## Implementation Standards

- Find and fix the root cause. Do not hide failures with temporary workarounds.
- Prefer the smallest change that fully solves the problem and follows existing project patterns.
- Avoid unrelated refactors, new abstractions without a concrete benefit, and broad formatting churn.
- Before finalizing a non-trivial change, ask whether the design can be simpler or clearer. Rework solutions that remain brittle or unnecessarily complex.
- Never overwrite, revert, or discard user changes unless explicitly instructed.
- Do not expose credentials, `.env` contents, tokens, or local-only Claude settings.

## Verification

- Never claim completion without evidence appropriate to the changed behavior.
- Start with focused checks, then run the broader relevant suite when the blast radius warrants it.
- For Flutter changes in `naivisense/`, run:
  - `flutter analyze`
  - `flutter test`
- For backend changes in `backend/`, run:
  - `npm test`
  - `npm run build`
- For cross-stack changes, run both sets of checks and verify request/response contracts on both sides.
- Compare changed behavior with the previous behavior when fixing regressions or altering shared flows.
- Review the final diff and ask: would a staff engineer approve the correctness, scope, clarity, and tests?
- Record commands, outcomes, remaining risks, and the final review in `tasks/todo.md`.
- If a required check cannot run, state exactly why and do not represent the task as fully verified.

## Learning From Corrections

- After any user correction, append a concise entry to `tasks/lessons.md` before continuing.
- Record the triggering mistake, the general prevention rule, and how to apply it in this repository.
- Write reusable rules rather than narrating blame or preserving sensitive details.
- Review existing lessons at the start of every session and apply relevant ones to the current plan.

## Communication

- For non-trivial work, give short updates at planning, implementation, and verification milestones.
- Explain what changed and why at a high level; let code and tests carry the detail.
- Report blockers with evidence and a concrete next action.
- Final responses must summarize the implementation, verification performed, and any residual risk.

## gstack

- Use the `/browse` skill from gstack for all web browsing.
- Never use `mcp__claude-in-chrome__*` tools.
- Available gstack skills: `/office-hours`, `/plan-ceo-review`, `/plan-eng-review`, `/plan-design-review`, `/design-consultation`, `/design-shotgun`, `/design-html`, `/review`, `/ship`, `/land-and-deploy`, `/canary`, `/benchmark`, `/browse`, `/connect-chrome`, `/qa`, `/qa-only`, `/design-review`, `/setup-browser-cookies`, `/setup-deploy`, `/setup-gbrain`, `/retro`, `/investigate`, `/document-release`, `/document-generate`, `/codex`, `/cso`, `/autoplan`, `/plan-devex-review`, `/devex-review`, `/careful`, `/freeze`, `/guard`, `/unfreeze`, `/gstack-upgrade`, `/learn`.
