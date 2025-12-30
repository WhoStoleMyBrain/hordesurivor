# V0.2 Plan — HordeSurvivor

This plan advances the project from the completed V0.1 prototype into V0.2. It focuses on run flow (start → home base → area select → stage → death), stage timing, content expansion, and extensibility hooks for future systems (contracts/heat, map modifiers, loot tables). It stays aligned with AGENTS.md: fixed timestep, pooling, data-driven content, and readability over complexity.

## V0.2 Objectives (summary)
- **New run flow:** start screen, home base, area selection, stage start, death screen.
- **Stage lifecycle:** stage timer, sectioned spawn distributions, run end conditions.
- **Content expansion:** more skills, items, and enemy roles/behaviors with sprite updates.
- **Extensibility:** data-driven areas, future modifiers, difficulty selection, loot info.
- **UX polish:** simple score display, restart/return paths, clear transitions.

---

## Phase 0 — Baseline alignment & new data definitions
**Goal:** Lay the groundwork for V0.2 data-driven content and flow without disrupting V0.1 systems.

**Decisions/constraints:**
- Keep **model vs view** separation: game state stays in `lib/game/`, UI/overlays in `lib/ui/`.
- Extend data definitions rather than hard-coding logic.
- No new TODOs without issue/task references.
- Area definitions include both role-level and enemy-specific weight maps for spawn tuning.
- Stage sections must be ordered, non-overlapping, and fit within the stage duration.

**Implementation notes:**
- Add `AreaDef` data objects in `lib/data/` (id, name, description, spriteId, recommendedLevel, lootProfile, difficultyTiers, stageDuration, sectionTimeline).
- Add `StageSection` data (startTime, endTime, spawnWeights, enemyMix).
- Add `RunSummary` structure in `lib/game/` (timeAlive, enemiesDefeated, xpGained, damageTaken, score).
- Add a lightweight `GameFlowState` enum to represent Start → HomeBase → AreaSelect → Stage → Death.
- Ensure data validation includes new `AreaDef` and `StageSection` references.
**Completed:**
- Added `AreaDef`/`StageSection` data definitions with sample areas and sections.
- Added `RunSummary` and `GameFlowState` scaffolding.
- Extended data validation for new area data structures.

---

## Phase 1 — Start screen & game flow routing
**Goal:** Provide an initial start screen and explicit game flow state transitions.

**Decisions/constraints:**
- Start screen is a UI overlay; the simulation does not run until a new run is requested.
- Keep UI routing centralized to avoid state leaks.
- Stress scene bypasses the start screen and begins in the stage flow state.
- Options are presented as a simple overlay and do not change flow state.

**Implementation notes:**
- Add `StartScreen` widget in `lib/ui/` with “Start” (and optional “Options”) CTA.
- Add a flow/router controller (e.g., `GameFlowController` in `lib/game/` or `lib/ui/`) to swap scenes/overlays.
- Ensure input routing disables gameplay input when overlays are active.
**Completed:**
- Added `StartScreen` overlay with a “Start Run” CTA.
- Gated simulation updates until the flow transitions to `GameFlowState.stage`, and lock input when not in stage.
- Start action removes the start overlay and enables the HUD; stress scene starts in stage.
- Added an options overlay stub reachable from the start screen and returning to it.
- Clear keyboard movement input when the flow locks/unlocks to prevent stuck movement after overlays.

---

## Phase 2 — Home base scene (non-combat)
**Goal:** Introduce a home base area where the player can move but **auto-attack is disabled**, and a portal leads to the area select screen.

**Decisions/constraints:**
- Home base uses the same core simulation loop but with combat systems disabled.
- Keep home base content minimal and readable; no enemies or combat.
- Portal interaction uses proximity checks in the fixed-step loop (no new collision system).

**Implementation notes:**
- Add `HomeBaseScene` in `lib/render/` that reuses player movement + camera.
- Gate skill casting and auto-attack logic with a `combatEnabled` flag on the scene or game state.
- Add an interactable `PortalComponent` (collision or proximity) to open area selection.
- Hook transition to `AreaSelect` via `GameFlowController`.
**Completed:**
- Added a home base flow state with movement-only stepping and combat/spawn systems disabled.
- Added a portal render component that triggers the area select overlay on proximity.
- Added a lightweight home base overlay instruction banner.

---

## Phase 3 — Area selection screen (extensible)
**Goal:** Allow selection of a stage/area, with future hooks for difficulty modifiers and loot info.

**Decisions/constraints:**
- Area selection is data-driven via `AreaDef`.
- UI should be extensible for later contracts/heat modifiers.

**Implementation notes:**
- Add `AreaSelectScreen` in `lib/ui/` listing all `AreaDef`s.
- For each area, display: name, short description, stage duration, enemy themes, loot profile (stubbed), and difficulty tiers (stubbed).
- Selecting an area triggers a run setup and transitions to the stage scene.
- Add placeholder UI for “Contracts” and “Difficulty” (disabled in V0.2 but structured).
**Completed:**
- Extended area cards with difficulty tier display and a disabled contracts placeholder note.

---

## Phase 4 — Stage lifecycle & timer sections
**Goal:** Introduce stage timing, sectioned spawn distributions, and run end conditions.

**Decisions/constraints:**
- Stage timer drives spawn profiles and end-of-run transitions.
- Spawn system remains pooled and data-driven.

**Implementation notes:**
- Add a `StageTimer` in `lib/game/` with elapsed time and max duration from `AreaDef`.
- Add section-based spawn selection in `SpawnerSystem` using `StageSection`.
- Emit “run ended” when duration is complete; transition to death screen with success state.
- Update HUD to display stage timer and current section indicator (e.g., “Section 2/4”).
**Completed:**
- Added `StageTimer` and HUD readouts for stage time + section index.
- Switched stage spawns to section-driven wave generation on section change.
- Stage completion currently returns the player to home base and clears enemies/projectiles.
**Decisions:**
- Section spawns are generated with a fixed wave interval and a small per-section count bump.
**Follow-ups:**
- Swap the stage completion return-to-base flow for the upcoming death/run summary screen.

---

## Phase 5 — Death & run summary
**Goal:** Add a death screen that shows a simple score and lets players restart or return to home base.

**Decisions/constraints:**
- Use a **simple score formula** for V0.2 (e.g., timeAlive + enemiesDefeated + xpGained).
- Store metrics in `RunSummary` and reset cleanly on restart.

**Implementation notes:**
- Add `DeathScreen` overlay in `lib/ui/`.
- Populate from `RunSummary` when player HP reaches 0 or stage duration ends.
- Provide actions: “Restart Run” and “Return to Home Base.”
**Completed:**
- Added a `DeathScreen` overlay with score and run stats plus restart/return actions.
- Tracked run summary metrics (time alive, kills, XP gained, damage taken) during stage flow.
- Routed stage completion and player death into the death screen flow with reset handling.
- Restart now resets player XP/level, skill loadout, and item modifiers to baseline.
**Decisions:**
- Restart uses the last selected area and revives the player at center.
- Restarts reset run progression (XP, skills, item modifiers) to keep runs discrete.
**Follow-ups:**
- Consider whether any meta-layer should carry progression between runs later.

---

## Phase 6 — Skills & items expansion (simple playtest version)
**Goal:** Expand skills/items with minimal complexity, keeping clear tradeoffs and easy tuning.

**Decisions/constraints:**
- Keep **data-driven** definitions; no new archetypes without data tags.
- Focus on straightforward mechanics (e.g., simple DOT, knockback, slow).

**Implementation notes:**
- Implement additional skills from AGENTS.md list with basic behaviors:
  - Waterjet (beam, slow), Oil Bombs (ground + debuff), Poison Gas (aura + DOT), Roots (snare).
  - Sword variants (Thrust, Swing, Deflect) with clean telegraphs.
- Add a minimal stat modifier pipeline for items if not already exposed in UI.
- Update `lib/data/skill_defs.dart` and `lib/data/item_defs.dart` with playtest numbers.
- Ensure UI labels show clear tradeoff text for items.
**Completed:**
- Added baseline casting logic for the remaining V0.1 skills (waterjet, oil bombs, sword thrust/swing/deflect, poison gas, roots) using simple projectile/arc/area bursts.
- Sword deflect now clears nearby enemy projectiles on cast.
- DOT-tagged skills now factor in `StatId.dotDamage` in the damage multiplier.
- Added waterjet beam effects plus lingering oil/roots ground zones with DOT-style damage ticks.
- Oil bomb ground effects now spawn at the projectile impact location.
- Added slow/root debuffs for waterjet, oil, and roots that scale with root stats and refresh while enemies remain in the effect.
**Decisions:**
- Placeholder implementations favor readable hitboxes over bespoke status effects for V0.2.
- Ground effects apply damage over their full duration instead of a one-time burst.
- Roots apply a movement snare using the root strength/duration stats rather than a full immobilize.
**Follow-ups:**
- Add status VFX/telegraphs for slowed or rooted enemies.

---

## Phase 7 — Enemy expansion (roles, behaviors, sprites)
**Goal:** Add new enemy behaviors with readable telegraphs and sprite support.

**Decisions/constraints:**
- Maintain role clarity; every enemy should read quickly in crowds.
- Behavior should be data-driven where possible.

**Implementation notes:**
- Add demon and angel roles as incremental behaviors:
  - Debuffer (Hexer aura), Buffer (Herald aura), Healer (Seraph Medic beam), Zoner (Warden light zones), Exploder (Cinderling), Elite (Hellknight dash).
- Update `lib/data/enemy_defs.dart` with role params and `spriteId` bindings.
- Expand sprite recipe sets for new silhouettes, keeping palette contrast.
- Add role telegraphs (aura/beam/charge) in `lib/render/`.
**Completed:**
- Added baseline behaviors for disruptor, zoner, exploder, support, pattern, and elite roles, including healing/rally pulses, ring attacks, and dashes.
- Added special-action telegraphs for non-ranged roles and tuned enemy stat blocks for the new behaviors.
- Added aura/zone ring visuals for support and zoner enemy roles to improve readability.
- Added unique sprite recipes for the expanded enemy roster and wired sprite IDs in enemy definitions.
**Decisions:**
- Support healer pulses restore ally HP; support buffer pulses shorten nearby allies’ attack/spawn timers.
- Exploders self-destruct by routing damage through the standard damage system for XP/cleanup consistency.
**Follow-ups:**
- Add new enemy sprite silhouettes if future roles are introduced.

---

## Phase 8 — UX polish, analytics hooks, and QA gates
**Goal:** Polish V0.2 flow and keep quality gates intact.

**Decisions/constraints:**
- No new TODOs without issue/task references.
- Avoid drive-by refactors.

**Implementation notes:**
- Add minimal run summary stats (time alive, kills, XP, damage taken).
- Add a “flow debug” overlay toggle for quick testing of states.
- Run `dart format .`, `flutter analyze`, `flutter test` after updates.
- If performance-sensitive code changes, add a short note on pooling/allocation impacts.
**Completed:**
- Added a flow debug overlay (toggle with F1) with quick jumps to each flow state.
**Decisions:**
- Flow debug overlay uses the first `AreaDef` when jumping directly into stage.

---

## Implementation ordering (recommended)
1. **Flow & data scaffolding:** `AreaDef`, `StageSection`, `RunSummary`, `GameFlowState`.
2. **Start screen → Home base → Area select** with routing.
3. **Stage timer + section-based spawns + run end**.
4. **Death screen with restart/return**.
5. **Skills + items expansion** (basic behaviors, clear tradeoffs).
6. **Enemy behaviors + sprites + telegraphs**.
7. **Polish & QA gates**.

---

## Extensibility notes (future V0.3+ hooks)
- Area UI already includes placeholders for contracts/heat and difficulty tiers.
- `AreaDef` should allow optional loot modifiers and map mutators.
- `RunSummary` can later include contracts, area, and build tags for meta tracking.
