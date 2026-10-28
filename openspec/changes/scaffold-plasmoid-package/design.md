# Design

## Context

See proposal.md for motivation. Constraints that shape the approach, all measured on this machine: runtime plasmashell 6.6.6; nixpkgs 26.05pre pinned by the **system registry**, so `nix shell nixpkgs#…` resolves to the same source that built the running Plasma; `kdePackages.plasma-sdk` 6.6.6 (plasmoidviewer), qtdeclarative 6.11.2 (qmllint), and `kdePackages.extra-cmake-modules` are all available from that pin. cmake and kpackagetool6 are already on PATH.

## Goals / Non-Goals

**Goals:**
- Every acceptance gate in `specs/plasmoid-package` is a named command a developer (or agent) can run, not a vibe check.
- Zero committed build tooling: the repo stays a package directory plus docs.

**Non-Goals:**
- CI, packaging derivation, translations, config UI — each deferred until it has a real driver.

## Decisions

### Layout: `package/` subdirectory, not repo root
The shipped applet archive is the contents of `package/`, so repo files (README, LICENSE, openspec/) must stay outside it. KDE's own tutorial and kdeplasma-addons use exactly this `repo/package/…` shape. Alternative considered: package at root with an install manifest — rejected as a premature build system.

### No flake.nix, no CMake
Pure-QML applets need no compilation; the registry pin already guarantees dev tooling matches the runtime, which is the only compatibility constraint that matters for a plasmoid. A self-pinned flake would drift from the system Plasma unless re-pinned on every rebuild — strictly worse. Revisit when a C++ extension, CI runner, or a nix installable appears.

### Gate 1 — lint: qmllint with a syntax-only bar
`nix shell nixpkgs#kdePackages.qtdeclarative -c qmllint package/contents/ui/*.qml`. Plasma's QML modules (`org.kde.plasma.*`) are not registered for qmllint's import scanner, so unresolved-import complaints are expected; the gate is **no syntax errors (exit 0)**. Documenting this prevents a future agent from "fixing" warnings that cannot go away.

### Gate 2 — boot: plasmoidviewer, screenshot-confirmed
`nix shell nixpkgs#kdePackages.plasma-sdk -c plasmoidviewer -a package` — run it, see the placeholder, quit. The agent-runnable form: launch under `timeout -s INT 12` (surviving to the kill proves liveness; exit 124 expected), capture the screen with `spectacle -b -n` and confirm the label visually. QML load errors land in the **user journal, not stderr** (wmctrl is blind on Wayland), so the check is `journalctl --user --since <start>` filtered to the package path — grep for the path/id alone, not error keywords (this runtime logs "Unable to assign", which no error-word grep matches). The reliable visual check forces X11 and grabs the window by id, immune to stacking: `QT_QPA_PLATFORM=xcb … plasmoidviewer -a package & …; ID=$(xdotool search --class plasmoidviewer | tail -1); magick import -window $ID shot.png` — desktop screenshots get occluded by whatever the user has focused. A harmless `org.kde.desktopcontainment` TypeError at startup is plasmoidviewer's own containment, not the applet.

Three API traps found while running this gate: the KF5 attached form `Plasmoid.preferredRepresentation` must become a direct `PlasmoidItem` property (the Setup tutorial snippet is stale); in this runtime the property takes a **Component**, not an enum — `preferredRepresentation: PlasmoidItem.FullRepresentation` logs `Unable to assign [undefined] to QQmlComponent*` on every load; the valid form is `preferredRepresentation: fullRepresentation`; and the KPlugin `Name` surfaces via `plasmoid.title` — `plasmoid.name` is empty. A sized `fullRepresentation` child with `Layout.preferred*` is required for content to render.

### Gate 3 — live shell: kpackagetool6 round-trip
Install with `kpackagetool6 --install package --type Plasma/Applet` (KF6 CLI grammar: `--install` takes the path as its value), assert `~/.local/share/plasma/plasmoids/com.github.kido5217.multitimer/` exists, then remove with `kpackagetool6 --remove com.github.kido5217.multitimer --type Plasma/Applet` — the explicit `--type` is required, since a bare `--remove` scans all package types over kded and never returns — and assert removal. Checking the on-disk directory is the observable; whether the running plasmashell's widget explorer needs a reload is out of scope for the scaffold.

## Risks / Trade-offs

- [System rebuild moves runtime and tooling together] → drift is shared, gates stay consistent; record Plasma version expectations in README rather than pinning.
- [qmllint exit-0 bar may hide real issues later] → acceptable now; revisit when the QML tree grows or a `.qmllint.ini` becomes useful.
- [plasmoidviewer requires a running graphical session] → this host is a Plasma desktop; only CI would need the offscreen gamble, and CI is out of scope.
- [`X-Plasma-API-Minimum-Version` mis-typed → Plasma 5 fallback] → kpackagetool6 only validates structure (install succeeds regardless), so detection belongs to Gate 2: plasmoidviewer load errors surface in the user journal.
