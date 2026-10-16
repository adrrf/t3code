@AGENTS.md

## Fork notes

- All fork code goes in new files, mostly under apps/web/src/fork/.
- Mark every edit to an upstream file with `// fork:`.
- Add no dependencies (runtime or dev); pnpm-lock.yaml must not change.
- Verify with: pnpm typecheck, pnpm lint, vp test run <files>.
- Manual checks use `pnpm dev:share`, never `pnpm dev:desktop` (headless server).
- Commits follow Conventional Commits: `type(scope): summary`, imperative,
  lower case, no trailing period, max 72 characters (feat, fix, test, refactor,
  style, docs, chore).
- Always [heavy]: rightPanelStore.ts, ChatMarkdown.tsx, composerDraftStore.ts,
  FilePreviewPanel.tsx, RightPanelTabs.tsx, anything under packages/contracts or apps/server.
- Usually [light]: CSS in apps/web/src/fork/*.css, docs, running check commands.
