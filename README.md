# Core Reactor

A PC idle / incremental game built with Godot 4. Energy is produced automatically, reinvested in reactor upgrades, and converted into permanent progress through Prestige.

## Play on Windows

Download `CoreReactor-Windows.zip`, extract it, and run `CoreReactor.exe`. Keep `CoreReactor.exe` and `CoreReactor.pck` together in the extracted folder.

## Run from source

Open `project.godot` with Godot 4.7.2 or newer and run the main scene at `scenes/main.tscn`.

## Current progression

- Base production is 1 Energy/sec.
- Core Power scales by `1 + level`; Core Frequency scales by `1 + level × 0.06`; Efficiency scales by `1 + level × 0.10`.
- Each ordinary upgrade has milestones at levels 10, 25, 50, and 100. Every milestone adds a global ×1.3 production multiplier.
- Prestige becomes available at 4,000,000 Energy produced in the current run. The gain is `floor(sqrt(run_energy / 4,000,000))`, with at least 1 point once the threshold is reached.
- Prestige has Production, Automation, and Offline branches. Permanent upgrades include Reactor Mastery, Overdrive, Critical Output, automation unlocks, and offline bonuses.
- Offline gains start at 25% efficiency. The initial offline cap is 8 hours; each Offline Capacity level adds 4 hours, up to 24 hours.
- Auto Prestige supports 2, 5, 10, 25, 50, and 100 PP targets, with a configurable minimum run time.

Balance values are centralized in `scripts/balance_config.gd`; save and progression logic is split between the manager scripts under `scripts/`.

## Saves and settings

Saves are local to each player through Godot's `user://core_reactor_save.json`. No personal save file is included in the repository or Windows ZIP. The game autosaves progress and keeps volume, number format, language, and automation settings locally.

## Project layout

- `scenes/main.tscn` — main game scene
- `scripts/game_manager.gd` — production, run state, statistics, and persistence
- `scripts/upgrade_manager.gd` — ordinary upgrades, milestones, and auto-buying
- `scripts/prestige_manager.gd` — Prestige awards and permanent upgrade branches
- `scripts/balance_config.gd` — centralized balance values
- `scripts/save_manager.gd` — local save/load
- `scripts/number_formatter.gd` — suffix and scientific number formats
- `scripts/ui/` — game UI, Reactor visual, and animated background
- `marketing/` — itch.io cover, screenshots, and trailer
