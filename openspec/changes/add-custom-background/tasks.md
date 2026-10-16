# Tasks

## 1. Background store

- [ ] 1.1 [standard] Create `apps/web/src/fork/backgroundStore.ts`: a zustand store (persisted with `resolveStorage` from `lib/storage`) holding `dim` (0–90, default 60), `blur` (0–40, default 8), `fit` (`cover` | `contain` | `tile`, default `cover`) and `hasImage`; verify with a unit test that defaults load and out-of-range values are clamped
- [ ] 1.2 [standard] Add blob storage helpers in the same file (`loadBackgroundBlob`, `saveBackgroundBlob`, `deleteBackgroundBlob`) behind a small `BackgroundBlobStore` interface, with an IndexedDB implementation using the plain IndexedDB API and an in-memory implementation for tests; any storage error resolves to "no image". Add no dependencies (no `fake-indexeddb`); verify with tests against the in-memory implementation, including a store that throws
- [ ] 1.3 [light] Add `validateBackgroundFile(file)` that accepts PNG/JPEG/WebP/GIF up to 20 MB and returns a typed error otherwise; verify with unit tests for each accepted type, a wrong type and a 21 MB file (light: rules fully specified here)
- [ ] 1.4 [light] Run `pnpm typecheck`, `pnpm lint` and `vp test run apps/web/src/fork/backgroundStore.test.ts`; all pass (light: commands only)

## 2. Background layer

- [ ] 2.1 [standard] Create `apps/web/src/fork/AppBackground.tsx`: loads the blob, creates an object URL (revoked on change/unmount), renders a fixed full-window layer at `z-index: -1` with fit, blur (over-sized to hide edges) and a dimming overlay mixed towards `var(--background)`; renders nothing when there is no image; verify with a component test for "no image renders nothing" and "image renders with expected styles"
- [ ] 2.2 [light] While an image is shown, set `data-fork-background="on"` on `document.documentElement` and remove it when hidden or unmounted; verify in the same test file (light: behaviour fully specified)
- [ ] 2.3 [standard] Mount `<AppBackground />` once in `apps/web/src/routes/__root.tsx` inside the main app return, marked `// fork:` (1–2 lines); verify with `pnpm dev:share` from a tailnet browser that the app looks unchanged with no image set
- [ ] 2.4 [light] Run `pnpm typecheck`, `pnpm lint` and the AppBackground tests; all pass (light: commands only)

## 3. Let the image show through

- [ ] 3.1 [standard] With a test image set (temporarily via the store in dev tools), audit the app in `pnpm dev:share` and list in this task's notes every top-level shell container (sidebar, main chat column, right panel, composer area, settings page) that still paints an opaque background; verify the list covers every opaque patch seen on screen
- [ ] 3.2 [standard] Create `apps/web/src/fork/background.css` with rules scoped to `html[data-fork-background="on"]` that make those containers use the existing glass treatment (`--glass-opacity` + backdrop blur) instead of opaque `--background`; import it from `apps/web/src/main.tsx` after `index.css`, marked `// fork:`; verify in `pnpm dev:share` that the image shows through all panels at Glass opacity 80% and panels are opaque at 100%
- [ ] 3.3 [standard] Check both a light and a dark theme with the image set and confirm chat text, code blocks and diff text stay readable at default dim/blur; verify by hand and note any surface that needed an extra rule
- [ ] 3.4 [standard] Remove the image and confirm the app is visually identical to before (compare a screenshot of the same thread before the change and after removal)

## 4. Settings UI

- [ ] 4.1 [standard] Create `apps/web/src/components/settings/BackgroundSettings.tsx` with: Choose image button (file input limited to image types), thumbnail preview, Dimming slider (0–90%), Blur slider (0–40 px), Fit selector (Cover/Contain/Tile) and Remove button; validation errors show inline; a short note says the image is saved in this browser only; verify with a component test that an invalid file shows the error and leaves the store unchanged
- [ ] 4.2 [light] Render `<BackgroundSettings />` from `ThemeSettings.tsx` near the existing glass/appearance controls, marked `// fork:` (1–2 lines); verify the section appears under Settings → Appearance (light: one-line insert at a named spot)
- [ ] 4.3 [standard] Verify by hand in `pnpm dev:share`: setting an image applies within one second without reload; sliders update live; Tile repeats at natural size; resizing with Cover never distorts; a reload restores image and options; Remove deletes it and a reload keeps it gone
- [ ] 4.4 [light] Run `pnpm typecheck`, `pnpm lint` and all tests touched in groups 1–4; all pass (light: commands only)

## 5. Integration check

- [ ] 5.1 [standard] Run `vp run --filter t3 build` (server + web) and `vp run --filter @t3tools/desktop build` (desktop still compiles); confirm the background works when the built server is opened from a tailnet browser; confirm `git diff upstream/main --stat` shows only the three planned upstream touch points outside new files and that `pnpm-lock.yaml` is unchanged
