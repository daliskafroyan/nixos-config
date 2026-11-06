# Design

## Context

See `proposal.md` for motivation. Noctalia already toggles its own mode and invokes `sync-system-theme.sh`, which writes the GNOME desktop `color-scheme` preference. That preference is currently undermined by a global `GTK_THEME=Gruvbox-Dark` session variable, fixed dark GTK 3/4 settings, and Zed's explicit dark mode. The existing Zed settings file is user-owned and contains unrelated custom settings, so replacing it from Home Manager would be destructive.

## Goals / Non-Goals

**Goals:**

- Make one Noctalia action consistently select the graphical light or dark mode.
- Use a paired Gruvbox appearance for GTK and Zed.
- Preserve user-owned Zed settings while changing only its appearance fields.
- Make behavior inspectable and recovery from a mismatch straightforward.

**Non-Goals:**

- Automatically switch terminal, Neovim, Helix, or other CLI applications during a graphical mode change.
- Replace Noctalia's theme engine, add a desktop environment, or enforce appearance on applications that intentionally override system preference.
- Change wallpaper selection or the current Niri layout.

## Decisions

### Noctalia remains the appearance authority

Continue using Noctalia's existing theme-mode hook as the sole event source. Extend its synchronization script so one mode selection updates the desktop preference, paired GTK theme, and mode-appropriate icon preference together.

**Alternatives considered:** A separate timer or system service would introduce a second authority and race with Noctalia. Relying only on GNOME `color-scheme` leaves explicit GTK theme selection unresolved for applications using traditional GTK theming.

### Use paired Gruvbox GTK themes with mode-appropriate icons

Use verified Gruvbox Dark and Gruvbox Light GTK names, selected by the Noctalia hook. The available Gruvbox icon packages are dark-only, so retain the verified Gruvbox dark icon theme in dark mode and use a verified neutral system icon theme in light mode. Remove the static dark `GTK_THEME` session variable and fixed system GTK settings because they override user-level light mode.

**Alternatives considered:** Adding an unreviewed third-party Gruvbox light icon source adds maintenance and supply-chain scope. Leaving GTK at its toolkit default in light mode is less coherent with the existing Gruvbox desktop. A globally exported dynamic `GTK_THEME` cannot react safely within already-running processes and remains unnecessarily forceful.

### Configure Zed for system mode without replacing its full settings file

Set Zed's theme and icon-theme modes to `system` with verified paired Gruvbox names. Manage only those JSON fields through a narrowly scoped update mechanism that parses and preserves all unrelated keys in the existing user settings file. Back up or atomically replace the file only after validating the resulting JSON.

**Alternatives considered:** Continuing to copy a Home Manager template risks deleting user-owned settings. Leaving Zed in explicit dark mode does not meet the policy. A one-time manual edit is not durable across future managed updates.

### Graphical-first scope

Limit automatic synchronization to Noctalia, GTK, and Zed. Document terminal/editor themes as intentionally static and provide no claim that they follow system appearance.

**Alternatives considered:** Synchronizing Ghostty, Helix, and Neovim would require application-specific reload mechanisms and can disrupt active development sessions. It can be designed as a separate opt-in change later.

## Risks / Trade-offs

- [A selected GTK, icon, or Zed theme identifier differs from expectations] → Inspect installed theme names before selecting them; use the reviewed neutral icon fallback only for light mode and do not silently substitute an unrelated GTK or Zed theme.
- [Running GTK or Zed processes do not redraw immediately] → Document restart/reload expectations and test newly launched windows in each mode.
- [Updating Zed JSON damages user settings] → Use an atomic, schema-aware update that changes only appearance keys and validates JSON before replacing the file.
- [An application deliberately ignores desktop preference] → Treat its explicit override as supported; document that the policy governs default appearance, not forced compliance.

## Migration Plan

1. Record the current dark appearance settings and ensure a previous NixOS generation remains available.
2. Verify installed Gruvbox Dark/Light GTK, Gruvbox dark icon, neutral light icon, and Zed theme identifiers.
3. Extend the Noctalia hook, remove static GTK-dark overrides, and add the non-destructive Zed appearance update.
4. Build and switch through the repository workflow.
5. Test dark-to-light and light-to-dark transitions with newly started GTK applications and Zed; inspect the desktop preference and preserve rollback instructions.
6. If visual regressions occur, roll back to the prior generation, which restores the current fixed-dark policy.
