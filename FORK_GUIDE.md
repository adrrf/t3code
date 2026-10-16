# Building my T3 Code fork with OpenSpec

Three OpenSpec changes, ready to apply in order. The full system (agents, server, security,
operations) is in the "Agent System & Setup" doc; this file is the short version for the fork.

| Order | Change                          | What it adds                                                           | Tasks |
| ----- | ------------------------------- | ---------------------------------------------------------------------- | ----- |
| 1     | `add-custom-background`         | Image behind the app, with dim / blur / fit, stored per browser        | 17    |
| 2     | `add-markdown-preview-comments` | Comment on rendered `.md` files and send it to the agent               | 14    |
| 3     | `add-openspec-panel`            | OpenSpec tab: changes, task progress, Apply / Verify / Archive buttons | 17    |

Every task is already tagged `[light]`, `[standard]` or `[heavy]`, and `openspec/config.yaml`
tells `/opsx:apply` to delegate each task to the matching subagent instead of doing it itself.

## 1. Set up the development checkout (once, on the server, as the `agent` user)

```bash
# Fork pingdotgg/t3code on GitHub, then:
git clone git@github.com:<you>/t3code.git ~/src/t3code && cd ~/src/t3code
git remote add upstream https://github.com/pingdotgg/t3code.git
git checkout -b my-fork

# Toolchain: Node 24.13+, pnpm 11, Vite+ (`vp`): https://viteplus.dev/guide/
pnpm install
pnpm dev:share          # dev server over the tailnet; open the printed pairing URL
```

The running service uses a separate stable checkout (see the doc); agents never touch it.

## 2. Add OpenSpec and these changes

```bash
npm install -g @fission-ai/openspec@latest
openspec init --tools claude
openspec config profile               # expanded profile (adds /opsx:verify)
openspec update
unzip ~/t3code-fork-openspec.zip -d . # overwrites openspec/config.yaml, adds the 3 changes
openspec validate --all --strict      # should report 3 passed
git add openspec .claude && git commit -m "Add OpenSpec plan for fork features"
```

## 3. Build each change

For each change, in order:

1. **Review first.** Read `proposal.md`, `specs/…/spec.md`, `design.md` and `tasks.md`,
   including the tier tags. Edit anything you disagree with now.
2. **Fresh thread on Opus 5.5:** `/opsx:apply add-custom-background`. The session delegates
   each task by tier (at most 3 at once), ticks tasks after each worker's check passes, then
   sends everything to the reviewer.
3. Read the reviewer's report, then try the feature yourself with `pnpm dev:share`.
4. `/opsx:archive add-custom-background`, commit, push.

Then repeat for `add-markdown-preview-comments` and `add-openspec-panel`.

Notes:

- `add-openspec-panel` task 1.1 checks that `/opsx:*` commands and your subagents work inside
  T3 Code's Claude threads. Don't skip it.
- Task 4.2 of that change is a spike: "Apply in new thread" may fall back to copying the
  command to the clipboard if the new thread's composer can't be pre-filled cleanly.

## 4. Keep up with upstream

```bash
git fetch upstream
git checkout main && git merge --ff-only upstream/main && git push origin main
git checkout my-fork && git rebase main
git grep -n "// fork:"                 # re-check every touch point
git push --force-with-lease origin my-fork
```

All other fork code is in new files, mostly under `apps/web/src/fork/`, which can't conflict.
No change adds dependencies, so `pnpm-lock.yaml` never conflicts because of the fork.
