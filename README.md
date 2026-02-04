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
- [ ] Add Flame dependency to `pubspec.yaml`
- [ ] Set up project folder structure (`game/`, `components/`, `screens/`, `utils/`)
- [ ] Create the main `FlameGame` class

### Phase 2: Core Game Mechanics
- [ ] Create the `Tile` component (single tile with safe/dangerous state)
- [ ] Create the `TileRow` component (row of N tiles, one marked safe)
- [ ] Implement row spawning logic (spawn new rows at bottom)
- [ ] Implement upward scrolling (configurable speed)
- [ ] Implement row cleanup (remove rows that scroll off-screen)

### Phase 3: Player & Controls
- [ ] Create `Player` component with basic rendering
- [ ] Implement fixed joystick for left/right movement
- [ ] Implement jump button for forward jumps
- [ ] Add jump physics (arc movement to next row)
- [ ] Implement collision detection (player landing on tiles)

### Phase 4: Game State & Death Conditions
- [ ] Track which row the player is currently on
- [ ] Validate landing — safe tile vs dangerous tile
- [ ] Handle death: landing on dangerous tile
- [ ] Handle death: scroll catches up to player (fell behind)
- [ ] Implement game over state

### Phase 5: Scoring & Difficulty
- [ ] Implement score tracking (+1 per successful jump)
- [ ] Implement difficulty scaling (scroll speed increases with score)
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
