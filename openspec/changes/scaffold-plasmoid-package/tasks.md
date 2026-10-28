# Tasks

## 1. Applet package

- [x] 1.1 Create `package/metadata.json` with `Id` `com.github.kido5217.multitimer`, `KPackageStructure` `Plasma/Applet`, `X-Plasma-API-Minimum-Version` `6.0`, plus `Name`/`Description`/`Version` (and `Authors`), per the KF6 metadata shape in the KDE Setup docs; verify with `python3 -m json.tool package/metadata.json` and confirm the three Plasma keys are present.
- [x] 1.2 Create `package/contents/ui/main.qml`: `PlasmoidItem` root importing `QtQuick`, `org.kde.plasma.plasmoid`, and `org.kde.plasma.components`, rendering a placeholder label with the widget name; verify Gate 1 — `nix shell nixpkgs#kdePackages.qtdeclarative -c qmllint package/contents/ui/*.qml` exits 0 (unresolved `org.kde.*` import warnings are acceptable per design.md).

## 2. Dev-loop documentation

- [x] 2.1 Add a `Development` section to `README.md` stating: no build step exists; the three gate commands verbatim from design.md (qmllint lint, `plasmoidviewer -a package` boot, `kpackagetool6` install/remove round-trip); the no-flake decision with its one-line rationale and re-evaluation triggers (C++, CI, packaging); verify by running the documented Gate 1 command exactly as written and confirming it behaves as the README claims.

## 3. Acceptance gates

- [x] 3.1 Run Gate 2: `nix shell nixpkgs#kdePackages.plasma-sdk -c plasmoidviewer -a package`; verify a window shows the placeholder and the user journal contains no QML errors for the package (spec: "Placeholder renders in plasmoidviewer").
- [x] 3.2 Run Gate 3: `kpackagetool6 --install package --type Plasma/Applet`, assert `~/.local/share/plasma/plasmoids/com.github.kido5217.multitimer/` contains the package, then `kpackagetool6 --remove com.github.kido5217.multitimer --type Plasma/Applet` and assert the directory is gone (spec: "Install then remove").

## Workflow follow-up

- Land via the AGENTS.md cycle: branch → commit → push → PR → squash-merge → pull+rebase.
- Archive the change (`/opsx-archive`) after the merge, syncing the `plasmoid-package` delta into main specs.
