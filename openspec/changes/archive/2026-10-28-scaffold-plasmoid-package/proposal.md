# Proposal

## Why

The repository has no widget source at all, so nothing can be run, tested, or iterated on yet. Before any timer functionality is written, the project needs a minimal Plasma 6 applet package that provably loads in the runtime on this machine (plasmashell 6.6.6), plus a repeatable dev loop to check it.

## What Changes

- Add `package/metadata.json` declaring the applet: `Id: com.github.kido5217.multitimer`, `KPackageStructure: Plasma/Applet`, `X-Plasma-API-Minimum-Version: 6.0`.
- Add `package/contents/ui/main.qml` with a `PlasmoidItem` root rendering a placeholder so the widget visibly boots.
- Document the development loop in `README.md`: `nix shell` invocations (plasma-sdk, qtdeclarative for qmllint), `plasmoidviewer -a package`, `kpackagetool6 --install/--remove`. No build system to install.
- Explicitly out of scope: `flake.nix` and any C++/CMake spine. A pure-QML widget needs no build step, and the NixOS system registry already pins `nixpkgs#` to the exact source the running Plasma was built from, so an extra pin cannot improve runtime matching. Re-evaluate if a C++ extension, CI, or nix-packaging appears.
- Explicitly out of scope: timer functionality and a configuration UI (`contents/config/`). Those belong to the feature change that follows.

## Capabilities

### New Capabilities

- `plasmoid-package`: the applet package's structure, metadata, and its load/install behavior in Plasma 6 — what must hold for the widget to be a valid, loadable plasmoid.

### Modified Capabilities

(none — no specs exist yet)

## Impact

- New files: `package/` tree. Modified: `README.md` (dev-loop section). No existing code, no dependencies installed system-wide; tooling is fetched ad-hoc via nix.
- Workflow impact: the AGENTS.md PR cycle now carries a concrete check — the "builds" gate defined in `specs/plasmoid-package`.
