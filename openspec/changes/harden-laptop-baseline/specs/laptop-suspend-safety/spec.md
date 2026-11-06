# Spec Delta

## Purpose

Defines safe, explicit laptop suspension behavior so unattended sessions are locked before sleep and resume behavior is predictable.

## ADDED Requirements

### Requirement: Lock before suspend
The graphical session SHALL request a lock before manual or automatic system suspension. Suspension MUST proceed only after the configured lock handoff has been initiated.

#### Scenario: Manual suspend from an unlocked session
- **WHEN** the user requests system suspend while the graphical session is unlocked
- **THEN** the configured lock mechanism is invoked before the system enters suspend

### Requirement: Declared lid-close behavior
The host SHALL declare lid-close behavior for normal mobile use and document the expected behavior when an external display or dock is connected.

#### Scenario: Closing the lid during mobile use
- **WHEN** the user closes the lid without an external display
- **THEN** the declared lid-close action runs and the session lock-before-suspend policy applies when that action suspends

#### Scenario: Closing the lid while docked
- **WHEN** the user closes the lid with an external display or dock connected
- **THEN** the documented docked behavior is applied consistently

### Requirement: Suspend-only recovery expectation
The host SHALL document that it supports suspend rather than hibernation until a hibernation-capable swap device is explicitly configured.

#### Scenario: Reviewing power recovery behavior
- **WHEN** an administrator follows the host recovery documentation
- **THEN** it states that a suspended session resumes from memory and does not claim hibernation support
