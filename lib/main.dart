import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/one_safe_tile_game.dart';
import 'screens/arena_border.dart';
import 'screens/controls_panel.dart';
import 'screens/game_hud.dart';
import 'screens/game_over_overlay.dart';
import 'screens/menu_screen.dart';
import 'screens/pause_overlay.dart';
import 'utils/score_manager.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode (mobile-first game)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hide system UI for immersive gameplay
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [],
  );

  // Initialize score manager for high score persistence
  await ScoreManager.instance.initialize();

  runApp(const OneSafeTileApp());
}

/// Root application widget
class OneSafeTileApp extends StatelessWidget {
  const OneSafeTileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Safe Tile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE94560),
          brightness: Brightness.dark,
        ),
      ),
      home: const GameScreen(),
    );
  }
}

/// Main game screen that hosts the Flame game
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final OneSafeTileGame game;

  @override
  void initState() {
    super.initState();
    game = OneSafeTileGame();
  }

  void _startGame() {
    game.startGame();
  }

  void _restartGame() {
    game.resetGame();
    game.startGame();
  }

  void _showMenu() {
    game.showMenu();
  }

  void _pauseGame() {
    game.pauseGame();
    game.overlays.add('pause');
  }

  void _resumeGame() {
    game.overlays.remove('pause');
    game.resumeGame();
  }

  void _quitToMenu() {
    game.overlays.remove('pause');
    game.showMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        initialActiveOverlays: const ['menu'],
        overlayBuilderMap: {
          // Main menu overlay
          'menu': (context, OneSafeTileGame game) =>
              MenuScreen(onPlayPressed: _startGame),

          // In-game HUD overlay (score + pause button at top)
          'hud': (context, OneSafeTileGame game) => Stack(
            children: [
              // Controls panel background at bottom
              const ControlsPanel(),
              // Arena border
              const ArenaBorder(),
              // HUD at top with score and pause
              ValueListenableBuilder<int>(
                valueListenable: game.scoreNotifier,
                builder: (context, score, child) =>
                    GameHud(score: score, onPausePressed: _pauseGame),
              ),
            ],
          ),

          // Pause overlay
          'pause': (context, OneSafeTileGame game) => PauseOverlay(
            onResumePressed: _resumeGame,
            onQuitPressed: _quitToMenu,
          ),

          // Game over overlay
          'gameOver': (context, OneSafeTileGame game) => GameOverOverlay(
            score: game.score,
            onRestartPressed: _restartGame,
            onMenuPressed: _showMenu,
          ),
        },
      ),
    );
  }
}
