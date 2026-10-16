# Proposal

## Original request

> custom background, diffs, explorer, comments on code/markdowns to agent, openspec support

Diffs, the file explorer and comments on code already exist upstream; this change covers the part named in its title.

## Why

T3 Code has a full theme editor and translucent "glass" surfaces, but the only thing behind the glass is a flat colour (or the OS window material on desktop). I want my own image behind the app so the fork feels like mine, without giving up readability.

## What Changes

- Add a **Background** section to Appearance settings: choose an image, adjust dimming and blur, choose fit (cover / contain / tile), and remove it.
- Render the chosen image as a fixed layer behind the whole app, under the existing glass surfaces, so the existing **Glass opacity** slider controls how much of it shows through panels.
- Store the image locally on the device. Nothing is uploaded and no server or contract change is needed.
- With no image set, the app looks exactly as it does upstream.

## Capabilities

### New Capabilities

- `app-background`: a user-chosen image displayed behind the application UI, with dimming, blur and fit controls, stored locally per device.

### Modified Capabilities

None.

## Impact

- New: background store, background layer component, Background settings section (all in new files under `apps/web/src`).
- Small hook points in `ThemeSettings.tsx` (render the section) and the app root/layout (mount the layer).
- No changes to `packages/contracts`, the server or the desktop shell.
- Risk: text readability over busy images; mitigated by dimming and blur defaults.
