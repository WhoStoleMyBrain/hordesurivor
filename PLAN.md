# V0.4 Plan — HordeSurvivor (revised scope)

This revised V0.4 plan focuses on fixing core feel issues and missing systems called out in AGENTS.md: **readable combat**, **rewarding moment-to-moment gameplay**, **enemy role clarity**, **tag-based build identity**, and **lateral progression** with opt-in difficulty. It replaces the prior V0.4 scope and sets a step-by-step sequence that Codex cloud agents can follow.

---

## V0.4 Objectives (summary)
- **Combat feel pass:** increase player/enemy/attack visual scale, add knockback, and make attacks read clearly.
- **Content completeness:** implement any missing or partially implemented skills/attacks and ensure tooltips match behavior.
- **Reward loop:** add earnable meta currency, a lateral meta unlock tree, and improve in-run rewards/feedback.
- **Difficulty system:** implement Contracts/Heat (opt-in) with clear mutators and reward scaling.
- **Clarity & performance:** maintain fixed timestep, pooling, data-driven defs, and readability in crowds.

---

## Progress updates
- ✅ Phase 2 (Knockback & impact feedback): added per-skill knockback parameters and applied knockback impulses during combat resolution. Follow-up: tune knockback values after playtesting and consider adding small hit-flash intensity tweaks once impact feel is validated.
- ✅ Phase 4 (Reward loop): added a HUD-level "LEVEL UP!" pulse to make level gains more readable during combat.
- ✅ Phase 4 (Reward loop): added a HUD acquisition pulse when selecting rewards (skills/items/upgrades). Decision: keep feedback in the HUD overlay for now to avoid extra VFX noise. Follow-up: consider adding a subtle sound cue or pickup spark once audio/VFX passes begin.
- ✅ Phase 3 (Skill/attack completeness): converted Poison Gas to a follow-player DOT aura effect so it matches the skill description. Decision: keep a short 0.8s aura per cast for now. Follow-up: tune aura duration/radius once combat pacing is playtested.
- ✅ Phase 4 (Reward loop): surfaced stat modifier lines for skill upgrades in the selection UI so choices show explicit deltas alongside tags.
- ✅ Phase 5 (Meta currency): added a first-pass "Meta Shards" earn rule based on run time, XP, and completion, and surfaced the earned amount on the run summary. Decision: keep it run-summary-only for now. Follow-up: add a persistent wallet and home-base UI entry for spending.
- ✅ Phase 5 (Meta currency): added a persistent Meta Shards wallet (save/load via shared preferences) and surfaced the wallet total in the start screen, home base overlay, and death screen. Decision: show the wallet badge in HUD overlays only for now to avoid clutter during combat. Follow-up: build the lateral unlock screen and spending flow.
- ✅ Phase 5 (Meta currency): added a Meta Unlocks screen with two lateral convenience unlocks (extra reroll, extra choice), wired to Meta Shards spending and applied their modifiers at run start. Decision: keep unlocks minimal and convenience-only while the full tree is scoped. Follow-up: expand the unlock catalog with skills/items/faction unlocks and add a tree-style layout once more options exist.
- ✅ Phase 6 (Contracts/Heat): added initial Contract definitions, selectable Contracts on the area selection screen, and applied their modifiers to elite odds, support spawns, enemy projectile speed, and meta shard rewards. Decision: keep the first Contracts list small and global for all areas. Follow-up: expand contract catalog with area-specific mutators and surface in-run UI indicator.
- ✅ Phase 6 (Contracts/Heat): surfaced an in-run HUD indicator for active Contract heat and names. Decision: keep the readout in the HUD panel near threat tier for clarity. Follow-up: revisit styling once broader HUD layout changes land.
- ✅ Phase 1 (Visual scale & readability pass): applied UI-wide text scaling via `MediaQuery` so `UiScale.textScale` affects overlay text. Decision: rely on `TextScaler.linear` for consistent scaling across overlays. Follow-up: add a settings toggle to adjust `UiScale.textScale` once Options exposes UI scale.
- ✅ Phase 3 (Skill/attack completeness): aligned Waterjet and Sword Thrust/Deflect descriptions to current behavior so tooltips match in-game actions. Decision: keep Waterjet as rapid pulses and Sword Deflect as an instant parry until mobility/deflect windows are implemented. Follow-up: revisit sword thrust mobility and deflect window once player impulse support exists.
- ✅ Phase 7 (Enemy role clarity & scale tuning): added lightweight role badges over non-core enemies to reinforce role readability without extra VFX noise. Decision: skip badges for basic chaser/ranged/spawner to keep clutter low. Follow-up: adjust badge shapes/colors once sprite silhouettes are updated.
- ✅ Phase 1 (Visual scale & readability pass): added an Options slider to adjust UI text scale and wired it through `UiScale` so overlay text scales consistently. Decision: keep the slider in Options and store the value in-memory for now. Follow-up: persist the UI scale preference alongside other settings once a shared settings save/load path exists.

---

## Phase 0 — Current-state audit & gap map
**Goal:** verify V0.4 baseline and document exact missing behaviors before changes.

**Steps:**
1. Inventory all skills/attacks in `lib/data/skill_defs.dart` and confirm implementation coverage in `lib/game/` and `lib/render/` (note missing/misaligned behaviors).
2. Inventory enemy roles in `lib/data/enemy_defs.dart`, confirm role behaviors implemented, and note any unclear telegraphs.
3. Record current player/enemy/attack visual scales and hitbox sizes (separate model vs view).
4. Review reward loop: gold/XP/loot drops, level-up rate, and any in-run feedback (damage numbers, VFX intensity).
5. Confirm if any meta currency or progression data exists (likely absent) and document the entry points for adding it.

**Exit criteria:** a short checklist of gaps with file paths and owner systems (combat, render, UI, data, meta).

---

## Phase 1 — Visual scale & readability pass
**Goal:** make player, enemies, and attacks readable at a glance; improve clarity in crowds.

**Steps:**
1. Introduce or confirm a **single render scale** parameter for world visuals (player/enemy/attack sprites) in `lib/render/`.
2. Apply scaling consistently to all render components (player, enemies, projectiles, beams, auras, ground effects).
3. Ensure collision and gameplay radii remain unchanged (visual-only scaling), and verify hitboxes remain accurate.
4. Tune UI scale so HUD/overlays stay legible but do not dominate the screen.

**Exit criteria:** visuals are larger and clearer without changing gameplay balance; all roles/attacks are readable on Windows and mobile.

---

## Phase 2 — Knockback & impact feedback
**Goal:** add satisfying, readable impact without breaking fixed timestep or pooling.

**Steps:**
1. Implement a **knockback system** in `lib/game/` (data-driven per skill/weapon and enemy resistance).
2. Add per-skill knockback parameters in `lib/data/skill_defs.dart` (e.g., force, falloff, duration).
3. Update combat resolution to apply knockback in the fixed-step loop without per-frame allocations.
4. Add lightweight hit feedback (damage numbers / brief flashes) if not already present, ensuring clarity over VFX noise.

**Exit criteria:** hits feel impactful; enemies respond visibly; performance remains stable.

---

## Phase 3 — Skill/attack completeness & correctness
**Goal:** ensure all listed skills behave as described and are selectable with accurate tooltips.

**Steps:**
1. Implement any missing skills or missing behaviors: Fireball, Waterjet, Oil Bombs, Sword Thrust/Cut/Swing/Deflect, Poison Gas, Roots.
2. For each skill, verify tags and delivery type match AGENTS.md (Projectile/Beam/Melee/Aura/Ground).
3. Add clear tooltip metadata in `lib/data/skill_defs.dart` (only relevant stats shown).
4. Validate that animations/telegraphs are visible at the new render scale.

**Exit criteria:** every skill in V0.1 list functions in-game, and tooltips accurately reflect behavior.

---

## Phase 4 — Reward loop & in-run progression feel
**Goal:** make combat and progression feel rewarding without violating “no stat meta-progression.”

**Steps:**
1. Tune XP/level-up pacing for a steady cadence (avoid long droughts).
2. Ensure selection UI highlights tradeoffs and tag synergies (explicit stat deltas + tags).
3. Add small, clear reward feedback on level-up and item/skill acquisition (sound or UI flash).
4. Verify drop/pickup visibility and radius; ensure pickups are easy to parse at scale.

**Exit criteria:** players get frequent, clear rewards; choices feel meaningful and legible.

---

## Phase 5 — Meta currency (earnable) & lateral unlock tree
**Goal:** introduce meta currency and a **lateral progression** unlock tree aligned with AGENTS.md.

**Steps:**
1. Define meta currency type(s) and earn rules (e.g., run completion, milestones, contracts).
2. Add a persistent meta currency wallet (save/load) with minimal UI in `lib/ui/`.
3. Build a **lateral unlock tree** (not raw power) that unlocks:
   - New skills/items/factions/characters.
   - Convenience-only unlocks with caps (e.g., +1 reroll, +1 starting choice).
4. Ensure unlocks are data-driven and stored separately from run stats.
5. Add a meta-progression menu entry from the main menu.

**Exit criteria:** meta currency can be earned and spent; unlocks are lateral and visible in UI.

---

## Phase 6 — Contracts/Heat (opt-in difficulty)
**Goal:** implement opt-in difficulty with proportional rewards and clear mutators.

**Steps:**
1. Define Contract/Heat data model with tagged mutators (e.g., more elites, faster projectiles, extra supports).
2. Add a Contract selection UI before a run (or at start) that clearly shows difficulty and reward multipliers.
3. Apply mutators in `lib/game/` via a centralized difficulty modifier system (avoid hardcoding per enemy).
4. Ensure rewards scale with Heat (meta currency, drops, or run rewards) without raw permanent stats.

**Exit criteria:** Contracts are selectable, change gameplay, and increase rewards proportionally.

---

## Phase 7 — Enemy role clarity & scale tuning
**Goal:** ensure each enemy role reads clearly under the new scale and knockback.

**Steps:**
1. Review enemy sprite recipes and telegraphs; refine silhouettes and role accents.
2. Verify role behavior clarity (spawners, zoners, supporters) with minimal screen noise.
3. Confirm knockback, hit flashes, and telegraphs remain readable in dense waves.

**Exit criteria:** each role is visually distinct and readable in crowds.

---

## Phase 8 — Performance & QA pass
**Goal:** keep fixed timestep, pooling, and ensure no regressions.

**Steps:**
1. Run `dart format .`, `flutter analyze`, `flutter test`.
2. Validate object pooling for new combat/knockback effects and Contracts modifiers.
3. Run the stress scene to ensure frame stability with 500+ enemies and 1000+ projectiles.
4. Check UI overlays for input locks and correct pause behavior.

**Exit criteria:** all checks pass; no regressions in performance or readability.

---

## Implementation ordering (recommended)
1. Phase 0 — Current-state audit & gap map
2. Phase 1 — Visual scale & readability pass
3. Phase 2 — Knockback & impact feedback
4. Phase 3 — Skill/attack completeness & correctness
5. Phase 4 — Reward loop & in-run progression feel
6. Phase 5 — Meta currency & lateral unlock tree
7. Phase 6 — Contracts/Heat (opt-in difficulty)
8. Phase 7 — Enemy role clarity & scale tuning
9. Phase 8 — Performance & QA pass

---

## Guardrails (non-negotiable)
- No stat-based permanent power boosts; meta is **lateral only**.
- Clarity beats complexity; avoid unreadable VFX or overly dense UI.
- Keep fixed timestep, pooling, and data-driven definitions.
- No new TODOs without an associated issue/task reference.
