# Spec Delta

## Purpose

Defines the behavior of the widget's single fixed-duration countdown timer: its four states, the one-button interaction model, wall-clock countdown semantics, and completion notification.

## ADDED Requirements

### Requirement: Fixed five-minute timer with four states
The widget SHALL operate exactly one countdown timer of fixed duration 300 seconds and SHALL be in precisely one of four states — READY (display `05:00`, disarmed), RUNNING (displaying remaining whole seconds, rounded down, as `MM:SS` with leading zeros, updated at least once per second), PAUSED (display frozen at the remaining time), FINISHED (display `00:00` blinking with a full on/off cycle of roughly one second until reset).

#### Scenario: Boots into READY
- **WHEN** the widget loads
- **THEN** it is in READY showing `05:00` and no timer is running

#### Scenario: Countdown display format
- **WHEN** the timer is RUNNING with 299 or fewer seconds remaining
- **THEN** the visible text is `MM:SS` with zero padding (e.g. `04:59`, `00:07`)

### Requirement: Middle-click performs exactly one action per state
A middle mouse click on the widget SHALL execute exactly one state transition: READY→start, RUNNING→pause, PAUSED→resume, FINISHED→reset. No other pointer button or gesture shall change timer state.

#### Scenario: Start
- **WHEN** the widget is READY and receives a middle click
- **THEN** it enters RUNNING and the display begins counting down from `05:00`

#### Scenario: Pause and resume
- **WHEN** the widget is RUNNING and receives a middle click
- **THEN** it enters PAUSED with the displayed time frozen, and a further middle click returns it to RUNNING continuing from the frozen remainder

#### Scenario: Reset is inert
- **WHEN** the widget is FINISHED and receives a middle click
- **THEN** it enters READY showing `05:00`, blinking stops, the pending finish time is cleared, no notification is sent, and the timer does NOT start — a separate middle click is required to start

### Requirement: Countdown is wall-clock
The displayed remaining time SHALL be derived from a deadline timestamp, not from accumulated ticks: pause SHALL store the remaining interval and resume SHALL re-arm the deadline from it, so that missed or coalesced timer ticks cannot make the countdown drift, and time spent suspended counts against the deadline.

#### Scenario: Paused across suspend keeps the remainder
- **WHEN** the timer is PAUSED with `03:00` displayed, the machine suspends and resumes
- **THEN** the display still reads `03:00`, and after resume+middle click it runs for another 3 minutes

#### Scenario: Suspended past expiry wakes finished
- **WHEN** the timer is RUNNING and the machine suspends long enough that the deadline passes, then resumes
- **THEN** the widget presents FINISHED (blinking `00:00`, one notification bearing the deadline's `HH:mm`) rather than a still-counting display

### Requirement: Completion notifies once with the finish time
On the RUNNING→FINISHED transition the widget SHALL send exactly one desktop notification whose body states the local wall-clock finish time (`HH:mm`), SHALL stop re-notifying thereafter, and SHALL show the same information in its tooltip while FINISHED; the tooltip SHALL describe the current state in every state (e.g. READY: "Ready — middle-click to start", RUNNING/PAUSED: remaining time).

#### Scenario: Finish emits one notification
- **WHEN** the deadline passes while RUNNING
- **THEN** the widget enters FINISHED, blinks `00:00`, and one notification appears containing the finish time; it stays blinking without further notifications until reset

#### Scenario: Tooltip mirrors state
- **WHEN** the user hovers the widget in any state
- **THEN** the tooltip reflects that state, and while FINISHED it contains the same `HH:mm` finish time as the notification

### Requirement: Timer face lives in the panel with a mirroring popup
The timer display SHALL be the widget's compact representation (visible in the panel without interaction), and the popup opened by left-click SHALL mirror the same state and display, with left-click retaining Plasma's default toggle behavior (open when closed, close when open).

#### Scenario: Panel presence
- **WHEN** the widget is placed in a Plasma panel
- **THEN** the current display text is visible in the panel itself

#### Scenario: Popup mirrors state
- **WHEN** the user left-clicks the widget while RUNNING with `02:41` remaining
- **THEN** the popup shows `02:41` in the same state
