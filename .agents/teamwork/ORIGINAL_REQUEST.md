# Original User Request

## Initial Request — 2026-10-27T13:56:09Z

GitHub profile overhaul for **VictorRamosHC**: replace generic cyberpunk neon aesthetic with a **coherent corporate-infrastructure identity** (obsidian/amber/ivory/deep crimson palette), rebuild the README as an explorable interface, deliver **four linked browser-based minigames** (one per featured project), and animate the profile with purposeful, restrained motion — no glitch-rain, no rainbow neon, no unverifiable claims.

**Working directory:** `C:\Users\victor.hugo\.gemini\antigravity\scratch\VictorRamosHC`

**Integrity mode:** demo

---

## Context

- **Repo:** `https://github.com/VictorRamosHC/VictorRamosHC` (GitHub profile special repo — already cloned at working directory)
- **Stack available:** pure HTML/CSS/JS for minigames + SVG for animated assets (no server-side)
- **Palette (authoritative):** `#030305` obsidian · `#0A0B10` panel · `#D4AF37` amber · `#F5F0E8` ivory · `#8C1D18` deep crimson · `#64748B` muted · `#E0E7FF` readable text
- **Existing assets in working directory:** `assets/cyberpunk_header.jpg`, `assets/profile_bust_caesar.png`, `assets/terminal_breach.svg`, `minigame/index.html` (old breach protocol game — can be replaced or kept as-is)
- **Git remote:** `https://github.com/VictorRamosHC/VictorRamosHC.git` (push enabled, credentials available via git keyring)
- **Important:** After all files are created and verified, run `git add . && git commit -m "feat(profile): corporate identity overhaul v3 - banner, network map, four minigames" && git push origin main` to publish.

---

## Requirements

### R1. New Corporate Banner SVG

Create `assets/corporate_grid.svg` — a **wide (3:1 ratio, 900×300) animated SVG banner** with:
- Pure obsidian/graphite/amber palette. No cyan, no rainbow neon.
- A single, clean geometric corporate sigil (angular hexagonal or diamond frame) centered-left with ample negative space on the right.
- Fine network routing lines (thin `#D4AF37` and `#8C1D18` paths) traversing the dark surface like infrastructure topology maps. Lines should animate slowly (stroke-dasharray draw-on / pulse), not flash.
- Right-side typography area (Space Mono font stack): `SYSTEMS ARCHITECTURE` in `#F5F0E8` ivory at bold weight, subtitle `SECURITY OPERATIONS GRID` in `#D4AF37` amber at smaller size, and a muted gray date/version stamp.
- A very subtle scanline overlay — one pixel repeating linear gradient, 4% opacity maximum, no distraction.
- **No holographic screens, no neon glows, no matrix rain, no generic hacker imagery, no cyan, no purple.**

### R2. Updated `README.md` — Explorable Interface

Rewrite `README.md` to follow this exact section hierarchy:

```
1. BANNER (assets/corporate_grid.svg — full width)
2. TYPING ANIMATION (corporate language only — no fake metrics)
3. IDENTITY (2–3 lines: who, what, mindset — real, human, direct)
4. EVOLUTION LINE (ProjetoViagem → GlassTask → Prisma House Painter → Aether Vault)
5. SYSTEMS TABLE (5 projects with stack + deploy/download links)
6. NETWORK MAP (assets/network_map.svg inline)
7. INTERACTIVE SYSTEMS — 4 minigame panels (BEFORE stats)
8. STACK BADGES (obsidian bg, amber/ivory logo colors)
9. TELEMETRY (GitHub Stats + Streak — obsidian/amber theme)
10. FOOTER WAVE (capsule-render: obsidian→crimson→amber)
```

Corporate language to use in the typing animation (readme-typing-svg demolab):
- `CORP // SYSTEMS ARCHITECTURE`
- `NETWORK NODE: VICTOR-HUGH`
- `ARCHITECTURE STATUS: EVOLVING`
- `BUILD · REFACTOR · HARDEN`
- `SIGNAL ROUTE: PROJECT → SYSTEM → PRODUCT`

Color for typing animation: `#D4AF37` (amber).

**REMOVE** all unverifiable fake-technical claims: no `RSA-2048`, no `LATENCY: 1ms`, no `LEVEL_5_ARCHON`, no `AIR-GAPPED BY DESIGN`, no `OVERCLOCK_120HZ`, no `NEURAL_ORCHESTRATED`.

The INTERACTIVE SYSTEMS section must look like this:

```markdown
## ◼ [ 05 // INTERACTIVE SYSTEMS ]

| System | Description | Access |
|---|---|---|
| **Signal Route** | Map the correct network path between nodes. Linked to ProjetoViagem. | [PLAY SIMULATION →](./minigame/signal-route/index.html) |
| **Task Triage** | Prioritize the backlog before operational collapse. Linked to GlassTask. | [OPEN CONTROL ROOM →](./minigame/task-triage/index.html) |
| **Color Protocol** | Reconstruct the facade composition. Linked to Prisma House Painter. | [ENTER PRISMA GRID →](./minigame/color-protocol/index.html) |
| **Audio Breach** | Synchronize frequency, rhythm, and signal. Linked to Aether Vault. | [ACCESS AETHER VAULT →](./minigame/audio-breach/index.html) |
```

### R3. Four Browser-Based Minigames

Each game is a **self-contained** `minigame/<name>/index.html` file — pure HTML/CSS/JS, **zero external dependencies** (no CDN, no unpkg, no googleapis, no framework imports). Must work via `file://` protocol. Each must:
- Use CSS variables matching the authoritative palette.
- Show a title screen with instructions, then a playable game loop, then a win/lose/score screen with a "Play Again" option.
- Render correctly at 900px viewport width minimum.

**Game 1 — `minigame/signal-route/index.html` — Signal Route**
- A grid-based wire-connection puzzle. Numbered colored nodes appear on a grid. Player clicks sequential cells to draw a path connecting matching pairs of nodes without crossing other paths.
- 5 levels of increasing grid size and node density (3×3 → 4×4 → 5×5 → 6×6 → 7×7).
- Show level number, move count, and a "Level Complete" overlay when all pairs are connected.
- Linked project: ProjetoViagem.

**Game 2 — `minigame/task-triage/index.html` — Task Triage**
- Task cards labeled CRITICAL / HIGH / MEDIUM / LOW fall slowly from the top of the screen.
- Player drags or clicks them into the correct priority column (4 columns at the bottom).
- 3 rounds, each 30 seconds. Score = correct placements. Wrong placements decrement score.
- Linked project: GlassTask.

**Game 3 — `minigame/color-protocol/index.html` — Color Protocol**
- A target color swatch is shown. Player mixes R/G/B sliders to match it.
- Score is calculated as 100 minus the average channel distance.
- 5 rounds with increasingly close target colors. Show score per round and total.
- Linked project: Prisma House Painter.

**Game 4 — `minigame/audio-breach/index.html` — Audio Breach**
- Uses Web Audio API (no audio files, all synthesized).
- The game plays a sequence of tones (3–7 tones per round, each a distinct frequency).
- Player must click corresponding on-screen frequency buttons in the same order.
- 5 rounds with increasing sequence length. Show correct/incorrect feedback after each attempt.
- Linked project: Aether Vault.

### R4. Animated Network Map SVG

Create `assets/network_map.svg` — an animated SVG (900×160) showing four project nodes connected by clean orthogonal routed lines.

Node labels (left to right): `ProjetoViagem` → `GlassTask` → `Prisma House Painter` → `Aether Vault`

- Each node: a small square `#0A0B10` with `#D4AF37` border, label in `#E0E7FF`, small year below in `#64748B`.
- Connecting lines: thin `#D4AF37` paths with animated signal dot (`#8C1D18` small circle) traveling left-to-right, repeating, with 1s delay between nodes.
- Background: `#030305` obsidian, no neon, no cyan.

---

## Acceptance Criteria

### R1 — Banner
- [ ] `assets/corporate_grid.svg` opens in a browser without errors.
- [ ] `grep -i "#00E5FF\|#00e5ff\|#00ff\|cyan\|neon\|rainbow" assets/corporate_grid.svg` returns zero matches.
- [ ] SVG has at least one `<animate>` or CSS `@keyframes` element producing slow, non-flashing motion.
- [ ] SVG width attribute is 900 or uses `viewBox="0 0 900 300"`.

### R2 — README
- [ ] `README.md` exists and starts with `<div align="center">` wrapping the banner image.
- [ ] `grep -i "rsa-2048\|latency: 1ms\|level_5\|air-gapped\|netrunner\|rainbow\|overclock\|neural_orch" README.md` returns zero matches.
- [ ] README contains all four minigame links pointing to `./minigame/<name>/index.html`.
- [ ] Section order follows: banner → typing → identity → evolution → systems → network map → interactive systems → stack → telemetry → footer.
- [ ] Typing animation color parameter is `D4AF37` (amber).

### R3 — Minigames
- [ ] All four `minigame/<name>/index.html` files exist.
- [ ] `grep -rn "cdn\|unpkg\|jsdelivr\|googleapis\|cloudflare" minigame/` returns zero matches.
- [ ] Signal Route: 5 levels defined in JS, level 3 puzzle is solvable by a human player.
- [ ] Task Triage: 3 rounds implemented, score variable increments on correct placement.
- [ ] Color Protocol: 5 rounds, score formula uses channel distance math.
- [ ] Audio Breach: `AudioContext` or `webkitAudioContext` is used, 5 rounds, sequence length grows per round.
- [ ] Each game has a title screen and a game-over / score screen.

### R4 — Network Map
- [ ] `assets/network_map.svg` exists with `viewBox` spanning at least 900px wide.
- [ ] All four node labels present: ProjetoViagem, GlassTask, Prisma House Painter, Aether Vault.
- [ ] Contains at least one `<animateMotion>` or equivalent animation on a signal dot element.
- [ ] `grep -i "cyan\|#00e5ff\|#00ff" assets/network_map.svg` returns zero matches.

### Final Delivery
- [ ] `git status` shows clean working tree after commit.
- [ ] `git log --oneline -1` shows the commit message containing "corporate identity overhaul v3".
- [ ] `git push` succeeded (remote refs updated).
