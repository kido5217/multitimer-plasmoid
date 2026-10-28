# Design

## Context

Scaffold exists and passes its three gates (see plasmoid-package spec and archived change scaffold-plasmoid-package): pure-QML `package/`, plasmoidviewer + journal + `xdotool`/`magick import` harness proven, kpackagetool6 install round-trip proven. Runtime: plasmashell 6.6.6, nixpkgs system-registry-pinned. Decisions from exploration are final (see proposal.md); this file covers how, and the mechanics that must be probed rather than assumed.

## Goals / Non-Goals

**Goals:**
- One QML file holds the whole state machine; every spec requirement maps to a scripted or observable check.
- Notification goes through the desktop's own system so the user can mute or restyle it, to the extent event registration succeeds (see D3 caveat).

**Non-Goals:**
- Persistence, config keys, multiple timers, sound, i18n catalogs — i18n wraps strings but no translations ship. `metadata.json` Version stays `0.1.0` (no release process yet).

## Decisions

### D1: Representation flip with hand-rolled input
`compactRepresentation` = `Item` containing a `PlasmaComponents.Label` (text bound to a root `display` string property) + a full-cover `MouseArea` with `acceptedButtons: Qt.MiddleButton | Qt.LeftButton`. Overriding compact stops Plasma's automatic popup click, per the tutorial's own note ("you will need to use a MouseArea to toggle the `plasmoid.expanded` property"), so the handler mirrors the default: `onClicked: if (mouse.button === Qt.MiddleButton) root.middleClick(); else plasmoid.expanded = !plasmoid.expanded` — a toggle, so left-click still closes the popup. `preferredRepresentation: compactRepresentation` (Component form, per the trap recorded in the scaffold design). `fullRepresentation` binds to the same root properties — mirroring is free because both views read one `display`. Tooltip bound to a state-derived string.

Blink: `SequentialAnimation on opacity { loops: Animation.Infinite; running: root.state === "finished" }` toggling 1→0.2, full on/off cycle ~1 s. Animations destroy property bindings on the animated property, so leaving FINISHED restores opacity imperatively (`label.opacity = 1` in the state handler), not by binding.

### D2: Wall-clock state machine
`property string state` ∈ {ready, running, paused, finished}; properties `deadlineMs`, `remainingMs`, `finishMs`; `display` bound to a format function of `state`/`remainingMs` (property changes fire change signals; JS calls like `Date.now()` do NOT, so no `nowMs` binding — the clock is read imperatively inside the tick). A single `Timer { interval: 1000; repeat: true; running: state === "running" }` recomputes `remainingMs = Math.max(0, deadlineMs - Date.now())` and `display` follows; whole seconds are rounded down (`Math.floor(remainingMs / 1000)`). At zero it sets `finishMs = deadlineMs` and state to finished — deadline-based, so the notification's "finished at" time is exact even if the tick lands late. Transitions: start `deadlineMs = Date.now() + 300000`; pause stores `remainingMs`; resume `deadlineMs = Date.now() + remainingMs`; reset clears to ready. One handler, four `if`s — no framework. The `300000` literal is asserted by the READY `05:00` display checks; expiry arithmetic is duration-independent and exercised with shortened scratch copies.

### D3: Notification — probed, with ordered candidates, decided by task 1.2
Primary (verified to resolve on this runtime by a load probe): `import org.kde.notification`, `Notification { componentName: "com.github.kido5217.multitimer"; eventId: "timerFinished"; title: …; text: i18n("Finished at %1", Qt.formatTime(new Date(finishMs), "HH:mm")) }` + `sendEvent()`. KNotify wants a `knotifications6/com.github.kido5217.multitimer.notifyrc` with a `[Global]` and an `[Event/timerFinished] Action=Popup` group; whether a plasmoid-bundled copy is discovered without a build-system install step is the probe question. Caveats recorded up front: System-Settings mute/style visibility requires the event registration to succeed (and per KNotify docs the full experience wants a matching `DesktopEntry=` desktop file, which this plasmoid lacks), and KNotify may render unknown-event notifications generically — good enough; probe asserts POPUP VISIBLE, and only secondarily settings visibility.
If bundled discovery fails: candidate (b) reuse an already-installed component name (e.g. `plasma_workspace`) for `componentName`. If that also fails: candidate (c) the "notifications" data engine via `org.kde.plasma.plasma5support` `DataSource` — the KDE examples page documents a notifications data engine; its write interface is to be confirmed in Plasma Engine Explorer during the probe. **No other fallbacks are pre-authorized**: if none of the three display, STOP and renegotiate — Qt 5's `QtDBus` QML types are gone on this runtime (probe-disproven), so a hand-rolled D-Bus call is not a 15-line safety net.

### D4: Interaction gates ride the existing harness — probes BEFORE repo edits
The probe must click the WIDGET, not wherever the pointer happens to sit: `ID=$(xdotool search --class plasmoidviewer | tail -1); xdotool windowactivate --sync $ID; xdotool mousemove --window $ID <x> <y>; xdotool click --window $ID 2`, with coordinates taken from a `magick import -window $ID` screenshot of the applet preview area, and a second screenshot proving the pointer landed on the widget. Journal marker confirms delivery. Immediately after (still probe stage, before any implementation), the same scratch package gets installed into the REAL panel (Gate 3, with a distinct scratch Id) for one human middle-click — the premise that "middle-click reaches applet input in a live panel" must be retired before task 2 exists, not after. If button 2 is swallowed in either environment, STOP and renegotiate the input mapping (candidates: Ctrl+click, double-click, popup buttons) — each changes the spec, so none may be silently absorbed.

### D5: Scripted state walk
Same harness as D4 for the RUNNING/PAUSED/READY transitions: assert via `magick import -window` crops (OCR or pixel diff between two grabs 3 s apart: frozen while paused, changing while running) and journal silence for the package path throughout.

### D6: README dev-loop grows, not churns
Keep the three scaffold gates verbatim; add one "Interaction check" subsection with the corrected xdotool recipe and the manual real-panel procedure (add widget, click through four states, notification expected, suspend check optional).

## Risks / Trade-offs

- [Panel swallows button 2 → whole UX premise breaks] → probe 1.1 + early real-panel click happen before any repo edit; stop-and-renegotiate rule in D4.
- [All three notification candidates fail] → change pauses at task 1.2 rather than shipping a silent widget; no improvised transports.
- [1 s Timer coalescing makes display jitter a second] → wall-clock math self-corrects on the next tick; never drifts cumulatively (the spec's suspend-past-expiry scenario is the guard that tick-counting cannot pass).
- [Suspend-past-expiry only verifiable with a real suspend] → human step in task 3.2, flagged as the sole automated-gate exception; scratch shortened duration keeps it under a minute.
- [plasmoidviewer's synthetic containment differs from real panel input routing] → the real-panel probe (D4) is not optional polish; it precedes implementation.
