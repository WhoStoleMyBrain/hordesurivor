# V0.4 Plan — HordeSurvivor (V0.3 wrap-up retained)

This plan moves the project from V0.3 into V0.4 with a focus on **readability, flow fixes, and gameplay clarity**. It addresses V0.3 issues, improves sprite and scale readability (especially on Windows), and rounds out the skill/item UX. All work stays aligned with AGENTS.md: fixed timestep, pooling, data-driven content, and clarity over complexity.

---

## V0.4 Objectives (summary)
- **Readability pass:** shrink debug/on-screen text and improve visual scale on Windows with a single configurable size parameter.
- **Flow fix:** canceling run start after portal entry should not immediately re-trigger the portal.
- **Visual clarity:** improve enemy and player/attack sprites for role readability.
- **Selection UX upgrades:** rerolls, full stat-change descriptions, and weapon/tooltips that explain behavior clearly.
- **Stats screen:** a pause/frozen overlay listing current stats, items, and skills with hoverable tooltips.
- **Sanity check:** project-wide QA pass to ensure V0.4 is stable and readable.

---

## V0.4 Phase 0 — Baseline review & issue inventory
**Goal:** confirm current V0.3 behavior, list exact problem surfaces, and avoid hidden scope creep.

**Implementation notes:**
- Document current debug text sizing locations and UI typography usage in `lib/ui/` overlays and HUD.
- Identify portal entry/cancel flow state transitions and any proximity-triggered re-entry loops in `lib/game/` or `lib/render/`.
- Snapshot current enemy/player/attack scales on Windows (desktop builds).
- Gather list of current skills/items/weapon definitions and their stat coverage in `lib/data/`.

**Exit criteria:** clear list of concrete V0.4 tasks mapped to file locations and systems.

---

## V0.4 Phase 1 — Text readability & UI scale hygiene
**Goal:** reduce oversized debug/on-screen text for both mobile and Windows; keep core HUD readable.

**Implementation notes:**
- Identify the debug overlay text widgets and apply a reduced base font size.
- Ensure HUD and menu typography use a shared scale or theme value (avoid per-widget hard-coded font sizes).
- Add a single UI scale constant in `lib/ui/` (or a shared settings config) so debug/UI text scales together.

**Success checks:**
- Debug overlays no longer dominate screen space on Windows.
- Core HUD elements remain legible without crowding.

---

## V0.4 Phase 2 — Portal cancel re-entry fix
**Goal:** exiting/canceling area selection after entering the portal must not immediately re-trigger portal entry.

**Implementation notes:**
- Add a portal cooldown/lockout timer or a flow-state gate so the portal cannot trigger while the area select overlay is visible or within a short grace window after cancel.
- Ensure the fixed-step proximity checks do not fire when the flow is not in the home base state.
- Add a small debug log or visual cue to confirm lockout behavior (only if it does not add new TODOs).

**Success checks:**
- Canceling area selection returns to home base without re-opening the selection dialog.
- Player can re-enter the portal intentionally after a short delay or a movement step.

---

## V0.4 Phase 3 — Global gameplay scale parameter
**Goal:** increase player, enemies, and attack visual size on Windows, controlled by a single parameter.

**Implementation notes:**
- Introduce a `worldScale` or `renderScale` configuration in `lib/render/` (and/or `lib/game/` if simulation sizes depend on it).
- Apply the scale to:
  - Player sprite/visual component size.
  - Enemy sprite/visual component size.
  - Attack visuals (projectiles, beams, auras, ground effects).
- Keep collision/logic sizes consistent and ensure hitboxes remain accurate; avoid per-entity allocations.

**Success checks:**
- Windows builds show larger player/enemy/attack visuals without breaking collisions.
- Scaling can be adjusted by a single parameter for easy tuning.

---

## V0.4 Phase 4 — Enemy sprite readability improvements
**Goal:** improve enemy silhouettes and clarity for all existing roles.

**Implementation notes:**
- Review `lib/data/enemy_defs.dart` and current sprite recipes in `lib/render/`.
- Add or refine sprite recipes with clearer silhouettes and role-based accents (color or shape).
- Ensure role telegraphs remain visible at the new scale.

**Success checks:**
- Enemies are distinguishable at a glance in crowds.
- Telegraphs and ring effects remain readable without clutter.

---

## V0.4 Phase 5 — Rerolls, item descriptions, and stat screen
**Goal:** improve selection agency and build clarity during runs.

**Implementation notes:**
- Add a reroll count to the player run state (limited; no permanent meta bonuses).
- Selection UI should display the remaining rerolls and allow rerolling current choices.
- Item descriptions should list **explicit stat changes** (e.g., “+10% AOE size, -10% attack speed”).
- Add a **Stats Screen overlay** in `lib/ui/`:
  - Shows current stats, items obtained, and skills obtained.
  - Each entry is hoverable (desktop) with tooltip details; mobile can use tap/long-press later.
  - Freeze the game simulation while this overlay is open.

**Success checks:**
- Players can reroll selection choices a limited number of times.
- Items and stats list accurate numeric changes.
- Stats screen displays and freezes gameplay when open.

---

## V0.4 Phase 6 — Skill & weapon clarity pass
**Goal:** all existing weapons/skills are implemented and selection tooltips explain their behavior and stats.

**Implementation notes:**
- Ensure every V0.3/V0.1 weapon skill is implemented (Fireball, Waterjet, Oil Bombs, Sword variants, Poison Gas, Roots).
- Tooltips should show only relevant stats (damage, AOE, attack speed, DOT, beam width, etc.).
- If a stat is not used (e.g., a utility-only skill), omit it from the description.
- Update `lib/data/skill_defs.dart` to include clear summary strings and stat metadata for UI.

**Success checks:**
- Skill selection shows clear, concise descriptions with relevant stats only.
- All listed weapons match their described behavior in-game.

---

## V0.4 Phase 7 — Sanity check & QA pass
**Goal:** verify stability, readability, and correctness across V0.4 changes.

**Implementation notes:**
- Run `dart format .`, `flutter analyze`, and `flutter test`.
- Validate that new UI overlays do not create input leaks or stuck movement.
- Ensure pooling remains intact for any new visual components.
- Add a quick stress-scene check for scale/readability.

**Exit criteria:**
- V0.4 changes are stable with no regressions in flow or readability.

---

## Implementation ordering (recommended)
1. **Baseline review & issue inventory** (Phase 0).
2. **Text readability & UI scale hygiene** (Phase 1).
3. **Portal cancel re-entry fix** (Phase 2).
4. **Global gameplay scale parameter** (Phase 3).
5. **Enemy sprite readability improvements** (Phase 4).
6. **Rerolls, item descriptions, and stats screen** (Phase 5).
7. **Skill & weapon clarity pass** (Phase 6).
8. **Sanity check & QA pass** (Phase 7).

---

## V0.4 Guardrails (carried forward)
- No stat-based meta progression; rerolls are **per-run** only.
- Maintain fixed timestep, pooling, and data-driven definitions.
- Clarity beats complexity; avoid adding new mechanics that reduce screen readability.
- No new TODOs without an associated issue/task reference.
