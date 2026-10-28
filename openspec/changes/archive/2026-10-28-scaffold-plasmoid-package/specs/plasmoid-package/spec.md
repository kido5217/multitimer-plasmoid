# Spec Delta

## Purpose

Defines the minimal contract that makes this repository a loadable Plasma 6 applet: valid package metadata, a widget that boots with a visible placeholder, and a clean install/uninstall round-trip against the live runtime.

## ADDED Requirements

### Requirement: Package metadata identifies a Plasma 6 applet
The package's `metadata.json` SHALL declare `Id` `com.github.kido5217.multitimer`, `KPackageStructure` `Plasma/Applet`, `X-Plasma-API-Minimum-Version` `6.0`, and human-readable `Name`, `Description`, and `Version` keys, so Plasma 6 recognizes and offers the widget.

#### Scenario: Runtime accepts the package
- **WHEN** the package is loaded by Plasma 6 tooling (plasmoidviewer or kpackagetool6)
- **THEN** the applet resolves under id `com.github.kido5217.multitimer` with no KPluginLoadingError or package-structure error in the user journal or on stderr

### Requirement: Widget boots with a visible placeholder
The applet's `contents/ui/main.qml` SHALL use a `PlasmoidItem` root and render the widget name as visible placeholder content, so a human can confirm the load without any feature logic.

#### Scenario: Placeholder renders in plasmoidviewer
- **WHEN** a developer runs plasmoidviewer against the package directory
- **THEN** a window opens showing the placeholder text and the process stays alive without QML errors

### Requirement: Install and removal round-trip cleanly
The package SHALL install into the user's Plasma applet location via `kpackagetool6` and SHALL be removable without leftover files, so the live-shell smoke test is repeatable.

#### Scenario: Install then remove
- **WHEN** the developer installs the package with `kpackagetool6 --install package --type Plasma/Applet`
- **THEN** `~/.local/share/plasma/plasmoids/com.github.kido5217.multitimer/` exists with the package contents
- **WHEN** the developer removes it with `kpackagetool6 --remove com.github.kido5217.multitimer --type Plasma/Applet`
- **THEN** that directory no longer exists
