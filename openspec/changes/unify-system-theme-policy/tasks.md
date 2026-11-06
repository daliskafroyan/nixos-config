# Tasks

## 1. Appearance inventory and safe defaults

- [x] 1.1 Inventory the installed Gruvbox Dark/Light GTK, Gruvbox dark icon, neutral light icon, and Zed theme identifiers; verify each selected identifier is available before adding it to configuration.
- [x] 1.2 Record the current Noctalia, GTK, and live Zed appearance settings and the current NixOS generation; verify the recorded state provides a rollback baseline.

## 2. System and GTK appearance synchronization

- [ ] 2.1 Extend the Noctalia theme-change hook to set the user desktop preference, paired Gruvbox GTK theme, Gruvbox dark icon in dark mode, and neutral icon in light mode; verify the hook reports the expected values after selecting light and dark mode.
- [ ] 2.2 Remove static system-wide dark GTK overrides that prevent a selected light mode, while retaining the required GTK theme packages; verify a newly launched GTK application uses the selected Gruvbox mode.
- [ ] 2.3 Document the graphical appearance authority, GTK reload expectations, inspection commands, and rollback procedure; verify each documented command works on the host.

## 3. Zed appearance synchronization

- [ ] 3.1 Configure paired verified Gruvbox themes and system appearance mode for Zed without replacing unrelated user-owned settings; verify the resulting settings are valid JSON and retain existing non-appearance keys.
- [ ] 3.2 Verify Zed adopts the selected system mode after its supported reload or restart path, including both light and dark mode; record any required restart behavior in the operations documentation.

## 4. Deployment and integration verification

- [ ] 4.1 Build and switch the host configuration using the repository workflow; verify `nixos-rebuild build --flake .#nixos` succeeds before `./scripts/switch` and record the resulting generation.
- [ ] 4.2 Run the end-to-end appearance check: toggle Noctalia dark-to-light and light-to-dark, inspect the desktop preference, start a GTK application, and verify Zed's paired Gruvbox mode; confirm terminal/editor themes remain intentionally unchanged.
