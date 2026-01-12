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
- ✅ Phase 1 (Visual scale & readability pass): persisted the UI text scale preference via shared preferences so Options changes survive restarts. Decision: clamp stored values to the same slider min/max for safety. Follow-up: consider folding this into a broader settings save/load bundle when more settings are added.
- ✅ Phase 1 (Visual scale & readability pass): aligned pickup spark visuals with `RenderScale.worldScale` to keep reward feedback consistent with world scaling. Decision: scale the component transform instead of multiplying radii. Follow-up: revisit spark stroke width once VFX/audio polish begins.
- ✅ Phase 4 (Reward loop): applied the drop-rate stat to the meta shard reward multiplier so Lucky Coin influences run rewards. Decision: compute the drop bonus at run end so late picks still count. Follow-up: add in-run pickup drops when a dedicated pickup system is introduced.
- ✅ Phase 6 (Contracts/Heat): added a Relentless Advance contract that boosts enemy move speed and wired contract move-speed multipliers into the enemy and spawner systems. Decision: keep it as a global mutator alongside the existing contract set. Follow-up: tune the speed multiplier once playtesting verifies dodge windows.
- ✅ Phase 6 (Contracts/Heat): added a Coordinated Assault contract to raise support spawn weights alongside faster enemy projectiles. Decision: keep it as a higher-heat combo contract in the global list for now. Follow-up: add area-specific contract pools once additional mutators are defined.
- ✅ Phase 4 (Reward loop): tuned early XP pacing by lowering base XP and growth in the experience curve. Decision: use base 18 / growth 8 for a steadier early cadence. Follow-up: revisit once pickup drops and level cadence playtests are available.
- ✅ Phase 0 (Audit/gap map): documented current skill coverage, enemy role behaviors, scale/hitbox values, reward loop state, and meta entry points in the Phase 0 section. Decision: keep the audit notes inline in PLAN.md for now. Follow-up: expand the audit if any new systems land outside the current scope.
- ✅ Phase 3 (Skill/attack completeness): added a Sword Thrust lunge impulse based on aim direction and player move speed to deliver the intended mobility tag. Decision: keep the impulse short (0.12s) with a mild speed bump for now. Follow-up: tune impulse duration/speed once movement playtests validate dodge windows.
- ✅ Phase 3 (Skill/attack completeness): added a short Sword Deflect parry window that deflects enemy projectiles within a radius after the cast. Decision: set the parry window to 0.18s with a 55px base radius scaled by AOE. Follow-up: tune deflect window timing/radius once projectile pressure is playtested.
- ✅ Phase 4 (Reward loop): added in-run XP pickups that drop on enemy defeat, scale collection radius with the pickup stat, and auto-despawn after a short lifetime. Decision: keep pickups as simple XP orbs with a base 32px pickup radius for now. Follow-up: add a pickup sparkle or sound cue once audio/VFX passes begin.
- ✅ Phase 4 (Reward loop): added a lightweight pickup spark ring on XP pickup collection to reinforce reward feedback without extra VFX noise. Decision: keep it render-only and pooled. Follow-up: consider layering a soft sound cue once audio assets exist.
- ✅ Phase 6 (Contracts/Heat): added a Hardened Onslaught contract that boosts elite odds and enemy move speed. Decision: keep it as another global contract alongside the initial set. Follow-up: add area-specific contract pools once additional mutators are defined.
- ✅ Phase 6 (Contracts/Heat): added a Crossfire Rush contract that stacks enemy projectile and move-speed pressure. Decision: keep it as a global option to test combined dodge pressure. Follow-up: evaluate heat/reward tuning once area-specific pools land.
- ✅ Phase 6 (Contracts/Heat): added a Siege Formation contract to push faster support-heavy waves. Decision: keep it global with existing Contracts for now. Follow-up: tune support weight once area-specific contract pools exist.
- ✅ Phase 6 (Contracts/Heat): added a Commanding Presence contract that boosts champion and support presence together. Decision: keep it as a mid-heat global option to reinforce coordination pressure. Follow-up: tune elite/support multipliers once area-specific contract pools land.
- ✅ Phase 6 (Contracts/Heat): added a Vanguard Volley contract that pairs faster enemy projectiles with higher champion weight for tighter front-line pressure. Decision: keep it in the Ashen Outskirts contract pool to amplify demon-side barrage pressure. Follow-up: consider a halo-area counterpart once more projectile mutators exist.
- ✅ Phase 6 (Contracts/Heat): added a Radiant Barrage contract to speed up angelic projectiles in Halo Breach. Decision: keep it as a low-heat option in the Halo Breach pool to highlight volley pressure. Follow-up: tune projectile speed once angel ranged densities increase.
- ✅ Phase 7 (Enemy role clarity & scale tuning): boosted support/zoner aura opacity and added a spawner charge rune to make role telegraphs easier to read in dense waves. Decision: keep the rune tied to spawn cooldown progress to avoid extra noise. Follow-up: revisit sprite silhouettes/telegraph styling once new sprite recipes are available.
- ✅ Phase 1 (Visual scale & readability pass): applied `RenderScale` to the area portal component so portal visuals scale with world scale. Decision: scale the portal label alongside the ring for consistent readability. Follow-up: confirm label legibility on smaller screens once UI scale playtests resume.
- ✅ Phase A (Onboarding & first-run clarity): added a first-run hints overlay that appears on the first stage and persists a tutorial-seen flag. Decision: keep the overlay compact with four core reminders and a single dismiss action. Follow-up: add iconography or tag badges to the hints once onboarding art direction is defined.
- ✅ Phase A (Onboarding & first-run clarity): moved Contracts heat readout into the primary HUD cluster near HP/XP so difficulty context is visible at a glance. Decision: keep the heat line close to core stats to reduce eye travel. Follow-up: add a small heat icon once HUD iconography pass begins.
- ✅ Phase A (Onboarding & first-run clarity): tuned early-stage enemy variety to introduce chasers first, then ranged, then support/spawner pressure in later sections. Decision: keep section notes updated to match the new ramp. Follow-up: revisit weights after playtesting the early minutes.
- ✅ Phase A (Onboarding & first-run clarity): added status-effect badges in the reward selection cards, driven by per-skill status metadata. Decision: reuse existing tag badge styling for status icons to avoid UI clutter. Follow-up: consider status badges for items/upgrades once they apply explicit status effects.
- ✅ Phase B (Build identity & tag synergy reinforcement): added data-driven synergy definitions for Oil + Fire → Ignite, surfaced synergy hints in the selection UI, and added an on-hit synergy text pulse when ignition triggers. Decision: reuse the pooled damage number component for the synergy cue to avoid new allocations. Follow-up: add a lightweight icon/pulse in render and expand the synergy catalog beyond Ignite.
- ✅ Phase B (Build identity & tag synergy reinforcement): added a Roots + Fire → Kindling synergy so rooted targets ignite when hit by fire skills, keeping the payoff data-driven and status-gated. Decision: reuse the existing ignite status effect for Kindling to avoid new DOT tuning in V0.5. Follow-up: consider a unique burn tint or icon pulse once the synergy catalog grows.
- ✅ Phase C (Run structure & end-of-run identity): added data-driven run milestones per area that grant bonus XP and trigger burst waves for mid-run and final pressure spikes. Decision: keep milestone rewards as XP plus a burst wave to reinforce pacing without adding new end-of-run entities yet. Follow-up: add a dedicated finale encounter and expand milestone effects once boss-style behavior lands.
- ✅ Phase C (Run structure & end-of-run identity): expanded the run summary with a build recap (skills/items/upgrades) and a synergy trigger count on the death screen. Decision: show recap as compact chips below core stats to keep the summary readable. Follow-up: revisit layout density once a dedicated run recap screen exists.
- ✅ Phase C (Run structure & end-of-run identity): added a finale hold window that triggers a final burst wave at stage completion before ending the run. Decision: drive finale timing and burst size from per-area data so pacing stays tuneable. Follow-up: consider adding a dedicated elite-style finale encounter once bespoke boss behaviors land.
- ✅ Phase D (Enemy role language & telegraph standards): added per-role telegraph opacity multipliers to emphasize spawners, zoners, support roles, and elites. Decision: keep multipliers modest (1.15–1.2) to avoid overpowering other signals. Follow-up: tune multipliers after stress-scene readability checks.
- ✅ Phase D (Enemy role language & telegraph standards): added per-role telegraph stroke widths so key roles (spawner/zoner/support/elite) read at a glance in dense waves. Decision: keep the width deltas subtle (2.2–3.0) to avoid overpowering other telegraphs. Follow-up: revisit widths alongside silhouette updates.
- ✅ Phase E (Platform readiness & QA): added a virtual stick overlay that renders at touch origin during pan input, showing dead zone and max-radius travel for mobile steering. Decision: show the overlay only while actively panning to avoid HUD clutter. Follow-up: consider an optional idle hint or left-hand lock-on toggle for mobile.
- ✅ Phase C (Run structure & end-of-run identity): expanded the run summary recap to list per-synergy trigger counts alongside the existing total synergy trigger stat. Decision: list synergies in definition order with an “×count” suffix to keep the recap compact. Follow-up: revisit ordering once the synergy catalog grows.
- ✅ Phase 6 (Contracts/Heat): added per-area contract pools so the area select screen focuses mutators by location. Decision: keep pools small and thematic per area for now. Follow-up: expand the catalog and consider area-specific mutators once more contracts exist.
- ✅ Phase 1 (Visual scale & readability pass): scaled combat damage numbers with `RenderScale` so floating damage text stays readable at larger world scales. Decision: keep TextPaint font sizes as-is and rely on component scaling. Follow-up: revisit font size tuning if damage text crowds the HUD at higher scales.

---

## Feature status (verified vs pending)
This section verifies what is already implemented in the codebase and lists the remaining, AGENTS.md-aligned features that are still open for work.

### ✅ Verified completed features
- Knockback system with per-skill knockback parameters applied during combat resolution.
- HUD-level feedback pulses for level-up and reward selections.
- Poison Gas implemented as a follow-player DOT aura matching its skill description.
- Selection UI shows explicit stat modifier deltas for item and skill upgrade choices.
- Meta Shards: earn rules, run-summary display, persistent wallet, and UI badges (start/home/death).
- Meta Unlocks screen with two convenience-only unlocks, spending flow, and run-start modifiers.
- Contracts/Heat: data definitions, area selection UI, gameplay mutators (elite/support weights, projectile/move speed), reward scaling, and HUD heat indicator.
- Contracts/Heat: expanded catalog with the Commanding Presence contract to mix elite and support pressure.
- Contracts/Heat: added the Vanguard Volley contract to boost projectile speed and champion presence in the Ashen Outskirts pool.
- Contracts/Heat: added the Radiant Barrage contract to speed up angelic volleys in Halo Breach.
- UI text scale system: MediaQuery text scaler, Options slider, and persisted preference.
- Waterjet/Sword Thrust/Deflect tooltips aligned with current behavior.
- Enemy role badges for non-core roles to reinforce readability.
- Drop-rate stat applied to meta shard reward multiplier (Lucky Coin interaction).
- Relentless Advance contract boosts enemy move speed via contract modifiers.
- RenderScale applied across render components (player/enemy/projectile/effects) for consistent visual scaling.
- Tag synergy catalog includes Oil + Fire → Ignite and Roots + Fire → Kindling definitions with selection UI hints.

### ⏳ Not yet implemented (aligned with AGENTS.md)
- Visual scale & readability pass: confirm/tune world render scaling across all attacks and telegraphs, and verify collision radii remain unchanged on both desktop and mobile targets.
- Knockback/impact tuning: playtest-based knockback value tuning and optional hit-flash intensity adjustments.
- Meta progression expansion: grow the lateral unlock catalog (skills/items/factions/characters), add a tree-style layout, and keep unlocks strictly non-power.
- Contracts/Heat expansion: broaden the contract catalog further, add area-specific mutators, and polish in-run presentation.
- Enemy role clarity pass: refine sprite recipes and silhouettes for spawners/zoners/supporters in dense waves (telegraph opacity/runes updated).
- Performance & QA pass: run format/analyze/test gates and stress-scene validation with pooled effects.

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

**Audit notes (completed)**
- Skills: all V0.1 skills are defined in `lib/data/skill_defs.dart` and dispatched in `SkillSystem` (`lib/game/skill_system.dart`). Missing behavior gaps remain for Sword Thrust mobility impulse and a Deflect parry window timing (not yet implemented). Oil Bombs create an impact ground effect with oil/slow; Fireball ignites oiled targets as expected.
- Enemies: all roles defined in `lib/data/enemy_defs.dart` have core behaviors in `lib/game/enemy_system.dart` (ranged, spawner, disruptor, zoner, exploder, support healer/buffer, pattern, elite). Telegraph arcs and role auras/zones render in `lib/render/enemy_component.dart`. Role-specific bespoke telegraphs for elite dash timing and exploder detonation remain minimal (only cooldown arc).
- Visual scale & hitboxes: `RenderScale.worldScale` is 1.2 in `lib/render/render_scale.dart` for all render components. Gameplay radii are fixed in `lib/game/horde_game.dart` (`_playerRadius = 16`, `_enemyRadius = 14`, `_portalRadius = 26`). Projectile/effect radii are per-skill in `lib/game/skill_system.dart` (e.g., Fireball radius 4, Oil Bombs radius 6 + ground radius 46*AOE, Poison Gas radius 70*AOE, Roots radius 54*AOE). No collision changes tied to render scale.
- Reward loop: XP is awarded on enemy death and leveled through `lib/game/experience_system.dart`; level-up UI and HUD pulses are present in overlays, but there is no in-run pickup/drop system (only stat modifiers exist for pickup radius).
- Meta progression entry points: meta shards wallet and unlocks are stored in `lib/game/meta_currency_wallet.dart` and `lib/game/meta_unlocks.dart`, with UI badges and screens in `lib/ui/`. No additional lateral unlock catalog yet.

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

---

# V0.5 Proposal — Toward a shippable “playable loop”

V0.5 focuses on turning the current V0.4 foundation into a **cohesive, repeatable, shippable loop**: an end-to-end run that starts cleanly, teaches the player, delivers readable combat and build identity, and ends with clear outcomes. The goal is to make the game feel like a complete “vertical slice” of the final product while keeping all V0.1 design pillars intact (no stat meta-progression, lateral unlocks, opt-in difficulty, clarity-first combat).

---

## V0.5 Objectives (summary)
- **First-play experience polish:** tutorialized onboarding flow, clearer HUD, and readable early-game pressure.
- **Build identity in-run:** deepen tag-based synergies (without hard evolutions) and surface them in UI/feedback.
- **Run structure & pacing:** defined milestones, a mid-run “pressure spike,” and a readable end-of-run moment.
- **Enemy role language:** role telegraph and silhouette standards applied consistently.
- **Vertical slice quality:** runnable, testable, and stable on desktop and Android targets.

---

## Phase A — Onboarding & first-run clarity
**Goal:** make the first 3–5 minutes readable and instructive without tutorials that break flow.

**Implementation details:**
1. **First-run hints overlay** in `lib/ui/`:
   - Lightweight, dismissible callouts for movement, auto-aiming skills, leveling, and item tradeoffs.
   - Only show on the first run; persist a “tutorial seen” flag in shared preferences.
2. **HUD clarity adjustments** in `lib/ui/`:
   - Move or group critical readouts (HP, XP, level, heat) into a consistent “primary cluster.”
   - Add iconography for tags/statuses in the selection overlay (skill and item entries).
3. **Early-game pacing pass** in `lib/game/experience_system.dart` and `lib/game/spawn_system.dart`:
   - Tune the first 2 minutes to avoid overwhelming density (clear enemy roles).
   - Use a gentle enemy variety curve: chaser → ranged → spawner.

**Exit criteria:** first-time players can finish a run without external instruction, and the HUD reads clearly at default scaling.

---

## Phase B — Build identity & tag synergy reinforcement
**Goal:** make tag synergies feel like deliberate player-driven build identity.

**Implementation details:**
1. **Tag synergy system** in `lib/game/`:
   - Add data-driven synergy hooks (e.g., Oil + Fire triggers Ignite burst/DOT).
   - Keep synergies as additive effects, not hard skill evolutions.
2. **Synergy UI feedback** in `lib/ui/` and `lib/render/`:
   - Add a subtle, consistent on-hit feedback (icon or color pulse) when a synergy triggers.
   - Surface synergy opportunities in tooltips and selection UI (e.g., “Oil + Fire = Ignite”).
3. **Definition data pass** in `lib/data/`:
   - Add synergy metadata to `SkillDef`/`StatusDef` or a dedicated synergy registry.
   - Ensure all tags used in synergies exist and are validated at startup.

**Exit criteria:** players can intentionally assemble a build and see/feel synergy payoffs in combat.

---

## Phase C — Run structure & end-of-run identity
**Goal:** give each run a clear arc with a legible “final moment.”

**Implementation details:**
1. **Run milestones** in `lib/game/`:
   - Add timed milestones (e.g., 3 min and 6 min) that push pressure and reward.
   - Keep milestones data-driven in `AreaDef`.
2. **End-of-run event** in `lib/game/` and `lib/render/`:
   - Add a readable “final wave” or “boss-style” elite encounter (no new faction yet).
   - Ensure telegraphs and role clarity match V0.4 readability standards.
3. **Summary and rewards polish** in `lib/ui/`:
   - Improve run summary with “build recap” (skills/tags/items chosen).
   - Show synergy activations count (if implemented) to reinforce build identity.

**Exit criteria:** runs have a clear beginning/middle/end, and the end feels like a deliberate finale.

---

## Phase D — Enemy role language & telegraph standards
**Goal:** make enemy roles and telegraphs unmistakable in dense crowds.

**Implementation details:**
1. **Role telegraph guidelines** in `lib/render/`:
   - Define color/shape conventions per role (support, zoner, spawner, elite).
   - Apply consistent opacity and timing to telegraphs.
2. **Silhouette pass** in sprite recipes:
   - Add exaggerated silhouette differences for key roles (spawners/zoners/elite).
3. **Readability validation**:
   - Test in stress scene and normal run to ensure telegraph visibility at scale.

**Exit criteria:** all enemy roles are visually distinguishable in dense waves.

---

## Phase E — Platform readiness & QA
**Goal:** ensure V0.5 can be reliably played on desktop and Android.

**Implementation details:**
1. **Input polish**:
   - Validate keyboard + touch input parity.
   - Add a basic virtual stick overlay for mobile (if not already present).
2. **Performance pass**:
   - Run the stress scene with updated telegraphs/synergy effects.
   - Confirm pooling and no per-frame allocations in new systems.
3. **Quality gates**:
   - Run `dart format .`, `flutter analyze`, and `flutter test`.
   - Verify no new TODOs without an issue reference.

**Exit criteria:** V0.5 builds, runs, and passes tests on desktop, and Android input feels responsive.

---

## V0.5 Exit Criteria (overall)
- A complete, readable run loop with clear onboarding and a distinct end-of-run moment.
- Tag synergies are data-driven, visible, and support build identity without hard evolutions.
- Enemy role telegraphs are consistent and readable in dense combat.
- Desktop and Android runs are playable with stable performance and passing tests.
