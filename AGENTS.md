# AGENTS.md — HordeSurvivor (Flutter/Flame)

This file is written for Codex cloud agents (and humans) to keep work aligned and minimize back-and-forth.
Follow it strictly unless a task explicitly says otherwise.

---

## 1) Game meta-information

### 1.1 One-line pitch

A pixel-style horde survivor focused on **readable combat**, **enemy role variety**, and **build depth via tag synergies and tradeoffs**, without permanent stat-grind metaprogression.

### 1.2 Design pillars (non-negotiable)

- **No stat meta-progression**: no permanent “+HP/+DMG” unlocks that invalidate early game.
- **Metaprogression is lateral**: unlocks add options (skills/items/factions/contracts), not raw power.
- **Difficulty is opt-in**: “Contracts/Heat” modify rules and rewards.
- **Clarity beats complexity**: every enemy/skill must read clearly in a crowded screen.
- **Build identity through tags + tradeoffs**: synergies should feel like evolutions without hard “category switching.”

### 1.3 Metaprogression & difficulty (V0.1 intent)

- **Meta currency** exists, but in V0.1 it may be stubbed.
- Meta unlocks are later used for:
  - Unlocking additional skills/items/factions/characters
  - Convenience unlocks only (bounded): e.g., +1 reroll, +1 starting choice (NO multipliers)
- **Contracts/Heat** (can be implemented later) will:
  - Increase difficulty via mutators (more elites, faster projectiles, extra support enemies, etc.)
  - Increase rewards proportionally

### 1.4 Content lists (V0.1)

#### Enemy roles & factions (V0.1)

**Shared core**

- Chaser (exists in both factions)

**Demons (pressure + debuff + explosive)**

- Chaser: Imp (fast, low HP)
- Ranged: Spitter (imperfect aim; “near player”)
- Summoner/Spawner: Portal Keeper (spawns imps until killed)
- Disruptor: Hexer (slow/weaken aura or curse projectile)
- Zoner: Brimstone Brander (burning ground patches)
- Elite: Hellknight (telegraphed dash + slam AOE)
- Exploder: Cinderling (detonates on timer/on death)

**Angels (support + patterns + zone control)**

- Chaser: Zealot (steady, tankier)
- Ranged: Cherub Archer (telegraphed volley pattern)
- Support (Healer): Seraph Medic (obvious heal beam)
- Support (Buffer): Herald (buff aura)
- Zoner: Warden (stationary “no-go” light zones)
- Pattern: Sentinel (patrol arcs/lines; minimal tracking)
- Elite: Archon Lancer (telegraphed charge; wind trail hazard)

### 1.5 Guardrails for skills/upgrades

- **No archetype betrayal**: projectile stays a projectile-style damage delivery; buff stays buff; etc.
- Prefer **tag synergies** over hard evolutions:
  - Example: Oil (Debuff) + Fire triggers “Ignition” effect (burst/extra DOT).
- **Tradeoffs must be legible**:
  - One clear upside, one meaningful downside
  - No “gotcha” downsides that only matter 10 minutes later without warning

### 1.6 Theme

- The theme is defined in THEME_GUIDE.md. Always refer to this theme guide when updating core elements of the game, especially sprites, skills, items, descriptions.

## 2) Technical & infrastructure information

### 2.1 Tech stack

- **Flutter (stable channel)**
- **Flame** for the game loop, rendering, and components
- Target platforms (priority order for V0.1):
  1. Android (primary dev target)
  2. Windows desktop (debug convenience)
  3. iOS/macOS/Linux later
  4. Web is optional and should not dictate early design unless a task explicitly targets it

### 2.2 Core architectural decisions (non-negotiable)

- Use a **fixed timestep** simulation for gameplay logic (determinism-friendly).
- Avoid per-entity allocations each frame:
  - Use **object pooling** for enemies/projectiles/damage numbers/particles.
- Use spatial constraints early:
  - Use **simple spatial partitioning** (grid or buckets) for proximity queries.
- Rendering:
  - Prefer **SpriteBatch / batching-friendly** drawing patterns where applicable.
- Separate “model” from “view”:
  - Game state / systems (pure-ish Dart) should be testable without rendering.

### 2.3 Repository structure (implemented)

- `lib/game/` — simulation + systems (movement, combat, spawns, tags, items)
- `lib/render/` — Flame components and render adapters
- `lib/ui/` — menus, selection screens, overlays, HUD
- `lib/data/` — static definitions (skills/items/enemies as data)
- `assets/` — art/audio (may be placeholders in V0.1)
- `test/` — unit tests for systems, plus lightweight integration tests

Agents may propose a slightly different structure if they also migrate existing code consistently.

### 2.3.1 Technical overview (where to look first)

Quick orientation for cloud agents; use this as the “map” when a task arrives:

- **Entry point & routing:** `lib/main.dart` initializes UI scale + data validation, wires routes (stress scene), and attaches overlays to the `GameWidget`.
- **Core game loop:** `lib/game/horde_game.dart` runs the fixed timestep, owns pools, systems, input handling, run flow, and HUD state.
- **Game flow states:** `lib/game/game_flow_state.dart` defines the Start → Home Base → Area Select → Stage → Death lifecycle.
- **Systems (simulation):**
  - **Skills/combat:** `lib/game/skill_system.dart`, `lib/game/projectile_system.dart`, `lib/game/effect_system.dart`, `lib/game/damage_system.dart`.
  - **Enemies & spawns:** `lib/game/enemy_system.dart`, `lib/game/spawner_system.dart`, `lib/game/spawn_director.dart`.
  - **Progression & rewards:** `lib/game/progression_system.dart`, `lib/game/level_up_system.dart`, plus reward handling in `lib/game/horde_game.dart`.
  - **Summons & pickups:** `lib/game/summon_system.dart` and pool classes in `lib/game/*_pool.dart`.
  - **Spatial queries:** `lib/game/spatial_grid.dart` for proximity checks.
- **Data catalogs:** definitions live in `lib/data/` (`skill_defs.dart`, `item_defs.dart`, `enemy_defs.dart`, `area_defs.dart`, `contract_defs.dart`, `currency_defs.dart`, `progression_track_defs.dart`, `selection_pool_defs.dart`, `synergy_defs.dart`, `weapon_upgrade_defs.dart`) and are validated by `lib/data/data_validation.dart`.
- **Rendering:** Flame components + visuals in `lib/render/` (e.g., `player_component.dart`, `enemy_component.dart`, `projectile_batch_component.dart`, `render_scale.dart`, `sprite_pipeline.dart`).
- **UI & overlays:** screens/overlays in `lib/ui/` (Start, Options, Area Select, Selection, HUD, Meta Unlocks, Death, etc.); `lib/ui/side_panel.dart` hosts the persistent HUD panel layout.
- **Input:** keyboard handling lives in `lib/game/horde_game.dart`; touch stick visualization in `lib/ui/virtual_stick_overlay.dart` + state in `lib/ui/virtual_stick_state.dart`.
- **Persistence:** meta currency + unlocks in `lib/game/meta_currency_wallet.dart` and `lib/game/meta_unlocks.dart`; UI scale persistence in `lib/ui/ui_scale.dart`.

### 2.4 Data-driven content

V0.1 content should be definable as data objects, not hard-coded behavior:

- `SkillDef`, `ItemDef`, `EnemyDef` with:
  - `id`, `name`, `tags`, `rarity/weight`, `params`
- Tag system is a first-class concept:
  - Implement tags as enums or interned strings, but keep them consistent.
- Sprite generation inputs/recipes should be data-driven (e.g., palettes, shapes, seeds) and decoupled from rendering code.

### 2.5 Testing & quality gates

Before opening a PR:

- `flutter analyze` must pass
- `flutter test` must pass
- `dart format .` applied to touched files
- No new TODOs without an associated issue/task reference

If a change impacts performance-sensitive code, include:

- A short note on allocations avoided / pooling used
- Any benchmark notes from the stress scene (even qualitative)

### 2.6 Collaboration rules for cloud agents

- Keep PRs small and focused (one feature/system per PR).
- Avoid “drive-by refactors” unless explicitly requested.
- If changing data formats or core APIs, update:
  - Definitions in `lib/data/`
  - Any loader/registry code
  - Tests
- Prefer additive changes; avoid breaking changes unless required for the task.

### 2.7 Licensing notes (for agent awareness)

- Code license will be selected later (MIT/Apache/GPL decision deferred).
- Assets are intended to be **proprietary** (All Rights Reserved) even if code is open.
  - Agents should not import third-party assets without clear license compatibility
  - If third-party assets are necessary for placeholders, prefer permissive CC0 and document sources

---
