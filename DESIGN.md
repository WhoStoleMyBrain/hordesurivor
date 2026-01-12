# HordeSurvivor Design Document

## 1) Project summary
HordeSurvivor is a pixel-style horde survivor centered on readable combat, distinct enemy roles, and build identity through tags and tradeoffs rather than permanent power creep. The current codebase targets desktop platforms (Windows/macOS/Linux/Web) with mobile expansion in mind through scalable UI and touch-ready input handling.

## 2) Core design pillars (implemented guardrails)
- **No stat meta-progression:** permanent “+HP/+DMG” unlocks are avoided in favor of lateral options.
- **Lateral metaprogression:** unlocks add skills/items/choices or convenience-only bonuses with caps.
- **Opt-in difficulty:** Contracts/Heat mutate gameplay and scale rewards.
- **Clarity over complexity:** attacks and roles are telegraphed and readable in crowds.
- **Build identity via tags + tradeoffs:** synergy uses tags and clear upsides/downsides.

## 3) Platform & input strategy
- **Current target:** desktop platforms (Windows/macOS/Linux/Web) for early iteration.
- **Mobile-ready design:**
  - Touch-friendly input pathways exist (pan gestures) alongside keyboard input.
  - A virtual stick overlay renders at touch origin during pan input to show dead zone
    and max-radius travel for mobile steering.
  - UI overlays use `SafeArea` and text scaling to remain readable on smaller screens.
  - Render scaling is decoupled from gameplay hitboxes so visuals can be tuned for multiple screen sizes.

## 4) High-level architecture
### 4.1 Tech stack
- **Flutter (stable) + Flame** for the game loop, rendering, and components.
- **Data-driven content** stored in `lib/data/` and validated at startup.

### 4.2 Model-view separation
- **Simulation/data model:** `lib/game/` hosts stateful systems and deterministic logic.
- **Rendering layer:** `lib/render/` provides Flame components and visual adapters.
- **UI overlays:** `lib/ui/` supplies menus, HUD, and selection screens that observe game state.

### 4.3 Fixed timestep simulation
- Gameplay runs on a fixed timestep (1/60s) with frame accumulation to ensure deterministic behavior across platforms.

### 4.4 Performance-first conventions
- **Object pools** exist for enemies, projectiles, effects, pickups, damage numbers, and spark effects to avoid per-frame allocations.
- **Spatial grid** is used for proximity queries and area-of-effect collisions.

## 5) Game flow & run lifecycle
### 5.1 Flow states
The game transitions between well-defined states:
- **Start** → **Home Base** → **Area Select** → **Stage** → **Death**

### 5.2 Run summary & scoring
A run summary aggregates time alive, enemies defeated, XP earned, damage taken, and the meta currency payout (with Contract bonuses). It also captures a build recap (skills, items, upgrades) and synergy trigger counts for end-of-run reflection.

## 6) Data-driven content design
### 6.1 Tags (first-class build identity)
Tags are implemented as enums for elements, effects, and delivery methods. Skills, items, upgrades, and status effects are tagged to drive synergy and UI presentation.

### 6.2 Definitions and registries
- **Skills:** `SkillDef` list with tags, descriptions, and knockback/deflect parameters.
- **Items:** `ItemDef` list with stat modifiers and optional tag alignment.
- **Skill upgrades:** `SkillUpgradeDef` list, tied to specific skills with modifiers.
- **Enemies:** `EnemyDef` list with faction, role, stats, and spawn parameters.
- **Areas:** `AreaDef` list defining stage duration and section tuning.
- **Contracts:** `ContractDef` list that modifies difficulty and rewards.
- **Meta unlocks:** `MetaUnlockDef` list for lateral, convenience-only bonuses.

### 6.3 Validation
A startup validation pass ensures IDs are unique and definitions are consistent (e.g., non-empty tags, positive weights, valid references).

## 7) Combat & gameplay systems
### 7.1 Player model
- **Player stats** are driven by a `StatSheet` with modifiers from items, upgrades, and meta unlocks.
- **Movement** supports keyboard input and pan-based directional input.

### 7.2 Skills & casting
- Skills are executed on individual cooldowns via the `SkillSystem`.
- Skill behavior is implemented as data-driven actions (projectile spawn, beam effects, melee arcs, auras).

### 7.3 Effects & status interactions
- **Ground/beam effects** apply area damage and status effects (slow, root, oil-soak, ignite).
- **Status effects** are represented by definitions for clarity and UI tagging.
- **Synergy hooks** are defined in `lib/data/synergy_defs.dart` and drive Oil + Fire → Ignite behavior, with selection UI hints and a pooled on-hit text pulse to reinforce synergy triggers without new per-hit allocations.

### 7.4 Damage & knockback
- Skills can apply knockback based on per-skill parameters and stat scaling.
- Knockback is applied during combat resolution without per-frame allocations.

## 8) Enemies, factions, and roles
### 8.1 Factions & roles
Enemy definitions specify **factions** (Demons/Angels) and **roles** (chaser, ranged, spawner, etc.). Role identity is reinforced visually (e.g., role badges) and behaviorally in the enemy system.

### 8.2 Variants
Enemy variants (base/champion) scale stats via multipliers, with tinting for readability.

## 9) Stage progression & spawning
### 9.1 Area structure
Areas are built from **timed sections** with their own role weights, enemy weights, and threat tiers. Areas also define **run milestones** (time-based beats) that trigger bonus XP and burst wave pressure spikes to reinforce pacing within a run.

### 9.2 Spawn director
A spawn director blends section weights over time and scales enemy tiers based on player level for consistent pressure.

### 9.3 Spawner system
Spawner waves are resolved into weighted picks across roles/enemies/variants, respecting champion caps and mutators.

### 9.4 Finale pacing
Areas can define a **stage finale** that starts after the timer completes, triggers a final burst wave, and holds the run open briefly before ending. This keeps the end-of-run moment readable without introducing permanent boss progression yet.

## 10) Progression systems
### 10.1 XP & leveling
- XP is earned during combat and processed by `ExperienceSystem`.
- Level-up triggers a selection flow that offers skills, skill upgrades, and items.

### 10.2 Selection & rerolls
The selection system supports rerolls and dynamic choice counts, influenced by stats and meta unlocks.

### 10.3 Items & upgrades
Items and upgrades apply explicit stat modifiers with tradeoffs. These are surfaced in the selection UI for clarity.

## 11) Meta progression (lateral only)
### 11.1 Meta currency
- **Meta Shards** are earned based on run time, XP, and completion, then multiplied by active Contracts.
- The wallet is persisted via shared preferences.

### 11.2 Meta unlocks
- Unlocks are convenience-only (e.g., extra reroll, extra choice).
- Unlocks are stored persistently and applied at run start as stat modifiers.

## 12) Difficulty system (Contracts/Heat)
- Contracts define gameplay mutators (projectile speed, move speed, elite/support weights).
- Heat is displayed in-run, and rewards scale with heat multipliers.
- Commanding Presence contract pairs elite and support weight boosts to emphasize coordinated enemy pressure.

## 13) Rendering & visual pipeline
### 13.1 Sprite generation pipeline
- Sprites are generated at runtime from data-driven recipes in `assets/sprites/recipes.json`.
- Generated sprites are cached in-memory for use by render components.

### 13.2 Render scale
Visual scaling is controlled via `RenderScale.worldScale` and is explicitly decoupled from gameplay hitboxes.

### 13.3 Effects & readability
Render components emphasize clarity (badges, telegraphs, readable HUD). Optional high-contrast telegraphs are supported.
Role telegraphs apply modest opacity multipliers for spawners, zoners, support roles, and elites to reinforce role readability without overwhelming other cues.
Role telegraphs also use per-role stroke widths so spawners/zoners/supporters/elites read more clearly during dense waves.

## 14) UI & overlays
- Overlays (HUD, selection, start, options, compendium, meta unlocks, area select, death) are attached to the Flame game instance.
- UI text scaling is adjustable and persisted, supporting accessibility and future mobile sizing.
- A first-run hints overlay appears during the first stage and is dismissible to reinforce core controls and tradeoffs.
- The HUD primary cluster groups HP/XP with Contracts heat to keep difficulty context visible without scanning the lower stage panel.

## 15) Performance & validation
### 15.1 Stress scene
A dedicated **stress scene** is available via a build flag to validate performance at high enemy/projectile counts.

### 15.2 Runtime checks
Data validation runs at startup to ensure definitions remain consistent as content grows.

## 16) Save & persistence
- Shared preferences are used for UI scale settings, meta currency wallet, unlock persistence, and a tutorial-seen flag for onboarding hints.

## 17) Asset & licensing constraints
- Code is Apache-2.0; game assets are All Rights Reserved.
- Third-party assets should be avoided unless license compatibility is explicit.

---

## 18) Placeholders for future design decisions
These categories are expected to be defined later and have no implementation yet:
- **Audio & music pipeline** (sound design, mixing, and asset workflow).
- **Mobile-specific controls** (aim assist, haptics, layout refinements).
- **Accessibility & UX options** (colorblind modes, input remapping, pause behavior on focus loss).
- **Meta unlock tree layout** (visual structure once the unlock catalog grows).
- **In-depth enemy telegraph language** (silhouette standards, VFX cadence guidelines).
