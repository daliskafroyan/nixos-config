# Design

## Context

See `proposal.md` for motivation. The host currently enables NetworkManager, Tailscale, Syncthing with `openDefaultPorts = true`, zram, and a user-managed Noctalia service. It does not declare a firewall, suspend/lock policy, disk-backed swap, automatic Nix garbage collection, or a documented rollback procedure. `systemd-oomd` is enabled by the NixOS default but user-slice monitoring is not enabled; the observed incident reached the kernel OOM killer and killed Zed while Noctalia's service peaked at 25.9 GiB with 14.4 GiB of swap use.

## Goals / Non-Goals

**Goals:**

- Make the host's inbound networking, suspension, memory-pressure response, privileged groups, and recovery process explicit and reviewable.
- Provide one early intervention path for user-session memory pressure and preserve a minimal graphical-session critical path where technically supported.
- Ensure each policy has practical verification commands and a safe rollback path.

**Non-Goals:**

- Guarantee that an application can never be terminated under extreme memory exhaustion.
- Add disk-backed hibernation, migrate to full-disk encryption, or tune AMD GPU kernel flags.
- Migrate Docker to rootless operation, alter VPN protocol compatibility, reorganize packages, or add CI.

## Decisions

### Explicit default-deny firewall with deliberate Syncthing transport scope

Enable `networking.firewall` explicitly. Keep Syncthing's GUI loopback-bound and replace broad automatic port exposure with an allowlist whose interfaces and ports are selected only after documenting the required synchronization paths. Tailscale remains available for private administration, but it is not treated as a blanket exemption for every inbound service.

**Alternatives considered:** Retaining the implicit/default firewall state leaves exposure unreviewable. Keeping `openDefaultPorts = true` permits Syncthing transport more broadly than the proposed boundary. Allowing Syncthing only on Tailscale before checking existing LAN peers risks breaking synchronization.

### One early OOM responder: earlyoom

Use `services.earlyoom` as the sole configured early OOM responder and explicitly disable `systemd.oomd` to avoid competing policies. Configure thresholds only after validating available RAM, zram behavior, and a controlled workload test. Use earlyoom's supported process-selection policy to avoid the Niri compositor; do not avoid Noctalia wholesale because its process tree can include high-memory application workloads.

**Alternatives considered:** Niri resets its own kernel OOM score after startup, so a systemd `OOMScoreAdjust` drop-in cannot provide durable compositor protection without privileged process mutation. Enabling both responders creates unclear selection and diagnosis. Relying on kernel OOM alone repeats the observed late intervention. Enabling `systemd-oomd` user-slice killing without first separating desktop workloads risks selecting a broad session cgroup.

### Session-bound Wayland lock before sleep

Run a single Wayland-compatible locker through the graphical session's idle/sleep integration so its pre-sleep hook covers manual and automatic suspend. Declare logind lid behavior for mobile and docked use; document suspend-only operation because `swapDevices` is empty. The implementation must not introduce a second competing lock service.

**Alternatives considered:** A desktop-agnostic system sleep hook cannot reliably lock the active Wayland session. Relying on manual locking does not protect automatic or lid-triggered suspension. Hibernation is excluded until encrypted, resume-capable disk swap is designed separately.

### Conditional removal of the disk group

Inventory the primary user's actual `disk`-dependent workflows before altering group membership. Remove `disk` when no valid dependency remains; otherwise retain it with a concise documented justification. `wheel` and `docker` remain explicitly acknowledged but are outside this change's privilege-model redesign.

**Alternatives considered:** Removing `disk` unconditionally may break a required maintenance workflow. Keeping it without a reason leaves broad raw-device access unexplained.

### Recovery documentation with declared retention policy

Add a README recovery section covering generation inspection, immediate rollback, boot-menu rollback, and collection. Choose and declare a retention window before enabling scheduled cleanup, preserving enough generations to recover from a failed switch without unbounded store growth.

**Alternatives considered:** Ad hoc manual collection leaves rollback capacity unpredictable. Retaining every generation indefinitely consumes storage and makes recovery choices harder to audit.

## Risks / Trade-offs

- [Firewall scope breaks an existing peer] → Inventory Syncthing peers and test loopback, Tailscale, and required LAN paths before applying; retain a console rollback path.
- [Early OOM intervention terminates useful work] → Start with documented conservative thresholds, record earlyoom's compositor-avoid rule, and test with a disposable memory workload.
- [Locker integration fails before suspend] → Test manual suspend, lid close, docked lid close, and resume before relying on the policy.
- [Removing `disk` breaks tooling] → Validate each known raw-device workflow first and retain only with a recorded reason.
- [Automatic cleanup removes needed rollback points] → Set the retention window before enabling cleanup and document boot-menu recovery.

## Migration Plan

1. Capture the current active generation and verify a known-good boot entry.
2. Inventory required inbound services, Syncthing peer paths, and `disk`-dependent workflows.
3. Apply firewall, memory, and lock/suspend policies in a single reviewed NixOS switch.
4. Run the network, suspend/resume, memory-pressure, and privilege smoke tests from `tasks.md`.
5. If any regression occurs, immediately switch or boot into the recorded prior generation; only enable scheduled garbage collection after the new generation is accepted.
