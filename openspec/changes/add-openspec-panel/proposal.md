# Proposal

## Original request

> custom background, diffs, explorer, comments on code/markdowns to agent, openspec support

Diffs, the file explorer and comments on code already exist upstream; this change covers the part named in its title.

## Why

My workflow is OpenSpec: explore → propose → review → apply in a fresh context → verify → archive. In T3 Code all of that is invisible. I can't see which changes are in flight or how far along their tasks are, and running each step means remembering change ids and retyping `/opsx:*` commands. Applying in a clean context (which OpenSpec recommends) means manually creating a new thread and pasting the command.

## What Changes

- Add an **OpenSpec** tab to the right panel, next to Diff and Files, shown only for projects that contain an `openspec/` folder.
- List active changes with task progress parsed from each change's `tasks.md`, plus collapsed lists of archived changes and main specs.
- Show a change's artifacts (proposal, design, specs, tasks); opening one uses the existing file preview, so Markdown review comments work on it.
- Action buttons that put `/opsx:apply`, `/opsx:verify` or `/opsx:archive` for the selected change into the composer for me to review and send — never auto-sent.
- **Apply in new thread**: starts a fresh thread in the same project with `/opsx:apply <id>` pre-filled, optionally on a new worktree.
- Refresh automatically when the agent edits files under `openspec/`.
- A keybinding to toggle the tab.

## Capabilities

### New Capabilities

- `openspec-panel`: an in-app view of a project's OpenSpec changes and specs, with task progress and shortcuts that drive the OpenSpec commands through the composer.

### Modified Capabilities

None.

## Impact

- New right-panel surface kind `openspec` (small hook points in `rightPanelStore.ts`, `RightPanelTabs.tsx`, keybindings).
- New `apps/web/src/fork/openspec/` module: discovery, parsing, panel UI.
- Reads files through the existing project RPCs (`projects.listEntries`, `projects.readFile`); no server or contract change.
- Depends on the OpenSpec slash commands being installed in the project (`openspec init` / `openspec update`) and on the agent loading project commands.
- Works best with `add-markdown-preview-comments`, but doesn't require it.
