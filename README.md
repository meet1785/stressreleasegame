# 🌸 Gentle Tidy (Stress Release Game)

A complete, cozy, tactile stress-relief game built in **Godot 4** designed to soothe your mind through satisfying tactile interactions, mindful breathing, and room decoration.

---

## ✨ Features

### 1. 🫧 ASMR Bubble Wrap Sheet
- **Tactile Grid**: Glossy 2D pastel bubbles with specular sheen, drop shadows, and silicone base sockets.
- **Fluid Controls**: Full support for single-tap, click, and **drag-to-pop** across multiple bubbles in a soothing cascade.
- **ASMR Audio & Visual Burst**: Procedural audio pops with pitch variation, squish-and-squash spring tweening, particle droplet bursts, and mobile haptic vibration.
- **Zen Combo System**: Rapid pops trigger a combo counter (`2x` up to `5x`) with pentatonic chime harmonies.
- **Sheet Flip / Refresh**: Smooth ripple wave animation with cascading pop sounds to refresh the sheet.
- **Play Modes**: Switch between **Tidy Sheet** (clear all bubbles to claim bonuses) and **Endless Pop** (fidget toy mode with auto-re-inflating bubbles).

### 2. ✨ Zen Surface Polish (Dust Wipe)
- **Satisfying Cleaning**: Clean cloudy and dusty surfaces (Cozy Oak Table, Vintage Brass Mirror, Steamy Rainy Window).
- **Tactile Sponge Wiping**: Move mouse or drag finger to wipe away dust spots in real-time.
- **Sparkling Cleanliness**: Real-time progress meter (`0%` to `100%`) with sparkle trails and soft whoosh sound effects.
- **Completion Fanfare**: Reaching clean status triggers a sparkling aura burst and rewards Satisfaction Points.

### 3. 🫁 Mindful Breathing Companion
- **4-4-4-4 Box Breathing Pacer**: Inhale (4s) ➔ Hold (4s) ➔ Exhale (4s) ➔ Rest (4s).
- **Soothing Audio Cues**: Resonant singing bowl hum on inhale, calming swoosh on exhale, and harmonious bells on cycle completion.
- **Color Shifting Sphere**: Smoothly expanding and contracting sphere with harmonic ripple rings to guide slow, deep breaths.
- **Stress-Relief Rewards**: Earns Satisfaction Points for each completed mindful breathing cycle.

### 4. 🪴 Cozy Isometric Diorama Room
- **2.5D Isometric Platform**: Beautiful parquet wooden floor with placement slots.
- **12 Collectible Cozy Decorations**:
  1. *Cozy Succulent* (Jade leaves in terracotta saucer)
  2. *Lavender Candle* (Flickering warm flame with amber ambient aura)
  3. *Chamomile Tea* (Steaming mug with lemon slice and rising steam curls)
  4. *Mochi the Cat* (Curled up sleeping kitten with breathing animation and floating heart emotes)
  5. *Warm Fairy Lights* (Hanging wire with colorful glowing bulbs)
  6. *Quiet Novels* (Stacked hardcover books with a satin bookmark)
  7. *Zen Juniper* (Sculpted bonsai tree in ceramic tray)
  8. *Vintage Turntable* (Spins vinyl record with brass tonearm)
  9. *Amber Floor Lamp* (Casts warm circular light cone on the floor)
  10. *Velvet Beanbag* (Squishy tufted corduroy floor cushion)
  11. *Amethyst Cluster* (Twinkling purple healing crystal with facet glints)
  12. *Mossy Terrarium* (Glass cloche dome with live moss and coral mushrooms)
- **Interactive Tapping**: Tap any placed decoration in the room to trigger micro-reactions (purring hearts, candle flare, steam curls, musical notes).

### 5. 🛍️ Zen Catalog (Shop)
- Browse all 12 cozy items with vector previews, descriptions, and point costs.
- Spend Satisfaction Points earned through popping, cleaning, and breathing to unlock room decor.
- Celebratory unlock fanfare with confetti sparkles and instant room placement.

### 6. 🎯 Daily Mindful Goals
- Calming daily milestones:
  - *Mindful Pop*: Pop 25 bubbles
  - *Bubble Zen*: Pop 100 bubbles
  - *Clean Slate*: Clear an entire bubble sheet
  - *Gentle Polish*: Wipe a dusty surface to 100% clean
  - *Calm Breath*: Complete 2 breathing cycles
  - *Cozy Space*: Unlock a diorama decoration
- Claim rewards directly to boost your Satisfaction Points balance.

### 7. ⚙️ Preferences & Save System
- Toggles for **Tactile SFX**, **Calming Ambience**, and **Haptic Feedback**.
- Progress reset option with safety confirmation.
- Safe JSON persistence to `user://gentle_tidy_save.json`.

---

## 🎵 Zero-Dependency Procedural Audio

`scripts/AudioManager.gd` generates all audio streams dynamically at runtime using `AudioStreamWAV` and mathematical waveform synthesis:
- **Pop**: Fast exponential sine sweep (720Hz ➔ 90Hz) with transient click and random pitch shift.
- **Pentatonic Chimes**: Multi-harmonic bell tones at C5 (523Hz), D5 (587Hz), E5 (659Hz), G5 (784Hz), A5 (880Hz), and C6 (1046Hz).
- **Whoosh**: Low-pass filtered shaped noise simulating soft sponge and cloth sweeps.
- **Sparkle**: Cascading high-frequency bell sweeps.
- **Singing Bowl**: Warm Tibetan singing bowl fundamental (220Hz) with 2nd and 3rd harmonics.
- **Click**: Tactile woodblock UI tap.

*No missing audio files, no external codecs required.*

---

## 🏗️ Project Architecture

```
stressreleasegame/
├── project.godot                  # Engine config (Main.tscn, autoloads, touch emulation, stretch)
├── README.md                      # Documentation
├── scenes/
│   ├── Main.tscn                  # Top-level view controller and navigation
│   ├── BubbleTile.tscn            # Individual tactile bubble with custom 2D rendering
│   ├── BubbleSheetView.tscn       # 35-bubble ASMR wrap grid with combos
│   ├── ZenWipeView.tscn           # Surface dusting and polishing mode
│   ├── BreatheView.tscn           # 4-4-4-4 mindful breathing guide
│   ├── DioramaView.tscn           # Isometric cozy room view
│   ├── DioramaItem.tscn           # Interactive placed diorama item
│   ├── ShopView.tscn              # Catalog and points unlock system
│   ├── DailyTasksView.tscn        # Mindful goals and rewards tracker
│   └── SettingsModal.tscn         # Audio, haptics, and reset settings
├── scripts/
│   ├── AudioManager.gd            # Autoload: procedural ASMR audio synthesizer
│   ├── GameManager.gd             # Autoload: points economy, catalog, stats, persistence
│   ├── Main.gd                    # Main view navigation and tab coordinator
│   ├── BubbleTile.gd              # Bubble physics, burst particles, and input handling
│   ├── BubbleSheetView.gd         # Grid management, combos, and sheet flip
│   ├── ZenWipeView.gd             # Dust matrix, wiping physics, and cleanliness ratio
│   ├── BreatheView.gd             # Breath phase timing and circle tweening
│   ├── DioramaCanvas.gd           # Isometric coordinate projection and floor drawing
│   ├── DioramaItem.gd             # Item idle animations and tap emote reactions
│   ├── DioramaView.gd             # Diorama ambient particles and stats
│   ├── ItemDrawer.gd              # Shared vector illustration drawer for all 12 items
│   ├── ShopView.gd                # Item cards, affordability logic, and unlock flow
│   ├── DailyTasksView.gd          # Goal progress bars and claim handler
│   └── SettingsModal.gd           # Toggles and preferences persistence
└── tests/
    └── test_all_features.gd       # 11-suite automated headless test runner
```

---

## 🧪 Testing & Verification

Run the comprehensive 11-suite automated test runner using headless Godot:

```bash
godot --headless --path . -s res://tests/test_all_features.gd
```

All 11 test suites validate:
1. `GameManager`: Points balance, transactions, item unlocks, and task tracking.
2. `AudioManager`: Waveform synthesis and polyphonic audio player dispatch.
3. `BubbleTile`: Input detection (touch/mouse), pop burst, reset, and signals.
4. `BubbleSheetView`: 35-bubble grid, drag-to-pop, combo multipliers, and flip reset.
5. `ZenWipeView`: Dust cell matrix, wipe calculation, and 100% clean detection.
6. `BreatheView`: 4-phase cycle progression and reward distribution.
7. `DioramaCanvas` & `DioramaItem`: Isometric coordinate transforms, item spawning, and tap reactions.
8. `ShopView`: Catalog generation, purchase flow, and room synchronization.
9. `DailyTasksView`: Task progress gauges, claim buttons, and reward redemption.
10. `SettingsModal`: SFX, ambience, haptics toggles, and data reset.
11. `Main`: View switching across all 6 views and top-level navigation.