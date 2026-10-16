# Design

## Context

See proposal.md for motivation. Relevant current state in upstream T3 Code:

- `packages/contracts/src/settings.ts` already has a `glassOpacity` client setting (40–100, default 80).
- `apps/web/src/routes/__root.tsx` writes it to the `--glass-opacity` CSS variable.
- `apps/web/src/index.css` defines `surface-glass` utilities that paint
  `color-mix(var(--background) var(--glass-opacity), transparent)` with a backdrop blur.
- Theme settings live in `apps/web/src/components/settings/ThemeSettings.tsx`.

So translucency already exists; what's missing is something worth seeing behind it.

## Goals / Non-Goals

**Goals**

- One image behind the whole app, controlled from Appearance settings.
- Zero visual change when no image is set.
- No edits to contracts, server or desktop main process.

**Non-Goals**

- Per-project or per-theme backgrounds (possible later).
- Video or animated-shader backgrounds.
- Syncing the image across devices.

## Decisions

### D1. Store locally in the web client, not in the settings contract

The image (a `Blob`) goes in IndexedDB; the small numeric options (dim, blur, fit) go in a
zustand store persisted to `localStorage` via the existing `resolveStorage` helper in
`apps/web/src/lib/storage`.
The blob store sits behind a small interface with an IndexedDB implementation and an
in-memory one for tests, so no test dependency (e.g. `fake-indexeddb`) is added and
`pnpm-lock.yaml` stays untouched. Storage is per browser: each device sets its own image.

- _Why:_ client settings are a shared contract that syncs through the server; a multi-MB
  data URL there would bloat every settings round-trip and touch upstream schema code.
- _Alternative rejected:_ add `backgroundImage` to `settings.ts`. More "native", but
  guarantees merge conflicts in a very busy file and puts large blobs in sync traffic.

### D2. One fixed layer at the app root, under everything

A new `AppBackground` component renders a `position: fixed; inset: 0; z-index: -1`
`<div>` with the image as `background-image` (object URL from the blob), plus a dimming
overlay that mixes towards `var(--background)`. Blur uses `filter: blur()` on the image
layer only, with the layer slightly over-sized to hide blurred edges.

- _Why:_ a single layer is cheap, and every glass surface already blurs what's behind it.

### D3. Make the app shell transparent only while an image is set

When an image is active, the layer sets `data-fork-background="on"` on `<html>`. A new
`apps/web/src/fork/background.css` scopes overrides to that attribute so the top-level
shell containers that currently paint an opaque `bg-background` become `surface-glass`
(or transparent). Without the attribute, nothing changes.

- _Why:_ keeps upstream components untouched; all overrides live in one fork file.
- _Alternative rejected:_ editing each shell component's classes — many conflict points.

### D4. Release object URLs

The component creates one object URL per loaded blob and revokes it on change/unmount to
avoid leaking memory when the user swaps images repeatedly.

## Touch points (existing upstream files edited)

- `apps/web/src/components/settings/ThemeSettings.tsx` — render `<BackgroundSettings />` (1–2 lines).
- `apps/web/src/routes/__root.tsx` — mount `<AppBackground />` once inside the main app return (1–2 lines).
- `apps/web/src/main.tsx` (or the existing CSS entry) — import `fork/background.css` (1 line).

## New files

- `apps/web/src/fork/backgroundStore.ts` (+ test) — zustand store for options, IndexedDB get/put/delete for the blob, validation (type, 20 MB limit).
- `apps/web/src/fork/AppBackground.tsx` (+ test) — the fixed layer.
- `apps/web/src/fork/background.css` — scoped shell overrides.
- `apps/web/src/components/settings/BackgroundSettings.tsx` — picker, thumbnail, sliders, fit, Remove.

## Risks / Trade-offs

- [Busy images make text unreadable] → defaults of 60% dim and 8 px blur; dimming mixes towards the theme background so it works in light and dark themes.
- [Some shell containers aren't covered by the CSS override, leaving opaque patches] → task 3.1 audits the shell with the image on and lists every container that needs a rule.
- [Large blur on a full-window layer costs GPU on low-end machines] → blur max is 40 px and blur is applied once to a static layer, not per surface.
- [Upstream renames shell classes] → overrides use a few stable selectors and live in one file, so a rebase break is easy to spot and fix.

## Migration Plan

Pure addition. Rollback = remove the three touch-point lines; stored data is ignored.
