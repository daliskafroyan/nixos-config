# Spec Delta

## Purpose

Defines a single, observable memory-pressure policy that keeps the graphical session usable and makes its safeguards reviewable.

## ADDED Requirements

### Requirement: Single memory-pressure responder
The host SHALL configure exactly one memory-pressure responder and SHALL document how to inspect its active policy. It MUST NOT enable both `earlyoom` and `systemd-oomd` as independent responders.

#### Scenario: Inspecting the configured policy
- **WHEN** an administrator inspects the declared NixOS configuration and runtime service state
- **THEN** they can identify one active memory-pressure responder and its applicable thresholds or selection policy

### Requirement: Graphical-session resilience
The memory-pressure policy SHALL preferentially preserve the compositor and session-critical services where the selected responder supports prioritization. It MUST make non-critical, high-memory workloads eligible for intervention before protected session components when resource policy permits.

#### Scenario: Memory pressure from a user workload
- **WHEN** a non-critical user workload creates sustained memory pressure
- **THEN** the configured responder applies its policy without intentionally selecting the compositor or session-critical service as the first eligible target

### Requirement: Memory-pressure observability
The host SHALL document commands for reviewing memory pressure, swap use, responder events, and systemd unit memory peaks after an incident.

#### Scenario: Investigating an OOM event
- **WHEN** an administrator investigates a desktop instability event
- **THEN** the documented commands provide the responder status, relevant journal entries, and unit memory usage information
