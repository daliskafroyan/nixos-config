# Graphical Appearance Operations

This document records the graphical appearance policy and its verification steps.

## Baseline before the unified theme policy

Before this change, the active NixOS generation was **201**. Its immediate rollback candidate is generation **200**.

The baseline appearance was:

| Area | Baseline setting |
| --- | --- |
| Noctalia | `dark` mode |
| Desktop preference | `prefer-dark` via the Noctalia theme hook |
| GTK 3 and GTK 4 | `Gruvbox-Dark`, `oomox-gruvbox-dark`, and dark-app preference forced by `/etc/gtk-*/settings.ini` |
| Session environment | `GTK_THEME=Gruvbox-Dark` |
| Zed theme | Explicit `dark` mode using `Gruvbox Dark Soft` |
| Zed icon theme | Explicit `dark` mode using `Zed (Default)` |

Inspect the rollback baseline:

```bash
nixos-rebuild list-generations
```

To return immediately to the previous generation after a visual regression:

```bash
sudo nixos-rebuild switch --rollback
```

If a graphical session is unusable, reboot and select a known-good NixOS generation from the systemd-boot menu.
