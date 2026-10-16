# Spec Delta

## Purpose

Lets the user review a Markdown file in its rendered form and send comments on specific passages to the coding agent, anchored to the exact source lines.

## ADDED Requirements

### Requirement: Start a comment from a selection

The system SHALL show a Comment action when the user selects text inside a rendered Markdown file preview, and SHALL open a comment editor anchored to that selection when the action is used.

#### Scenario: Select and comment

- **WHEN** the user selects text in a rendered `.md` or `.mdx` file preview
- **THEN** a Comment button appears next to the selection
- **AND** clicking it opens a comment editor beside the selected passage

#### Scenario: Selection outside the preview

- **WHEN** the selection starts or ends outside the Markdown preview
- **THEN** no Comment button is shown

#### Scenario: Keyboard submit

- **WHEN** the comment editor is open and the user presses the same submit shortcut used for diff comments
- **THEN** the comment is saved

### Requirement: Anchor comments to source lines

The system SHALL resolve a rendered selection to the smallest source line range covering every rendered block the selection touches.

#### Scenario: Selection inside one paragraph

- **WHEN** the user comments on words inside a paragraph that spans source lines 12–14
- **THEN** the comment's range is lines 12–14

#### Scenario: Selection across blocks

- **WHEN** the selection starts in a heading on line 5 and ends in a list item on line 9
- **THEN** the comment's range is lines 5–9

#### Scenario: Selection in a code block

- **WHEN** the selection is inside a fenced code block spanning lines 20–30
- **THEN** the comment's range is lines 20–30

### Requirement: Send comments to the agent

The system SHALL attach each saved preview comment to the thread's next prompt with the file path, source line range, comment text and quoted Markdown source of that range, in the same format as source-view file comments.

#### Scenario: Comment attached to prompt

- **WHEN** the user saves a preview comment and then sends a prompt
- **THEN** the agent receives the comment with the file path, line range, comment text and the Markdown source of that range

#### Scenario: Preview and source comments together

- **WHEN** the user comments on the same file in both the preview and the source view
- **THEN** all comments appear together in the composer and are sent together

### Requirement: Show and manage pending comments

The system SHALL highlight passages that have pending comments and SHALL let the user edit or remove each comment before sending.

#### Scenario: Highlight

- **WHEN** a preview comment is pending
- **THEN** the commented blocks are visibly highlighted in the preview

#### Scenario: Remove

- **WHEN** the user removes a pending comment from the preview or from the composer
- **THEN** it is removed in both places and the highlight disappears

#### Scenario: Switching views

- **WHEN** the user switches between preview and source view of a file with pending comments
- **THEN** the comments remain pending and visible at the same lines in both views

### Requirement: Chat rendering is unchanged

The system SHALL NOT show comment actions or source-line markup in chat messages or other Markdown outside file previews.

#### Scenario: Selecting text in chat

- **WHEN** the user selects text in an assistant message
- **THEN** no Comment button appears and the message renders exactly as before
