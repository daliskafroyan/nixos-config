
# Laptop Operations Baseline

This document records the operational boundary for the `nixos` laptop and the checks to run after changing it.

## Recovery baseline

Before this hardening change, the active known-good NixOS generation was **195**. Generation **194** is the immediate previous rollback candidate.

Inspect installed generations:

```bash
nixos-rebuild list-generations
```

`systemd-boot` presents the installed NixOS generations at boot. Keep a known-good generation available before switching a configuration that changes networking, login, or the graphical session.

## Network boundary

The firewall is explicitly enabled. Syncthing administration stays local at:

```text
http://127.0.0.1:8384
```

Syncthing device transport is allowed only on the `tailscale0` interface:

| Traffic | Scope | Reason |
| --- | --- | --- |
| Syncthing `22000/tcp` | Tailnet only | Direct authenticated device transport |
| Syncthing `22000/udp` | Tailnet only | QUIC device transport |
| Syncthing GUI `8384/tcp` | Loopback only | Local administration |
| Syncthing local discovery `21027/udp` | Not exposed | Tailnet peers do not need LAN discovery |

All Syncthing peers that require direct connectivity must join the same Tailnet. A peer outside the Tailnet can still use Syncthing's outbound relay fallback when configured, but it cannot initiate direct transport to this host.

Inspect listeners and firewall state after a switch:

```bash
ss -tulpn
sudo nft list ruleset
systemctl status syncthing --no-pager
```

## Memory-pressure policy

This host runs **earlyoom** as its only early memory-pressure responder. `systemd-oomd` is explicitly disabled. Earlyoom begins intervention only when both available memory is below 8% and free zram swap is below 15%; it then targets the largest eligible workload. Earlyoom's candidate policy excludes the Niri compositor with `--avoid '^niri$'`. Noctalia is intentionally not protected as a whole because it owns child application processes and development workloads.

Inspect memory state and incident evidence:

```bash
free -h
zramctl
swapon --show
systemctl status earlyoom --no-pager
journalctl -u earlyoom -b --no-pager
systemctl --user show niri.service --property=MemoryCurrent --property=MemoryPeak
systemctl --user show noctalia.service --property=MemoryCurrent --property=MemoryPeak
journalctl -k -b --grep='[Oo]ut of memory|[Kk]illed process' --no-pager
```

Do not run an unbounded memory-allocation test on this working session. Use a disposable workload and stop it immediately after earlyoom logs an intervention.

## Lock, lid, and suspend behavior

Noctalia remains the only session locker. `systemd-lock-handler` starts the Noctalia lock command for user-session lock and sleep events. Closing the lid suspends an undocked laptop; closing it while docked is ignored so an external display session can remain active.

This host is **suspend-only**: it has zram swap but no disk-backed swap device, so hibernation is not configured or supported.

After a switch, test this manually:

1. Use the existing `Super+Alt+L` binding and confirm Noctalia locks.
2. Run `systemctl suspend`; confirm the lock screen appears before sleep and unlock after resume.
3. Close and reopen the lid while undocked; confirm suspend and resume work.
4. With an external display attached, close the lid; confirm the external session remains active.

Inspect the integration:

```bash
systemctl --user status systemd-lock-handler --no-pager
systemctl --user status noctalia-lock --no-pager
systemd-analyze cat-config systemd/logind.conf
```

## Local privilege boundary

The `yoran` account retains these intentionally privileged groups:

| Group | Purpose |
| --- | --- |
| `wheel` | Administrative commands through `sudo` |
| `docker` | Local Docker daemon access; effectively administrative |
| `networkmanager` | Manage network connections through NetworkManager |

The `disk` group was removed. GNOME Disks and removable-media operations continue to use UDisks and Polkit rather than raw block-device access. For raw-device recovery, partitioning, or imaging, use an explicit privileged command instead of permanent `disk` membership.

Verify the active membership after logging in again:

```bash
id yoran
```

## Rollback, retention, and garbage collection

Automatic Nix garbage collection runs weekly with up to a 45-minute randomized delay and removes generations older than 30 days. This retains roughly one month of rollback points while limiting store growth. Generation cleanup is irreversible after the Nix store garbage collector removes unreferenced paths.

Before a risky switch:

```bash
nixos-rebuild list-generations
```

To roll back the currently running system immediately:

```bash
sudo nixos-rebuild switch --rollback
```

If the system cannot reach a usable session, reboot and select a known-good **NixOS generation** from the systemd-boot menu. Once booted, inspect the failed configuration and rebuild only after correcting it.

To inspect the scheduled cleanup policy:

```bash
systemctl list-timers nix-gc.timer
systemctl cat nix-gc.service
```

For a one-off cleanup, first review generations, then use the same retention window:

```bash
nixos-rebuild list-generations
sudo nix-collect-garbage --delete-older-than 30d
```
