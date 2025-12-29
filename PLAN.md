# V0.1 Prototype Plan — HordeSurvivor

This plan takes the project from initial scaffolding to a fully working V0.1 prototype, aligned with AGENTS.md (design pillars, data-driven content, fixed timestep, pooling, and stress scene requirements). Each phase includes implementation context and decisions.

## Phase 0 — Project readiness & foundations
**Goal:** Establish the project scaffolding, architectural boundaries, and quality gates.

**Decisions/constraints:**
- Enforce a fixed timestep core loop.
- Separate model (`lib/game/`) from view (`lib/render/`).
- Keep content data-driven (`lib/data/`).
- Use pooling from the start for performance-sensitive entities.

**Implementation notes:**
- Verify `pubspec.yaml` includes Flame and test/lint dependencies.
- Confirm directory structure: `lib/game`, `lib/render`, `lib/ui`, `lib/data`, `assets`, `test`.
- [x] Implement the entry point in `lib/main.dart` with a fixed timestep game runner.
- [x] Add a HUD overlay stub in `lib/ui/`.
- Ensure `flutter analyze`, `flutter test`, and `dart format .` are part of the default workflow.

## Phase 1 — Core simulation loop & player movement
**Goal:** Build the minimal playable loop with player movement, camera, and HUD.

**Decisions/constraints:**
- Simulation logic uses fixed timestep and is testable without rendering.
- No per-frame allocations in movement logic.

**Implementation notes:**
- [x] `lib/game/`: Add `PlayerState` (position, velocity, HP, base stats).
- [x] `lib/game/`: Add fixed-step update with accumulator.
- [x] `lib/render/`: Add `PlayerComponent` to render the player from `PlayerState`.
- [x] `lib/ui/`: Add basic HUD (HP bar).
- [x] Input handling: map keyboard/touch to movement intent.
- [x] Tests in `test/` for player movement and bounds handling.

## Phase 2 — Spawn system & enemy chaser role
**Goal:** Add wave-based spawning and a basic chaser enemy using pooling.

**Decisions/constraints:**
- Spawns are time-based and data-driven.
- Enemy entities use pooling; no per-entity allocations during updates.
- Spawn positions use a ring around the player (120–200 units) and clamp to arena bounds.

**Implementation notes:**
- [x] `lib/game/`: Implement `SpawnerSystem` (wave timings, compositions).
- [x] `lib/game/`: Add `EnemyState` and a pooled `EnemyPool`.
- [x] `lib/game/`: Implement chaser AI.
- [x] `lib/render/`: Render enemy sprite placeholders.
- [x] Tests for spawn timing and chaser movement.

## Phase 3 — Skills system & Fireball + Sword Cut
**Goal:** Implement skill casting and two baseline skills to meet V0.1 scope.

**Decisions/constraints:**
- Data-driven definitions for `SkillDef`.
- Tag system is consistent and central to synergy.
- Projectile and melee deliveries remain true to archetype.
 - Fireball targeting picks the nearest active enemy and falls back to player aim if no target exists.
 - Projectile lifetimes are bounded to avoid unbounded pooling growth in early loops.
 - Sword Cut uses a 90° melee arc at ~46 units, centered on the current aim/nearest target.
 - Spatial grid buckets use 64-unit cells and are rebuilt each fixed step for hit queries.
 - Cooldown timers are validated to support multi-cast bursts when large `dt` steps occur.

**Implementation notes:**
- [x] `lib/data/`: Define `SkillDef` (id, name, tags, params, rarity/weight).
- [x] `lib/game/`: Add `SkillSystem` with cooldowns and basic casting loop.
- [x] `lib/game/`: Add `ProjectileState` and pooled projectile system.
- [x] Fireball: projectile delivery with base damage, lifespan, and speed.
- [x] Sword Cut: melee arc with hit detection.
- [x] Spatial partitioning (grid/buckets) for hit detection.
- [x] Tests for melee hit detection.
- [x] Tests for cooldowns and skill triggers.

## Phase 4 — Damage, HP, death, despawn
**Goal:** Complete survivability loop with damage processing and despawn logic.

**Decisions/constraints:**
- Damage pipeline is event-based and pooled.
- Death/despawn returns entities to pools cleanly.
 - Contact damage ticks each fixed step at a small DPS value while enemies overlap the player.
 - Projectile hits resolve via spatial grid queries and stop at the first collision.

**Implementation notes:**
- [x] `lib/game/`: Add damage events (source, target, amount, tags).
- [x] `lib/game/`: Add HP management for player/enemies.
- [x] `lib/game/`: Add despawn/cleanup with pool return.
- `lib/render/`: Optional damage number visuals using pooling.
- [x] Tests for death and despawn behavior.

## Phase 5 — Level-up and selection UI (skills/items)
**Goal:** Implement the selection loop for skills/items with tradeoffs.

**Decisions/constraints:**
- Items are data-driven and have clear upside/downside.
- No permanent stat meta-progression.
- XP curve is linear (base 20 XP, +10 XP per level).
- Enemy XP rewards are defined in `lib/data/enemy_defs.dart` and granted on defeat.
 - Level-up choices draw from skill + item definitions without duplicates, using base choice count plus `choiceCount` stat modifiers.

**Implementation notes:**
- [x] `lib/data/`: Define `ItemDef` (id, name, tags, modifiers).
- [x] `lib/game/`: Implement XP/level system and enemy defeat XP rewards.
- [x] `lib/ui/`: Build selection overlay with skill/item cards.
- [x] `lib/game/`: Apply modifiers to player stats.
- [x] Tests for modifier application and selection handling.

## Phase 6 — Additional enemy roles (ranged, spawner)
**Goal:** Reach V0.1 minimum of 3 roles: Chaser, Ranged, Spawner.

**Decisions/constraints:**
- Roles must be readable and telegraphed.
- Role definitions remain data-driven.
 - Ranged enemies kite between 55–90% of their attack range and fire imperfect shots based on their projectile spread.
 - Spawners emit configured minions on a cooldown, clamped to arena bounds, with spawn stats taken from enemy definitions.
 - Spawn waves can request weighted role mixes; role weights select a role first, then pick an enemy within that role using per-enemy weights.

**Implementation notes:**
- [x] Ranged enemy: imperfect aim projectile pattern using enemy-defined cooldowns and spread.
- [x] Spawner enemy: Portal Keeper spawns data-driven minions until killed.
- Render distinct telegraphs and silhouettes.
- [x] Update `SpawnerSystem` to include role weighting.
- [x] Tests for ranged fire cadence and spawner behavior.

## Phase 7 — Sprite generation pipeline (data-driven)
**Goal:** Create a lightweight, in-project pixel sprite generation pipeline.

**Decisions/constraints:**
- Generation inputs are data-driven (palette, seed, shapes) and live in JSON assets.
- Pipeline is decoupled from gameplay logic and uses a cache for reuse.
- Shape rendering supports simple primitives (circle/rect/pixels) with optional seeded jitter for pixel noise.
 - Additional primitives use a single saved layer and BlendMode.dstIn masks for in-order masking.
 - Recipe validation logs errors and skips invalid recipes; out-of-bounds shapes emit warnings.
 - Runtime sprite wiring should reuse generated images loaded at game start (no per-frame allocations).

**Implementation notes:**
- [x] Define sprite recipe data objects in `lib/data/sprite_recipes.dart` and load from JSON.
- [x] Add a recipe loader (`lib/render/sprite_recipe_loader.dart`) that reads assets.
- [x] Build generator module (`lib/render/sprite_generator.dart`) that renders circles/rects/pixels.
- [x] Add a cached pipeline (`lib/render/sprite_pipeline.dart`) plus `SpriteCache`.
- [x] Provide a demo renderer/export helper in `lib/render/sprite_gen_demo.dart`.
- [x] Ship baseline recipes in `assets/sprites/recipes.json` (player, enemy, item, skill, ground, projectile, pickup).
- [x] Wire runtime generation for the player sprite in `lib/game/horde_game.dart`.
- [x] Add recipe validation (required keys, bounds checking, palette references) with clear error logging.
- [x] Expand the generator with additional primitives (lines, arcs, layered masks) for more readable silhouettes.
- [x] Map generated sprites to runtime components for player, enemies, and projectiles (items/UI TBD).
- [x] Add tests for recipe loading + deterministic generation (seeded output).
- [x] Decide on runtime vs build-time export workflow and document in code comments or README.
  - Decision: runtime sprite generation is the default; optional export via
    `SpriteGenDemo` is available for development inspection or asset baking.

## Phase 8 — Stress scene (performance validation)
**Goal:** Validate 60 FPS target with high entity counts.

**Decisions/constraints:**
- Stress scene must be toggled via a single debug route or flag.
- Pooling and spatial partitioning required.
 - Stress scene uses a `/stress` route (or `STRESS_SCENE=true` dart-define) and
   reuses the main game loop with larger pooled counts.
 - FPS + frame time are displayed in the HUD only during stress mode.
 - Stress scene logs a single startup note to capture qualitative benchmark
   context alongside HUD readings.

**Implementation notes:**
- [x] Create debug route to spawn 500+ enemies and 1000+ projectiles.
- [x] Add FPS/frame time overlay.
- [x] Add qualitative benchmark notes in code comments or logs.

## Phase 9 — Cross-platform run readiness
**Goal:** Ensure the game runs on core platforms (Android + Windows debug).

**Decisions/constraints:**
- Desktop and mobile input supported.
- Avoid platform-specific assumptions in rendering or assets.

**Implementation notes:**
- Validate input mapping for keyboard + touch.
- Ensure sprite generation works on target platforms.
- Update `README.md` only if new platform-specific steps are required.

## Phase 10 — V0.1 polish & validation
**Goal:** Deliver a stable, playable V0.1 prototype.

**Decisions/constraints:**
- Must meet V0.1 checklist and quality gates.
- No new TODOs without issue/task references.

**Implementation notes:**
- Verify skills (Fireball + Sword Cut) and 3 enemy roles.
- Ensure selection UI and progression loop are functional.
- Run `dart format .`, `flutter analyze`, `flutter test`.
- Confirm stress scene performance qualitatively and document results.
