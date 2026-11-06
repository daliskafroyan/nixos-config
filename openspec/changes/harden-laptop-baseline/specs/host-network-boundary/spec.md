# Spec Delta

## Purpose

Defines an explicit inbound network boundary for the laptop while preserving required Syncthing access and local administration.

## ADDED Requirements

### Requirement: Explicit host firewall policy
The host SHALL explicitly enable and declare its firewall policy. Inbound traffic MUST be denied unless it is permitted by a documented service or trusted-interface rule.

#### Scenario: Unsolicited inbound connection
- **WHEN** an external peer attempts to reach a port not declared by the firewall policy
- **THEN** the host does not accept the connection

### Requirement: Loopback-only Syncthing administration
The Syncthing GUI SHALL remain bound to loopback and MUST NOT be exposed through a general firewall allowance.

#### Scenario: Local Syncthing GUI access
- **WHEN** the local user connects to the configured loopback GUI address
- **THEN** the Syncthing GUI remains reachable

#### Scenario: Remote Syncthing GUI access
- **WHEN** a remote peer attempts to reach the Syncthing GUI directly
- **THEN** the host does not expose the GUI as an inbound network service

### Requirement: Scoped Syncthing transport exposure
The host SHALL explicitly document and configure the interfaces or ports through which Syncthing device transport is permitted. The selected scope MUST be validated against the user's required synchronization peers.

#### Scenario: Required synchronization peer
- **WHEN** a configured peer connects through an allowed Syncthing transport path
- **THEN** synchronization transport remains reachable

#### Scenario: Non-allowed network path
- **WHEN** a peer attempts Syncthing transport through an interface or path outside the declared scope
- **THEN** the firewall policy does not permit that path
