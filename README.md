# multitimer-plasmoid

KDE Plasma 6 panel widget: multiple countdown timers in one widget.

## Layout

Everything under `package/` is the applet itself — that directory (its contents) is what gets installed and shipped. Everything else in the repo is project scaffolding.

## Development

This is a pure-QML applet: **no build step**. Edit QML, run a gate, iterate. Tooling is fetched ad-hoc from the system-pinned nixpkgs, so it always matches the running Plasma exactly.

Gate 1 — lint (exit 0 is the bar; unresolved `org.kde.*` import *warnings* are expected and cannot be fixed without a QML catalog):

```sh
nix shell nixpkgs#kdePackages.qtdeclarative -c qmllint package/contents/ui/*.qml
```

Gate 2 — boot check, shows the widget in a window without installing it:

```sh
nix shell nixpkgs#kdePackages.plasma-sdk -c plasmoidviewer -a package
```

Gate 3 — live-shell round-trip (`--type` is mandatory on both halves; a bare `--remove` scans all package types over kded and hangs):

```sh
kpackagetool6 --install package --type Plasma/Applet
kpackagetool6 --remove com.github.kido5217.multitimer --type Plasma/Applet
```

### Why no flake.nix

The NixOS system registry pins `nixpkgs#` to the exact source the running Plasma was built from, so ad-hoc `nix shell` invocations are automatically version-matched to the runtime — a self-pinned flake could only drift from it. Re-evaluate if a C++ extension, CI on a non-NixOS runner, or nix-packaging of the widget appears.
