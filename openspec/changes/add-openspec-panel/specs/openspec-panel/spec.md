# Spec Delta

## Purpose

Gives the user an in-app view of a project's OpenSpec changes and specs, with task progress and one-click shortcuts that run the OpenSpec workflow through the composer.

## ADDED Requirements

### Requirement: Show the panel only for OpenSpec projects

The system SHALL offer an OpenSpec tab in the right panel for a thread whose workspace contains an `openspec/` directory, and SHALL NOT offer it otherwise.

#### Scenario: Project with OpenSpec

- **WHEN** the thread's workspace root contains `openspec/changes/`
- **THEN** an OpenSpec tab is available in the right panel and through its keybinding

#### Scenario: Project without OpenSpec

- **WHEN** the workspace has no `openspec/` directory
- **THEN** no OpenSpec tab is offered and the keybinding does nothing

#### Scenario: OpenSpec initialised later

- **WHEN** `openspec init` creates the folder while the thread is open
- **THEN** the tab becomes available without restarting the app

### Requirement: List active changes with progress

The system SHALL list every folder under `openspec/changes/` except `archive`, showing the change id and task progress counted from checkbox lines in its `tasks.md`.

#### Scenario: Progress from tasks

- **WHEN** a change's `tasks.md` has 10 checkbox tasks and 4 are marked done
- **THEN** the change shows 4/10 with a matching progress bar

#### Scenario: Checkbox parsing matches OpenSpec

- **WHEN** a task line is `- [X] 1.1 ...` or `- [ x] 1.1 ...`
- **THEN** it counts as done, while `- [ ]`, `- [~]`, `- [-]` and `- []` count as not done

#### Scenario: No tasks yet

- **WHEN** a change has no `tasks.md`
- **THEN** it shows "No tasks yet" instead of a progress bar

#### Scenario: Complete change

- **WHEN** every task in a change is done
- **THEN** the change is marked ready to verify/archive

### Requirement: Browse change artifacts

The system SHALL show, for a selected change, which of `proposal.md`, `design.md`, `tasks.md` and `specs/**/spec.md` exist, and SHALL open any of them in the existing file preview when clicked.

#### Scenario: Open an artifact

- **WHEN** the user clicks `proposal.md` for a change
- **THEN** the file opens in the right panel's file preview

#### Scenario: Missing artifact

- **WHEN** a change has no `design.md`
- **THEN** design is shown as not created rather than hidden

### Requirement: Browse archived changes and specs

The system SHALL show collapsed sections listing archived changes and the main specs under `openspec/specs/`, each openable in the file preview.

#### Scenario: Open a main spec

- **WHEN** the user expands Specs and clicks a capability
- **THEN** its `spec.md` opens in the file preview

### Requirement: Insert OpenSpec commands into the composer

The system SHALL provide Apply, Verify and Archive actions for a change that insert `/opsx:apply <id>`, `/opsx:verify <id>` or `/opsx:archive <id>` into the current thread's composer without sending it.

#### Scenario: Apply action

- **WHEN** the user clicks Apply on change `add-dark-mode`
- **THEN** the composer contains `/opsx:apply add-dark-mode` and focus moves to the composer
- **AND** nothing is sent until the user sends it

#### Scenario: Composer has a draft

- **WHEN** the composer already contains text and the user clicks an action
- **THEN** the command is inserted on a new first line and the existing draft is kept

### Requirement: Apply in a new thread

The system SHALL provide an Apply in new thread action that creates a new thread in the same project with `/opsx:apply <id>` in its composer, unsent, optionally on a new worktree.

#### Scenario: New thread

- **WHEN** the user chooses Apply in new thread for a change
- **THEN** a new thread opens in the same project with `/opsx:apply <id>` ready in its composer, unsent

#### Scenario: Pre-fill unavailable

- **WHEN** the new thread's composer cannot be pre-filled
- **THEN** the new thread still opens, the command is copied to the clipboard, and a notice tells the user to paste it

#### Scenario: New worktree

- **WHEN** the user chooses Apply in new thread with "new worktree" selected
- **THEN** the new thread starts on a new worktree using the project's normal worktree flow

### Requirement: Stay in sync with the files

The system SHALL refresh the panel after the agent or the user changes files under `openspec/`, including changes made by another thread, and SHALL offer a manual refresh.

#### Scenario: Agent ticks a task in this thread

- **WHEN** the agent in the thread showing the panel marks a task done in `tasks.md`
- **THEN** the change's progress updates without the user reopening the panel

#### Scenario: Agent ticks a task in another thread

- **WHEN** a task is ticked by an agent in a different thread while the panel is visible
- **THEN** the progress updates within 15 seconds

#### Scenario: Returning to the app

- **WHEN** the browser tab regains focus after files changed
- **THEN** the panel refreshes immediately

#### Scenario: Panel hidden

- **WHEN** the panel is not visible or the browser tab is in the background
- **THEN** the system does not poll the server

#### Scenario: Change archived

- **WHEN** `/opsx:archive` moves a change into `changes/archive/`
- **THEN** it disappears from active changes and appears under archived changes

### Requirement: Read-only and safe

The panel SHALL NOT write, move or delete files itself; all changes to OpenSpec files happen through the agent or the file editor.

#### Scenario: Unreadable file

- **WHEN** a `tasks.md` cannot be read
- **THEN** that change shows an error marker and the rest of the panel still works
