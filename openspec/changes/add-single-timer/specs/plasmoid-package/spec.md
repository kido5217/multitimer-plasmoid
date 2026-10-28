# Spec Delta

## MODIFIED Requirements

### Requirement: Widget boots with a visible placeholder
The applet's `contents/ui/main.qml` SHALL use a `PlasmoidItem` root and render the timer face (`05:00` in READY) as visible boot content, so a human can confirm the load without any feature logic.

#### Scenario: Placeholder renders in plasmoidviewer
- **WHEN** a developer runs plasmoidviewer against the package directory
- **THEN** a window opens showing the timer face `05:00` and the process stays alive without QML errors
