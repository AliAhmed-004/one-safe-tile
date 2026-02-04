## One Safe Tile

A minimalist, mobile-first reflex game where every row has exactly one safe tile.

---

### Core Gameplay
- Rows of tiles scroll upward endlessly
- Each row contains one safe tile
- Player must jump forward onto the safe tile to survive
- Wrong tile or falling behind (scroll catches up) results in instant death

### Controls
- **Fixed Joystick** — Move player left/right to align with the safe tile
- **Jump Button** — Jump forward onto the next row
- Landing is physics-based with collision detection

### Scoring
- +1 point per successful safe jump
- Local high score tracking

### Difficulty Scaling
- Scroll speed increases as score rises

---

## Implementation Phases

### Phase 1: Project Setup
- [x] Add Flame dependency to `pubspec.yaml`
- [x] Set up project folder structure (`game/`, `components/`, `screens/`, `utils/`)
- [x] Create the main `FlameGame` class

### Phase 2: Core Game Mechanics
- [x] Create the `Tile` component (single tile with safe/dangerous state)
- [x] Create the `TileRow` component (row of N tiles, one marked safe)
- [x] Implement row spawning logic (spawn new rows at bottom)
- [x] Implement upward scrolling (configurable speed)
- [x] Implement row cleanup (remove rows that scroll off-screen)

### Phase 3: Player & Controls
- [x] Create `Player` component with basic rendering
- [x] Implement fixed joystick for left/right movement
- [x] Implement jump button for forward jumps
- [x] Add jump physics (arc movement to next row)
- [x] Implement collision detection (player landing on tiles)

### Phase 4: Game State & Death Conditions
- [x] Track which row the player is currently on
- [x] Validate landing — safe tile vs dangerous tile
- [x] Handle death: landing on dangerous tile
- [x] Handle death: scroll catches up to player (fell behind)
- [x] Implement game over state

### Phase 5: Scoring & Difficulty
- [x] Implement score tracking (+1 per successful jump)
- [x] Implement difficulty scaling (scroll speed increases with score)
- [ ] Add local high score persistence (`shared_preferences`)

### Phase 6: UI & Screens
- [ ] Create Start/Menu screen (title, play button, high score)
- [ ] Create Game Over overlay (final score, high score, restart)
- [ ] Create in-game HUD (current score display)

### Phase 7: Polish & Feedback
- [ ] Add visual feedback for safe landing (e.g., color flash, particles)
- [ ] Add visual feedback for death (e.g., shake, red flash)
- [ ] Add sound effects (jump, land, death)
- [ ] Add background music (optional)

### Phase 8: Final Touches
- [ ] Optimize for mobile (smooth 60fps, responsive controls)
- [ ] Handle different screen sizes/aspect ratios
- [ ] Add pause functionality
- [ ] Testing & bug fixes

---

## Project Structure

```
lib/
├── main.dart
├── game/
│   └── one_safe_tile_game.dart      # Main FlameGame class
├── components/
│   ├── tile.dart                     # Individual tile
│   ├── tile_row.dart                 # Row of tiles
│   ├── player.dart                   # Player character
│   └── hud/
│       ├── joystick.dart             # Fixed joystick component
│       └── jump_button.dart          # Jump button component
├── screens/
│   ├── menu_screen.dart              # Start menu
│   └── game_over_overlay.dart        # Game over UI
└── utils/
    ├── constants.dart                # Colors, sizes, speeds
    └── score_manager.dart            # High score persistence
```
