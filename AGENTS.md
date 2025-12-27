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

#### Tags (V0.1)
**Element / material**
- Fire, Water, Earth, Wind, Poison, Steel, Wood

**Effect / build intent**
- AOE, DOT, Support, Debuff, Mobility

**Delivery / geometry**
- Projectile, Beam, Melee, Aura, Ground

#### Skills (V0.1)
- Fireball — Projectile; Fire; optional splash/ignite later
- Waterjet — Beam; Water; optional slow/push later
- Oil Bombs — Projectile + Ground; Debuff (“Oil”); synergy with Fire
- Sword: Thrust — Melee; Steel; Mobility (short lunge); single-target
- Sword: Cut — Melee; Steel; short arc AOE
- Sword: Swing — Melee; Steel; wide arc AOE (slower)
- Sword: Deflect — Melee; Steel; Support (projectile deflect/parry window)
- Poison Gas — Aura; Poison; AOE; DOT
- Roots — Earth/Wood; Debuff (root/snare); optional patch AOE later

#### Items with tradeoffs (V0.1)
(All are passives. Numbers tuned later; implement as modifiers first.)
- Glass Catalyst: +Damage, -Max HP
- Heavy Plate: +Max HP, -Move Speed
- Feather Boots: +Move Speed, -Defense (or -Max HP)
- Overclocked Trigger: +Attack Speed, -Damage
- Slow Cooker: +DOT damage/duration, -Direct hit damage
- Wide Lens: +AOE size, -Attack Speed
- Sharpening Stone: +Melee damage, -Projectile damage
- Focusing Nozzle: +Beam damage, -AOE size
- Volatile Mixture: +Explosion/Fire damage, +Self-damage from explosions
- Insulated Flask: +Water effectiveness, -Fire damage
- Toxic Filters: +Poison resistance, -Healing received
- Briar Charm: +Root duration/strength, -Move Speed
- Iron Grip: +Knockback strength, -Attack Speed
- Vampiric Seal: +Life steal, -Max HP
- Lucky Coin: +Drops/rewards, -Damage
- Gambler’s Die: +Rerolls, -Choice count
- Reactive Shield: periodic shield, -Cooldown recovery (or -Attack Speed)
- Ritual Candle: +Fire DOT, -Water effectiveness
- Slick Soles: +Mobility effects, -Accuracy (projectile deviation)
- Backpack of Glass: +Pickup radius, -Max HP

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

### 1.6 V0.1 Implementation Scope (what “done” means)
V0.1 aims to be a playable skeleton with at least:
- Player movement + basic survivability loop
- Spawn system (timed waves)
- A minimal skill system (at least Fireball + Sword Cut) with leveling
- Basic item selection UI (tradeoff items can be zero-number tuned but functional)
- At least 3 enemy roles (Chaser, Ranged, Spawner) with clear visuals
- A performance “stress scene” (see Technical section) for early validation

---

## 2) Technical & infrastructure information

### 2.1 Tech stack
- **Flutter (stable channel)**
- **Flame** for the game loop, rendering, and components
- Target platforms (priority order for V0.1):
  1) Android (primary dev target)
  2) Windows desktop (debug convenience)
  3) iOS/macOS/Linux later
  4) Web is optional and should not dictate early design unless a task explicitly targets it

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

### 2.3 Suggested repository structure (agents should follow)
- `lib/game/` — simulation + systems (movement, combat, spawns, tags, items)
- `lib/render/` — Flame components and render adapters
- `lib/ui/` — menus, selection screens, overlays, HUD
- `lib/data/` — static definitions (skills/items/enemies as data)
- `assets/` — art/audio (may be placeholders in V0.1)
- `test/` — unit tests for systems, plus lightweight integration tests

Agents may propose a slightly different structure if they also migrate existing code consistently.

### 2.4 Data-driven content
V0.1 content should be definable as data objects, not hard-coded behavior:
- `SkillDef`, `ItemDef`, `EnemyDef` with:
  - `id`, `name`, `tags`, `rarity/weight`, `params`
- Tag system is a first-class concept:
  - Implement tags as enums or interned strings, but keep them consistent.

### 2.5 Performance validation: “Stress Scene” requirement
Add a dedicated debug scene to spawn large counts and measure FPS/frame time.
Baseline target (adjustable later):
- 60 FPS on a mid-range phone with:
  - 500+ enemies, 1000+ projectiles in bursts
- The stress scene must be runnable via a single toggle or debug route.

### 2.6 Testing & quality gates
Before opening a PR:
- `flutter analyze` must pass
- `flutter test` must pass
- `dart format .` applied to touched files
- No new TODOs without an associated issue/task reference

If a change impacts performance-sensitive code, include:
- A short note on allocations avoided / pooling used
- Any benchmark notes from the stress scene (even qualitative)

### 2.7 Collaboration rules for cloud agents
- Keep PRs small and focused (one feature/system per PR).
- Avoid “drive-by refactors” unless explicitly requested.
- If changing data formats or core APIs, update:
  - Definitions in `lib/data/`
  - Any loader/registry code
  - Tests
- Prefer additive changes; avoid breaking changes unless required for the task.

### 2.8 Build/run commands (expected)
- Run: `flutter run`
- Tests: `flutter test`
- Lint: `flutter analyze`
- Format: `dart format .`

(If platform-specific steps are needed, document them in `README.md` or `docs/`.)

### 2.9 Licensing notes (for agent awareness)
- Code license will be selected later (MIT/Apache/GPL decision deferred).
- Assets are intended to be **proprietary** (All Rights Reserved) even if code is open.
  - Agents should not import third-party assets without clear license compatibility
  - If third-party assets are necessary for placeholders, prefer permissive CC0 and document sources

---

## Agent task selection guidance (what to build first)
Preferred early tasks that unblock everything:
1) Minimal game loop + player movement + camera + HUD overlay
2) Spawn system (waves) + enemy chaser
3) Skill casting system + one projectile skill (Fireball)
4) Damage, HP, death, despawn, pooling
5) Level-up & selection UI (skills/items)
6) Stress scene instrumentation

Avoid early tasks until core loop exists:
- Large content expansion
- Heat/Contracts system
- Meta unlock trees
- Steam/store integrations
- Complex VFX/particles

---
