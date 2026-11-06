# Spec Delta

## Purpose

Defines one reliable graphical appearance policy so the user's selected light or dark mode is reflected consistently across the desktop, GTK applications, and Zed.

## ADDED Requirements

### Requirement: Single graphical appearance authority
The system SHALL use the Noctalia light/dark mode as the authoritative graphical appearance preference. A mode change MUST update the desktop appearance preference used by system-aware graphical applications.

#### Scenario: Selecting light appearance
- **WHEN** the user changes Noctalia to light mode
- **THEN** the desktop appearance preference reports a light preference

#### Scenario: Selecting dark appearance
- **WHEN** the user changes Noctalia to dark mode
- **THEN** the desktop appearance preference reports a dark preference

### Requirement: Paired GTK appearance
The system SHALL apply Gruvbox Light or Gruvbox Dark GTK preferences for the selected appearance mode. It MUST use Gruvbox dark icons in dark mode and a verified neutral system icon theme in light mode, and MUST NOT impose a permanently dark GTK theme that overrides the selected light mode.

#### Scenario: GTK application launched in light mode
- **WHEN** the selected system appearance is light and the user launches a GTK application
- **THEN** the application uses Gruvbox Light GTK and the configured neutral system icon theme

#### Scenario: GTK application launched in dark mode
- **WHEN** the selected system appearance is dark and the user launches a GTK application
- **THEN** the application uses Gruvbox Dark GTK and the configured Gruvbox dark icon theme

### Requirement: Zed system appearance integration
Zed SHALL follow the system appearance preference using paired Gruvbox light and dark themes. Applying this policy MUST preserve unrelated user-owned Zed settings.

#### Scenario: Zed follows light mode
- **WHEN** the system appearance is light and Zed starts or reloads its appearance settings
- **THEN** Zed uses the configured Gruvbox light theme

#### Scenario: Preserving existing Zed settings
- **WHEN** the system theme policy updates Zed appearance configuration
- **THEN** unrelated Zed editor, agent, and user settings remain unchanged

### Requirement: Appearance-change observability
The system SHALL document how to inspect the active desktop preference and verify GTK and Zed appearance behavior. The documentation MUST identify applications that require restart or reload after a mode change.

#### Scenario: Diagnosing an appearance mismatch
- **WHEN** the user reports that an application does not match the selected mode
- **THEN** the documented checks identify the active preference and the application's expected reload behavior
