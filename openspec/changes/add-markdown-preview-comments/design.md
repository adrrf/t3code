# Design

## Context

See proposal.md for motivation. Relevant current state in upstream T3 Code:

- `components/files/FilePreviewPanel.tsx` shows Markdown files in a preview surface that
  renders `<FileMarkdownPreview>` inside a `ScrollArea` (around line 990). The editable
  source surface in the same file supports line comments via `@pierre/diffs` line
  annotations (`fileCommentAnnotations.ts`).
- Saved file comments go to the composer through
  `addReviewComment(composerDraftTarget, buildFileReviewComment({...}))` and are removed
  with `removeReviewComment`. `buildFileReviewComment` (in `reviewCommentContext.ts`) takes
  a 1-based line range and the file contents and produces the quoted context sent to the agent.
- `components/files/FileMarkdownPreview.tsx` is a 34-line wrapper around `ChatMarkdown`.
- `ChatMarkdown` uses `react-markdown`; mdast/hast nodes already carry `position`
  (it reads `node.position.start.offset` for task-list toggling).
- `components/diffs/commentSubmitShortcut.ts` defines the comment submit shortcut.

## Goals / Non-Goals

**Goals**

- Comment on any rendered passage of a Markdown file and reuse the existing comment pipeline.
- One source of truth for pending comments shared by preview and source view.

**Non-Goals**

- Character-level anchors (comments anchor to whole source lines, like code comments).
- Comments in chat messages, PR descriptions or other Markdown surfaces.
- Persisting comments to disk or into the Markdown file.

## Decisions

### D1. Tag rendered blocks with source lines, opt-in

Add an optional prop to `ChatMarkdown` (e.g. `sourceLineAttributes`). When true, a small
rehype step adds `data-source-start` / `data-source-end` (1-based lines from
`node.position`) to block-level elements: headings, paragraphs, list items, blockquotes,
table rows, code blocks and thematic breaks. Default false, so chat output is byte-identical.

- _Alternative rejected:_ fuzzy text search of the selected words in the source. Breaks on
  repeated phrases, inline formatting and links.
- _Alternative rejected:_ a separate Markdown renderer for previews. Duplicates link,
  image and task-list handling that `ChatMarkdown` already does.

### D2. Map a DOM selection to a line range

On selection end, walk from the range's start and end containers up to the nearest element
with `data-source-start`; the comment range is `min(start)`–`max(end)` of the two blocks.
If either side has no tagged ancestor inside the preview root, no action is shown.
Pure function in its own file so it's unit-testable with jsdom.

### D3. Composer draft store is the single source of truth

Pending comments already live in the composer draft (`addReviewComment` keyed by comment id,
with `filePath`, `startIndex`, `endIndex`). The preview derives its highlights by selecting
that thread's review comments where `filePath` matches. Saving from the preview calls
`addReviewComment(buildFileReviewComment(...))`; removing calls `removeReviewComment`.
The source view gets the same comments by seeding its `lineAnnotations` from the store when
it mounts (task 3.1 checks whether it already does).

- _Why:_ avoids lifting `lineAnnotations` state out of the source surface (large upstream edit)
  and keeps composer, preview and source view consistent.

### D4. Comment UI as an overlay, not inline DOM edits

A new `MarkdownCommentLayer` wraps the preview: it positions a floating Comment button at
the selection rect, a comment editor beside the anchored block, and highlight boxes over
commented blocks using their bounding rects (recomputed on scroll/resize via
`ResizeObserver`). It doesn't modify the rendered Markdown DOM, so it can't break
`ChatMarkdown` features (links, task lists, find).
Reuse the visual style of `DiffCommentAnnotation` for the editor where practical.

## Touch points (existing upstream files edited)

- `apps/web/src/components/ChatMarkdown.tsx` — accept `sourceLineAttributes` and add the rehype step when true (small, guarded).
- `apps/web/src/components/files/FileMarkdownPreview.tsx` — wrap output in `MarkdownCommentLayer`, pass `sourceLineAttributes`.
- `apps/web/src/components/files/FilePreviewPanel.tsx` — pass `composerDraftTarget`, file contents and the add/remove callbacks to the preview; seed source-view annotations from the store if needed.

## New files

- `apps/web/src/fork/markdown/rehypeSourceLines.ts` (+ test)
- `apps/web/src/fork/markdown/selectionToLineRange.ts` (+ test)
- `apps/web/src/fork/markdown/MarkdownCommentLayer.tsx` (+ test)

## Risks / Trade-offs

- [Some block types lack `position` after plugins transform the tree] → fall back to the nearest tagged ancestor; test tables, nested lists, GitHub alerts and code blocks explicitly.
- [Overlay positions drift when content reflows, e.g. images loading] → recompute on `ResizeObserver` of the preview root and on scroll.
- [Large files: tagging every block costs render time] → attributes are only added for file previews, and only to block elements.
- [Upstream refactors `ChatMarkdown`] → the change there is one prop and one plugin entry; easy to re-apply.

## Migration Plan

Pure addition. Rollback = drop the three touch-point edits.
