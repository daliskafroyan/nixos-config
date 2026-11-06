# Proposal

## Why

An observed out-of-memory event killed Zed and caused Noctalia to restart, cascading into desktop application failures. The laptop's inbound network exposure, suspend safety, privileged local access, and rollback lifecycle are also currently implicit rather than declared and reviewable.

## What Changes

- Declare an explicit host firewall policy and deliberately scope Syncthing transport exposure while retaining its loopback-only GUI.
- Define lock-before-suspend and lid-close behavior, and document that this host is suspend-only because no hibernation swap device is configured.
- Establish one inspectable memory-pressure policy that avoids competing OOM responders and prioritizes graphical-session resilience where supported.
- Review the operational need for the `disk` group; retain it only with a documented requirement.
- Document rollback, generation retention, and garbage-collection operations for safe recovery after NixOS changes.
- **BREAKING**: Enabling an explicit firewall may block inbound traffic that was previously reachable; permitted services will be deliberately selected and documented.
- **BREAKING**: Lid-close and suspend behavior may change to ensure the session is locked before suspension.

## Capabilities

### New Capabilities

- `laptop-memory-resilience`: Defines memory-pressure response and graphical-session workload safeguards.
- `laptop-suspend-safety`: Defines lock-before-suspend, lid-close, resume, and suspend-only behavior.
- `host-network-boundary`: Defines explicit firewall behavior and Syncthing network exposure.
- `host-administration-boundary`: Defines privileged local group review and documented rollback and generation-retention behavior.

### Modified Capabilities

- None.

## Impact

Affected areas include `modules/system.nix`, the user graphical-session configuration, and `README.md`. The change affects host networking, power/session behavior, memory-pressure handling, local privilege boundaries, and NixOS recovery operations. It does not require application API changes or new external services.
