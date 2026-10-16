# Proposal

## Original request

> custom background, diffs, explorer, comments on code/markdowns to agent, openspec support

Diffs, the file explorer and comments on code already exist upstream; this change covers the part named in its title.

## Why

T3 Code lets me comment on lines in a diff or a file's source view and sends those comments to the agent with my next prompt. But Markdown files open in a rendered preview, and there I can't comment at all. Reviewing OpenSpec proposals, designs and specs is mostly reading rendered Markdown, so the review loop breaks exactly where I need it most: I have to switch to the raw source, find the lines again, and comment there.

## What Changes

- Let me select text in the rendered Markdown preview and add a comment on it.
- The comment is attached to my next prompt in the same format as existing file comments: file path, source line range and the quoted Markdown source.
- Commented passages stay highlighted in the preview, and comments can be edited or removed before sending, matching the source view.
- Comments made in the preview and in the source view of the same file appear together in the composer.
- Chat message rendering is unchanged.

## Capabilities

### New Capabilities

- `markdown-review-comments`: commenting on passages of a rendered Markdown file preview and sending those comments, anchored to source lines, to the agent.

### Modified Capabilities

None.

## Impact

- `ChatMarkdown` gains an opt-in way to tag rendered blocks with their source line range (off by default, so chat is unaffected).
- `FileMarkdownPreview` gains a comment layer; `FilePreviewPanel` passes it the existing review-comment callbacks.
- Reuses `buildFileReviewComment` / `addReviewComment`; no new prompt format, contract or server change.
- Unlocks reviewing OpenSpec artifacts inside the app (used by the `add-openspec-panel` change).
