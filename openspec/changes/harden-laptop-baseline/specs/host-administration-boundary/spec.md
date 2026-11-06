# Spec Delta

## Purpose

Defines reviewable local privilege boundaries and recovery procedures for safely operating and rolling back this NixOS host.

## ADDED Requirements

### Requirement: Privileged group review
The host SHALL document the purpose of each privileged local group assigned to the primary user. The `disk` group MUST be removed unless a validated operational requirement is recorded for retaining it.

#### Scenario: Reviewing disk-group membership
- **WHEN** an administrator reviews the primary user's `disk` membership
- **THEN** the configuration either records the required dependent workflow or removes the membership after validating that workflow

### Requirement: Rollback procedure
The host SHALL document how to identify a previous NixOS generation and roll back both immediately and at the next boot after an unsuccessful configuration switch.

#### Scenario: Recovering from a bad switch
- **WHEN** a configuration switch leaves the desktop or networking unusable
- **THEN** the administrator can follow the documented procedure to boot or switch to a known-good generation

### Requirement: Generation retention and garbage collection
The host SHALL declare or document its generation-retention and garbage-collection policy, including the operational trade-off between retained rollback points and disk usage.

#### Scenario: Maintaining rollback capacity
- **WHEN** an administrator performs generation cleanup
- **THEN** the documented policy preserves the intended rollback window before unreferenced store data is collected
