# Proposal

## Why

The current light/dark toggle updates Noctalia and the desktop preference, but GTK applications and Zed are independently forced to dark themes. This produces an inconsistent desktop and makes the advertised system appearance setting unreliable.

## What Changes

- Establish Noctalia's light/dark toggle as the single source of truth for graphical system appearance.
- Apply paired Gruvbox dark and light GTK themes rather than forcing GTK applications to dark mode through static system settings; use Gruvbox dark icons in dark mode and a verified neutral system icon theme in light mode.
- Configure Zed to follow the system appearance with paired Gruvbox themes, while preserving unrelated user-owned Zed settings.
- Define how running applications adopt a theme change and document applications that require a restart.
- **BREAKING**: GTK applications that were always forced to Gruvbox Dark will adopt Gruvbox Light when the system appearance is set to light.

## Capabilities

### New Capabilities

- `system-appearance-policy`: Defines a single, observable graphical light/dark appearance policy across Noctalia, GTK applications, and Zed.

### Modified Capabilities

- None.

## Impact

Affected areas include the Noctalia theme-change hook, GTK session and configuration settings, Zed theme settings management, and operational documentation. This change does not alter terminal/editor themes, window-manager behavior, or the user's ability to choose an application-specific override.