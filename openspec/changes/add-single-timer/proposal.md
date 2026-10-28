# Proposal

## Why

The widget currently renders a static "Multitimer" placeholder — nothing it does is functional. The first useful slice is the core timer loop itself: a fixed 5-minute countdown driven entirely by one mouse button, with completion announced through the desktop notification system. Small on purpose: no configuration, no multiple timers yet — just the interaction model proven end to end on the real runtime.

## What Changes

- `package/contents/ui/main.qml` becomes a four-state timer: READY (`05:00`) → RUNNING (`04:59`...) → PAUSED (frozen) → FINISHED (blinking `00:00` + one notification). Middle-click performs exactly one action per state: start / pause / resume / reset. Reset from FINISHED lands on READY and is inert — it does not auto-start.
- The digits move to the **compact representation** (visible in the panel); `preferredRepresentation` flips from `fullRepresentation` to `compactRepresentation`. Left-click keeps Plasma's default popup behavior, and the popup (full representation) mirrors the timer state.
- Countdown is wall-clock: a deadline timestamp plus a 1 s render tick; pause stores the remaining milliseconds. Suspend keeps counting against the deadline (a laptop slept past expiry wakes into FINISHED + notification).
- On entering FINISHED, exactly one notification fires, its body carrying the local finish time (`HH:mm`); the widget tooltip mirrors the state (e.g. "Finished at 14:32").
- Notification transport: KNotifications QML (`org.kde.notification`, verified to resolve on this runtime) as the primary path, with ordered probed candidates (reuse of an installed component name, then the Plasma5Support notifications data engine) if the plasmoid-bundled `.notifyrc` proves undiscoverable; no unprobed fallback is pre-authorized — Qt 5's QtDBus QML types do not exist on Qt 6.
- Spec side: new capability `timer-core`; `plasmoid-package`'s "visible placeholder" requirement is MODIFIED — the boot check now renders the timer face (`05:00`) instead of the name label.

Out of scope (deliberately): configurable durations, multiple timers, sounds, persistence across plasmashell restart, keyboard input, config UI. Each becomes its own follow-on change.

## Capabilities

### New Capabilities

- `timer-core`: the single fixed-duration timer — state machine, middle-click semantics, countdown rendering, pause/resume math, completion notification, finished-state blinking, popup mirror.

### Modified Capabilities

- `plasmoid-package`: "Widget boots with a visible placeholder" is reworded to render the timer face instead of the widget-name label; load/install requirements unchanged.

## Impact

- One source file changes (`main.qml`); optionally a bundled `.notifyrc` in `package/`; README gains interaction-check commands. `metadata.json` Version stays `0.1.0` (no release process yet). No build system, no flake, no C++ — the pure-QML constraint from the scaffold still holds.
- Acceptance gains scripted interaction gates (plasmoidviewer + xdotool synthetic middle-clicks) alongside the existing three.
