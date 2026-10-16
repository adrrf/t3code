# Tasks

## 1. Source-line tagging

- [ ] 1.1 [standard] Create `apps/web/src/fork/markdown/rehypeSourceLines.ts`: a rehype plugin that adds `data-source-start` and `data-source-end` (1-based lines from `node.position`) to headings, paragraphs, list items, blockquotes, table rows, `pre` blocks and thematic breaks; verify with unit tests covering each block type, nested lists, a table and a GitHub alert block
- [ ] 1.2 [heavy] Add an optional `sourceLineAttributes` prop to `ChatMarkdown.tsx` that appends the plugin only when true, marked `// fork:`; verify with a test that output with the prop off is identical to upstream (snapshot of an existing `ChatMarkdown.test.tsx` fixture) and with it on contains the attributes (heavy: `ChatMarkdown` renders every chat message)
- [ ] 1.3 [light] Run `pnpm typecheck`, `pnpm lint`, the new plugin tests and `vp test run apps/web/src/components/ChatMarkdown.test.tsx`; all pass (light: commands only)

## 2. Selection mapping

- [ ] 2.1 [standard] Create `apps/web/src/fork/markdown/selectionToLineRange.ts`: given the preview root and a DOM `Range`, return `{ startLine, endLine }` from the nearest tagged ancestors, or `null` if either end is outside the root or untagged; verify with jsdom tests for: words inside one paragraph, a selection across heading→list item, a selection inside a code block, a selection starting outside the preview (null)
- [ ] 2.2 [light] Run `pnpm typecheck`, `pnpm lint` and the selection tests; all pass (light: commands only)

## 3. Comment layer in the preview

- [ ] 3.1 [heavy] Read how the source view in `FilePreviewPanel.tsx` initialises `lineAnnotations`; if it does not already seed from the composer's pending review comments for this file, add a small seeding step (marked `// fork:`); verify by adding a comment in the source view, switching to preview and back, and seeing it still there (heavy: shared state between the editor and the composer draft store)
- [ ] 3.2 [standard] Create `apps/web/src/fork/markdown/MarkdownCommentLayer.tsx`: shows a floating Comment button at the selection rect when `selectionToLineRange` returns a range; opens an editor anchored to the block; saves with `buildFileReviewComment` + `addReviewComment` (new id from `nextFileCommentId`); submits on the shortcut from `commentSubmitShortcut.ts`; verify with component tests for button visibility, save calling `addReviewComment` with the right line range, and Escape cancelling
- [ ] 3.3 [standard] Derive highlights from the composer draft store (review comments for this thread with matching `filePath`), draw highlight boxes over the commented blocks and recompute positions with a `ResizeObserver` and on scroll; each highlight offers Edit and Remove (Remove calls `removeReviewComment`); verify with component tests that adding/removing in the store adds/removes the highlight
- [ ] 3.4 [heavy] Wrap the output of `FileMarkdownPreview.tsx` in `MarkdownCommentLayer` with `sourceLineAttributes` on, and pass `composerDraftTarget`, contents and callbacks from `FilePreviewPanel.tsx` (marked `// fork:`); disable the layer when the preview is read-only for an attachment that is not a workspace file; verify the existing `FilePreviewPanel.test.ts` still passes (heavy: edits a large, busy upstream component)
- [ ] 3.5 [light] Run `pnpm typecheck`, `pnpm lint` and all tests in groups 1–3; all pass (light: commands only)

## 4. Manual verification

- [ ] 4.1 [standard] In `pnpm dev:share` from a tailnet browser, open a long `.md` file: comment on part of a paragraph, across a heading and list, and inside a code block; send a prompt and confirm the agent message contains file path, correct line ranges and quoted source for all three
- [ ] 4.2 [standard] Confirm a comment made in the preview shows in the source view at the same lines, and vice versa; removing from the composer removes the preview highlight
- [ ] 4.3 [standard] Select text in an assistant chat message and confirm no Comment button appears and the message looks unchanged
- [ ] 4.4 [standard] Scroll and resize the panel with pending comments and confirm highlights stay aligned with their blocks, including after images in the file finish loading; repeat once on a phone browser
