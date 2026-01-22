# THEME_GUIDE.md — HordeSurvivor Core Theme (Exorcism: Sacred + Wry)

This file defines the non-negotiable creative direction for HordeSurvivor.
All new **characters, skills, items, enemies, UI text, VFX/SFX motifs, and sprites**
must follow these rules unless a task explicitly says otherwise.

---

## 1) Core fantasy (1 line)

A cast of unconventional exorcists survives impossible hordes by applying **ritual “rules”**
(items with explicit tradeoffs) and **holy-but-practical techniques** (skills) until the build “clicks”.

---

## 2) Tone (strict)

Choose content that is:

- **Crisp** (readable, immediate, high signal)
- **Ritualistic** (symbols, seals, chants, rites)
- **Wry** (dry humor; funny twists, not meme jokes)

### Avoid

- Modern meme references, slang-heavy jokes, internet culture callouts
- “Random” sci-fi/modern weapons unless reframed as relics / ritual tools
- Humor that breaks the world’s internal logic (the world can be serious even if characters are odd)

---

## 3) Signature identity mechanic: “Rites are rules”

Items are not generic gear. They are **Rites/Relics/Vows** that change game rules.

### Item text format (required)

Every item must clearly present:

- **Blessing**: one upside
- **Burden**: one downside

Example formatting:

- “Rite of Glass — **+Damage** / **-Max HP**”
- “Vow of Plenty — **+Gold drops** / **-Damage**”

### Design constraints

- No “gotcha” downsides (downsides must matter in normal play).
- Avoid multi-downside + multi-upside items early (keep them legible).
- Small deltas are preferred (players buy many items).

---

## 4) Naming conventions (required)

### Characters

Use “The \_\_\_” archetype naming:

- The Priest, The Brawler, The Cook, The Penitent Demon, etc.

Each character must have:

- 1 iconic prop (stole, ladle, bat, censer, book, chains, etc.)
- 1 gameplay identity (tags they bias toward)

### Skills (two buckets)

Pick one style and stick to it per skill:

1. **Sacred/Ritual**: “Litany of **_”, “Psalm of _**”, “Censer Ember”, “Sanctify”, “Seal of \_\_\_”
2. **Practical/Wry**: “Chair Throw”, “Hot Soup Splash”, “Receipt of Repentance”, “Slap of Absolution”

Rules:

- Skills must remain readable in shape and purpose.
- Funny names are allowed, but the effect must still feel “exorcism-adjacent”.

### Items

Must use one of:

- **Rite of \_\_\_** (rule change, most common)
- **Vow of \_\_\_** (rule + tradeoff; often economy/heat)
- **Relic: \_\_\_** (a physical object)
- Optional: **Clause: \_\_\_** (contract/legal flavor; use sparingly)

Item names should be short, noun-forward:

- Hymnal, Censer, Salt, Crucifix, Stole, Incense, Ledger, Ladle, Pan, Apron, Receipt Book.

### Enemies

Use coherent naming per faction:

**Demons/Infestation**

- One nasty word + one mundane noun: “Guilt Mite”, “Ash Imp”, “Grudge Hound”, “Ledger Wraith”
- Visuals: jagged, asymmetric, warm hues, smoke/ember motifs

**Order/Angels (if kept)**

- Ceremonial titles: “Warden”, “Herald”, “Sentinel”, “Archon”
- Visuals: geometric, symmetric, cool hues, light-zone motifs

---

## 5) Visual language (sprites + VFX)

### Silhouette rules

- Player characters: simple silhouette + 1 iconic prop (must be visible at 16px).
- Enemies: silhouette must communicate role (chaser/ranged/spawner/elite).

### Motifs to reuse everywhere (preferred)

**Sacred**

- Rings, seals, chalk sigils, crosses, incense puffs, bell flashes

**Practical/Wry**

- Splashes, steam clouds, receipt-paper strips, chair-shaped hit sparks

### Palette guidance (high-level)

- Sacred: off-white, gold, pale cyan
- Profane: crimson, ember orange, bruised purple
- Neutral UI: parchment + ink

---

## 6) UI/feedback language (text + SFX hooks)

### UI phrasing style

- Short, declarative, ritual-like.
- Always show tradeoffs in the same cadence:
  - “Blessing / Burden” (or “+ / -” but consistent)

### Feedback motifs (recommended)

- Sacred hit: bell tick + soft choir “ah”
- Debuff applied: chalk scratch
- Item picked: stamp “THUNK”
- Exorcised kill: inhale → whisper-pop

(Placeholders are fine; keep the motif consistent.)

---

## 7) Content templates (use for all new content)

### Skill template (minimum)

- Name (Sacred or Practical)
- Tags (Element/Effect/Geometry)
- Readable shape (beam / cone / ring / arc / aura)
- 1 synergy hook (e.g., Oil + Fire => Ignition)
- 1 mid-tier behavior upgrade (level 4–5)

### Item template (minimum)

- Category: Rite / Vow / Relic
- Blessing (+)
- Burden (-)
- Tags (what builds want it)
- Icon concept (prop/symbol)

### Enemy template (minimum)

- Role (chaser/ranged/spawner/etc.)
- Telegraph (visual + sound cue)
- Counterplay (what the player should do)
- One prop/motif (chains, candles, ledger pages, halo shards, etc.)

---

## 8) Do-not-do list (hard constraints)

- No permanent stat-grind metaprogression framing in theme text
- No meme/internet jokes in names or descriptions
- No unreadable VFX “noise” (clarity first)
- No items without explicit Blessing/Burden
- No content that ignores the exorcism motif (everything should feel like purification, binding, banishment, rites, or wry practical “cleansing”)

---

## 9) Quick checklist for agents (before submitting)

For every content change, verify:

- [ ] Fits “Exorcism: Sacred + Wry” tone
- [ ] Names follow conventions
- [ ] Items: explicit Blessing/Burden and legible tradeoff
- [ ] Skills: readable geometry + at least one synergy hook
- [ ] Sprites/VFX: uses approved motifs and is readable at 16px
- [ ] No meme references / no off-theme tech
