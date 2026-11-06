# Tasks

## 1. Baseline inventory and recovery preparation

- [x] 1.1 Record the current NixOS generation and a known-good boot entry before changes; verify with `nixos-rebuild list-generations` and the boot menu.
- [x] 1.2 Inventory active listeners, Syncthing peer paths, and required LAN/Tailscale access; verify findings with `ss -tulpn`, Syncthing device status, and a documented peer-access table.
- [x] 1.3 Identify every current workflow that needs the primary user's `disk` group; verify each workflow either succeeds without the group in a test context or has a recorded retention justification.

## 2. Network boundary

- [x] 2.1 Declare an explicit NixOS firewall policy and replace Syncthing's broad automatic port exposure with the inventory-approved interface/port allowlist; verify `nixos-rebuild build --flake .#nixos` evaluates successfully.
- [x] 2.2 Verify the network policy after switching: confirm the Syncthing GUI is reachable at `127.0.0.1:8384`, required synchronization peers connect, and an undeclared inbound port is rejected from a separate host or network namespace.
- [x] 2.3 Document the allowed inbound services, interfaces, ports, and any Tailscale assumptions in the host documentation; verify the commands and endpoints in the documentation match the deployed configuration.

## 3. Memory-pressure resilience

- [x] 3.1 Configure `services.earlyoom` as the sole early memory-pressure responder and explicitly disable `systemd.oomd`; verify the evaluated configuration enables only the selected responder.
- [x] 3.2 Set conservative earlyoom thresholds after checking physical RAM and zram capacity, and configure earlyoom to avoid the Niri compositor; verify the active earlyoom arguments and that Niri is excluded from its candidate policy.
- [ ] 3.3 Exercise the policy with a disposable, bounded memory-pressure workload; verify earlyoom records the intervention and the Niri compositor remains excluded from selection without claiming that normal applications cannot be terminated.
- [x] 3.4 Document incident-inspection commands for memory, swap, earlyoom journal events, and systemd unit memory peaks; verify each command runs on the host and returns the intended category of information.

## 4. Lock and suspend safety

- [x] 4.1 Add one Wayland-compatible graphical-session locker and pre-sleep integration, without creating a competing lock service; verify manual suspend invokes the locker before the machine sleeps.
- [x] 4.2 Declare normal and docked lid-close behavior through the applicable logind/session configuration; verify lid-close behavior and resume with and without an external display.
- [x] 4.3 Document suspend-only behavior and the absence of hibernation-capable swap; verify the documentation does not advertise hibernation and that the tested suspend/resume workflow works as described.

## 5. Privilege boundary and NixOS recovery lifecycle

- [x] 5.1 Remove the primary user's `disk` group when the inventory finds no requirement, or record the validated requirement if it must remain; verify the affected maintenance workflows and `id yoran` after a rebuild.
- [x] 5.2 Add a declared generation-retention and garbage-collection policy that preserves the approved rollback window; verify the configuration evaluates and its schedule/retention behavior is inspectable.
- [x] 5.3 Add README instructions for generation inspection, immediate rollback, boot-menu rollback, and safe garbage collection; verify every documented command against the local host or NixOS manual syntax.

## 6. Integrated acceptance

- [x] 6.1 Build and switch the host configuration using the repository workflow; verify `nixos-rebuild build --flake .#nixos` succeeds before `./scripts/switch` and record the resulting generation.
- [x] 6.2 Run the complete post-switch smoke test: firewall reachability, Syncthing loopback/peer sync, earlyoom status, lock-before-suspend, lid-close/resume, group membership, and rollback visibility; verify each outcome against the four capability specs.
