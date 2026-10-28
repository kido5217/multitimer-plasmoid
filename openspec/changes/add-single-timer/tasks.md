# Tasks

## 1. Probes (before touching the repo)

- [ ] 1.1 Middle-click reachability in plasmoidviewer: copy `package/` to a scratch dir under /home/kido/trash/temp/opencode (distinct `Id` like `dev.scratch.multitimerprobe`), add a `console.log` marker + `acceptedButtons: Qt.MiddleButton` MouseArea there; run `QT_QPA_PLATFORM=xcb nix shell nixpkgs#kdePackages.plasma-sdk -c plasmoidviewer -a <scratch-package> &`; then click the WIDGET: `ID=$(xdotool search --class plasmoidviewer | tail -1); xdotool windowactivate --sync $ID; xdotool mousemove --window $ID <x> <y>; xdotool click --window $ID 2` with coordinates read off a `magick import -window $ID` screenshot, plus a confirming screenshot of pointer-on-widget; check the user journal for the marker. PASS = marker present. FAIL (or marker absent despite proven pointer position) = STOP and renegotiate the input mapping before any further work.
- [ ] 1.2 Middle-click reachability in the REAL panel: Gate 3-install the same scratch package (`kpackagetool6 --install <dir> --type Plasma/Applet`), human adds it to the panel and middle-clicks once, journal shows the marker; then remove. This retires the change's top risk BEFORE task 2 exists.
- [ ] 1.3 Notification transport probe (scratch package): candidate (a) `org.kde.notification` `Notification` with a bundled `knotifications6/com.github.kido5217.multitimer.notifyrc` containing `[Global]` and `[Event/timerFinished] Action=Popup`, triggered by the probe click — PASS = popup visibly appears (screenshot or human confirm); note in System Settings→Notifications whether the event is configurable. If (a) shows nothing, candidate (b) same type with `componentName: "plasma_workspace"`. If still nothing, candidate (c) confirm the "notifications" data engine's write interface in Plasma Engine Explorer (`plasma-sdk`'s plasmaengineexplorer), then exercise it via `org.kde.plasma.plasma5support` `DataSource`. Record the winning path AND its settings-visibility status in design.md D3; if no candidate displays, STOP — no unprobed fallbacks.

## 2. Timer implementation

- [ ] 2.1 Rewrite `package/contents/ui/main.qml` per design D1/D2: state/property set, 1 s Timer with `Math.floor` whole-second formatting, `display` bound to state+remaining, compact face (Label + dual-button MouseArea: middle → state handler, left → `plasmoid.expanded = !plasmoid.expanded`), `preferredRepresentation: compactRepresentation`, fullRepresentation bound to the same `display`, blink animation with imperative opacity restore on state exit, tooltip property mirroring state. Verify Gate 1: `nix shell nixpkgs#kdePackages.qtdeclarative -c qmllint package/contents/ui/*.qml` exit 0; Gate 2: plasmoidviewer boots showing `05:00` (asserts the 300 s literal), journal silent for the package path.
- [ ] 2.2 Wire the probe-winning notification path (1.3) into the RUNNING→FINISHED transition, exactly once, body `Qt.formatTime(new Date(finishMs), "HH:mm")`. Verify on a scratch copy with a ~5 s duration: one popup, no repeats while blinking, tooltip shows the same HH:mm.

## 3. Interaction acceptance

- [ ] 3.1 Scripted state walk on the repo package via the D5 harness: middle-click → RUNNING (display changes between two grabs 3 s apart), middle-click → PAUSED (frozen across 3 s), middle-click → RUNNING, middle-click from FINISHED → READY `05:00` static across 3 s (blink stopped, no auto-start). Expiry itself is covered by 2.2/3.2 with shortened durations. Journal silent for the package path throughout. PASS/FAIL recorded per transition.
- [ ] 3.2 Real-panel walk on the shipped package (Gate 3 install, human): all four transitions with the physical middle button; left-click opens the popup mirror AND a second left-click closes it; hover tooltips checked in all four states; notification body shows the correct local HH:mm; suspend test — start the timer, suspend past expiry (use the scratch shortened copy), resume expecting immediate blinking FINISHED + one notification with the deadline's time, then reset; finish with Gate 3 remove. Record observations in this file — this task is the spec's only real-panel evidence.

## 4. Documentation

- [ ] 4.1 Add README "Interaction check" subsection per design D6 (corrected xdotool recipe + manual procedure incl. suspend check), run the documented recipe exactly as written once and confirm it behaves as described; the three scaffold gates must remain quoted verbatim and still pass.

## Workflow follow-up

- Land via the AGENTS.md cycle: branch → commit → push → PR → squash-merge → pull+rebase (direct pushes to main are now rejected by protection).
- Archive with `/opsx-archive` after merge: syncs `timer-core` (new) and the `plasmoid-package` MODIFIED requirement into main specs.
