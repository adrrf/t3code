# Design

## Context

See proposal.md for motivation. Relevant current state in upstream T3 Code:

- `apps/web/src/rightPanelStore.ts` holds right-panel surfaces. `RIGHT_PANEL_KINDS` lists kinds
  (`diff`, `files`, `file`, `preview`, …); `diff` and `files` are singleton surfaces with fixed ids.
  The store exposes `open(...)`, `openFile(ref, relativePath, line?)`, etc.
- `apps/web/src/components/RightPanelTabs.tsx` switches on `surface.kind` to render tab
  labels/icons (around line 603) and panel bodies (around line 670).
- `apps/web/src/components/files/useDirectoryEntries.ts` loads directory listings for an
  `(environmentId, cwd)` via the `projects.listEntries` RPC; `projects.readFile` reads files.
- `apps/web/src/hooks/useWorkspaceMutationRefresh.ts` triggers a refresh once per workspace
  mutation; `FileBrowserPanel` wires it with a `workspaceMutationId`.
- `apps/web/src/composerDraftStore.ts` exposes `setPrompt(threadRef, prompt)`.
- `apps/web/src/lib/chatThreadActions.ts` has `startNewThreadFromContext`.
- `apps/web/src/keybindings.ts` matches commands like `"diff.toggle"`.
- The Claude provider loads `user`, `project` and `local` setting sources
  (`apps/server/src/provider/ClaudeProvider.ts`), so project `.claude/commands/opsx/*` should
  be available in Claude threads. Task 1.1 confirms this before building UI on it.

## Goals / Non-Goals

**Goals**

- See and drive OpenSpec changes without leaving the thread.
- Zero server changes; read files through existing RPCs.

**Non-Goals**

- Editing artifacts in the panel (the file preview/editor already does that).
- Running the `openspec` CLI from the panel (later: a Validate button via the terminal).
- OpenSpec Stores (multi-repo planning repos).
- Rendering spec deltas as a structured diff.

## Decisions

### D1. Singleton surface kind `openspec`

Add `"openspec"` to `RIGHT_PANEL_KINDS` and `{ id: "openspec"; kind: "openspec" }` to the
surface union, mirroring `files`. Add the two `case "openspec"` branches in
`RightPanelTabs.tsx` that delegate to the fork module. All real UI lives in
`apps/web/src/fork/openspec/`.

- _Watch:_ `migratePersistedRightPanelState` must accept the new kind so a persisted panel
  state containing `openspec` survives reload; and an upstream build reading fork-persisted
  state should drop the unknown kind rather than crash (check its behaviour in task 2.1).

### D2. Discovery and parsing are pure functions

`openspecModel.ts` builds a model from directory listings + file contents:
`{ changes: ChangeSummary[], archived: ArchivedChange[], specs: SpecEntry[] }`.
`parseTaskProgress(tasksMd)` implements OpenSpec's rule: a checkbox counts as done only if
its box contains just `x`/`X` with any spacing; other markers count as not done; lines
without a checkbox are ignored. Unit-tested without React.

- _Alternative rejected:_ calling `openspec list --json` through the server. Requires a new
  RPC and the CLI on the server host; file reading is enough for the panel's needs.

### D3. Data loading through existing RPCs, refreshed on workspace mutations

`useOpenSpecProject(environmentId, cwd)` lists `openspec/`, `openspec/changes/`,
`openspec/changes/archive/`, `openspec/specs/` (recursively for capability paths), reads each
active change's `tasks.md`, and exposes `refresh()`. Three refresh triggers:

1. `useWorkspaceMutationRefresh` with the thread's `workspaceMutationId`, as `FileBrowserPanel`
   does. In `ChatView.tsx` that id only advances when a command or file change completes in
   the thread being viewed, so it misses work done in other threads ("Apply in new thread")
   and possibly work done inside subagents.
2. A poll every 10 s while the panel is visible and `document.visibilityState === "visible"`.
3. An immediate refresh on `window` focus / `visibilitychange` to visible.
   Plus a manual refresh button. Reads are limited to active changes' `tasks.md` (a handful of
   small files per poll); archived changes and specs are only listed until opened.

### D4. Actions go through the composer, never auto-send

Apply/Verify/Archive call `setPrompt` with the command prepended as a new first line
(keeping any draft), then focus the composer. "Apply in new thread" opens a new thread
through the existing new-thread flow (`startNewThreadFromContext` in
`lib/chatThreadActions.ts`) and then pre-fills its draft; the worktree option reuses the
existing new-thread worktree flow rather than calling git directly.

- _Unproven:_ `startNewThreadFromContext` returns only a boolean, not the new thread or its
  draft target, so how to address the new draft is unknown. Task 4.2 is a spike that finds
  the draft key (e.g. the project's new-draft target in `composerDraftStore.ts`) before any
  UI is built on it. Fallback if no clean hook exists: open the new thread and copy the
  command to the clipboard with a toast, so the user pastes it.
  Command spelling is fixed to the Claude form `/opsx:<cmd>`; other providers' spellings are
  a non-goal for now.

### D5. Visibility check

The tab is offered when `openspec/` exists at the workspace root (checked with the same
listing hook). Absence is cached per workspace and re-checked on workspace mutations so
`openspec init` makes the tab appear.

## Touch points (existing upstream files edited)

- `apps/web/src/rightPanelStore.ts` — add kind, surface type, persisted-state acceptance.
- `apps/web/src/components/RightPanelTabs.tsx` — two `case "openspec"` branches + a way to open the tab (same place the Files tab is offered).
- `apps/web/src/keybindings.ts` (and the default keybindings list) — `"openspec.toggle"`.

## New files

- `apps/web/src/fork/openspec/openspecModel.ts` (+ test) — parsing and model building.
- `apps/web/src/fork/openspec/useOpenSpecProject.ts` (+ test) — loading/refresh hook.
- `apps/web/src/fork/openspec/OpenSpecPanel.tsx` (+ test) — the panel UI.
- `apps/web/src/fork/openspec/openspecActions.ts` (+ test) — composer insertion and new-thread apply.
- `apps/web/src/fork/openspec/OpenSpecTabLabel.tsx` — tab icon/label.

## Risks / Trade-offs

- [Project slash commands not loaded in Claude threads] → task 1.1 verifies first; if missing, the actions still insert the text but the agent won't recognise it — fix in the provider before continuing.
- [Big repos with many archived changes] → archived list is lazy (names only until expanded).
- [`rightPanelStore.ts` is large and busy upstream] → edits are additive one-liners; re-apply on rebase is mechanical.
- [OpenSpec changes its folder layout] → paths are constants in `openspecModel.ts`; one place to update.

## Migration Plan

Pure addition. Rollback = remove the touch-point edits; a persisted `openspec` surface is dropped by the migration on next load.
