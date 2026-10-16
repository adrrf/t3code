# Tasks

## 1. Prerequisite check

- [ ] 1.1 [standard] In `pnpm dev:share` from a tailnet browser, open a project where `openspec init --tools claude` has been run, start a Claude thread and type `/opsx:` in the composer; verify the OpenSpec commands are offered and `/opsx:explore` runs, and that asking "which subagents can you use?" lists worker-light, worker, worker-heavy and reviewer. If not, stop and fix project command loading in the Claude provider before continuing (record what was changed here)

## 2. Model and parsing

- [ ] 2.1 [standard] Create `apps/web/src/fork/openspec/openspecModel.ts` with path constants and `parseTaskProgress(tasksMd)` returning `{ done, total }`, where a box counts as done only if it contains just `x`/`X` with any spacing; verify with unit tests for `- [x]`, `- [X]`, `- [ x]`, `- [ ]`, `- [~]`, `- [-]`, `- []`, indented tasks, tier tags after the number and non-checkbox lines
- [ ] 2.2 [standard] Add `buildOpenSpecModel(listings, tasksContents)` that returns active changes (excluding `archive`), archived changes and spec capability paths (supporting nested paths like `identity/user-auth`), with per-change artifact presence (proposal, design, tasks, specs) and a per-change read error; verify with unit tests using fixture listings, including an empty project, a change without `tasks.md` and an unreadable `tasks.md`
- [ ] 2.3 [light] Run `pnpm typecheck`, `pnpm lint` and `vp test run apps/web/src/fork/openspec/openspecModel.test.ts`; all pass (light: commands only)

## 3. Loading hook

- [ ] 3.1 [standard] Create `apps/web/src/fork/openspec/useOpenSpecProject.ts(environmentId, cwd)`: detects `openspec/`, lists changes/archive/specs via the same RPC path `useDirectoryEntries` uses, reads only active changes' `tasks.md` via `projects.readFile`, returns `{ status, model, refresh }`; verify with a hook test using mocked RPCs for "no openspec", "loading", "loaded" and "one tasks.md fails"
- [ ] 3.2 [standard] Add the three refresh triggers from design D3: `useWorkspaceMutationRefresh` (as `FileBrowserPanel.tsx` does), a 10 s poll only while the panel is mounted and `document.visibilityState === "visible"`, and an immediate refresh on window focus / visibility regained; verify with hook tests using fake timers: a new mutation id triggers one refresh, polling stops when hidden, focus triggers a refresh, and no poll runs after unmount
- [ ] 3.3 [light] Run `pnpm typecheck`, `pnpm lint` and the hook tests; all pass (light: commands only)

## 4. Composer actions

- [ ] 4.1 [standard] Create `apps/web/src/fork/openspec/openspecActions.ts` with `insertOpenSpecCommand(threadRef, command, changeId)` that uses `setPrompt` to put `/opsx:<command> <id>` on a new first line while keeping any existing draft, then focuses the composer; verify with unit tests for empty and non-empty drafts and that nothing is sent
- [ ] 4.2 [heavy] Spike, before any UI: find how to address the draft of a thread just created by `startNewThreadFromContext` (it returns only a boolean). Write findings in this task's notes, then implement `applyInNewThread(context, changeId, { worktree })`: pre-fill the new draft if a clean hook exists, otherwise use the clipboard + toast fallback from design D4; for `worktree: true`, use the existing new-thread worktree option rather than git commands; verify with a unit test using a mocked context and by hand that both variants open a new thread with the command unsent (heavy: undocumented upstream behaviour)
- [ ] 4.3 [light] Run `pnpm typecheck`, `pnpm lint` and the action tests; all pass (light: commands only)

## 5. Panel UI and right-panel integration

- [ ] 5.1 [heavy] Add `"openspec"` to `RIGHT_PANEL_KINDS` and `{ id: "openspec"; kind: "openspec" }` to the surface union in `rightPanelStore.ts`, and make `migratePersistedRightPanelState` accept it (marked `// fork:`); verify with a test in the existing `rightPanelStore.test.ts` style that a persisted state containing the openspec surface round-trips (heavy: persisted state)
- [ ] 5.2 [standard] Create `apps/web/src/fork/openspec/OpenSpecPanel.tsx`: active changes with progress bars (or "No tasks yet"), a "ready" marker when all tasks are done, per-change artifact list (missing ones shown as not created) that opens files with `openFile`, Apply / Verify / Archive buttons, an Apply in new thread menu (with/without worktree), collapsed Archived and Specs sections, a manual refresh button and per-change error markers; verify with component tests using a fixture model
- [ ] 5.3 [heavy] Create `OpenSpecTabLabel.tsx` and add the `case "openspec"` branches in `RightPanelTabs.tsx` for label and body, offering the tab only when `useOpenSpecProject` reports an `openspec/` folder (marked `// fork:`); verify the existing `RightPanelTabs.test.tsx` and `RightPanelTabs.keyboard.test.tsx` still pass (heavy: large, busy upstream component)
- [ ] 5.4 [standard] Add an `"openspec.toggle"` command to `keybindings.ts` and the default keybindings, matching how `"diff.toggle"` is defined, and make it a no-op when the project has no `openspec/` folder; verify with a test in `keybindings.test.ts`
- [ ] 5.5 [light] Run `pnpm typecheck`, `pnpm lint` and all tests touched in groups 2–5; all pass (light: commands only)

## 6. End-to-end check

- [ ] 6.1 [standard] In `pnpm dev:share` from a tailnet browser on a real OpenSpec project: confirm the tab is absent before `openspec init` and appears after it without restart; create a change with `/opsx:propose`, see it listed with its artifacts, open `proposal.md` from the panel, click Apply in new thread, send, and watch progress update in the original thread's panel within 15 s as tasks are ticked; then Verify and Archive and confirm the change moves to the Archived section
- [ ] 6.2 [light] Confirm `git diff upstream/main --stat` shows only the planned upstream touch points (`rightPanelStore.ts`, `RightPanelTabs.tsx`, `keybindings.ts` and its defaults) outside `apps/web/src/fork/`, and `pnpm-lock.yaml` is unchanged (light: commands only)
