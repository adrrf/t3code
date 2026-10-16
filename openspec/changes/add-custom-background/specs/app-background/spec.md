# Spec Delta

## Purpose

Lets the user place their own image behind the T3 Code interface, tuned so that text and panels stay readable, and stored only on the user's device.

## ADDED Requirements

### Requirement: Choose a background image

The system SHALL let the user choose a PNG, JPEG, WebP or GIF image from Appearance settings and SHALL display it behind the application UI immediately, without a restart.

#### Scenario: User sets an image

- **WHEN** the user opens Settings → Appearance → Background and picks a valid image file
- **THEN** the image appears behind the whole application within one second
- **AND** a thumbnail of the image is shown in the Background section

#### Scenario: Unsupported file

- **WHEN** the user picks a file that is not a supported image type
- **THEN** the system shows an error message and leaves the current background unchanged

#### Scenario: Oversized file

- **WHEN** the user picks an image larger than 20 MB
- **THEN** the system rejects it with a message stating the size limit and leaves the current background unchanged

### Requirement: Remove the background image

The system SHALL let the user remove the background image, after which the application SHALL look identical to having no image set.

#### Scenario: User removes the image

- **WHEN** a background image is set and the user clicks Remove
- **THEN** the image disappears and the stored image is deleted from the device

#### Scenario: No image set

- **WHEN** no background image has ever been set
- **THEN** the application renders exactly as it does without this feature

### Requirement: Adjust dimming and blur

The system SHALL provide a dimming control from 0% to 90% and a blur control from 0 px to 40 px, both applied to the background image in real time.

#### Scenario: User adjusts dimming

- **WHEN** the user moves the dimming slider
- **THEN** the image darkens (dark themes) or lightens (light themes) towards the theme background colour by the chosen percentage while the slider moves

#### Scenario: Readable defaults

- **WHEN** the user sets an image for the first time
- **THEN** dimming starts at 60% and blur at 8 px

### Requirement: Choose image fit

The system SHALL let the user choose how the image fills the window: cover, contain or tile.

#### Scenario: Tile fit

- **WHEN** the user selects Tile
- **THEN** the image repeats at its natural size across the window

#### Scenario: Window resize

- **WHEN** the window is resized with Cover selected
- **THEN** the image still fills the whole window without distortion

### Requirement: Background shows through glass surfaces

The system SHALL draw the background beneath all application surfaces, so the existing Glass opacity setting controls how visible the image is through panels.

#### Scenario: Glass opacity below 100%

- **WHEN** a background image is set and Glass opacity is below 100%
- **THEN** the image is visible through the sidebar, chat and right panel surfaces

#### Scenario: Glass opacity at 100%

- **WHEN** Glass opacity is 100%
- **THEN** panels are opaque and the image is visible only where no surface covers it

### Requirement: Background persists locally

The system SHALL keep the background image and its settings on the current device across restarts, and SHALL NOT send the image to any server.

#### Scenario: Restart

- **WHEN** the user restarts the app after setting an image
- **THEN** the same image, dimming, blur and fit are restored

#### Scenario: Storage unavailable

- **WHEN** device storage cannot be read
- **THEN** the application renders without a background image and does not show an error on every launch
