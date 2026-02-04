import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/one_safe_tile_game.dart';
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
  // Create the game instance
  late final OneSafeTileGame game;

  @override
  void initState() {
    super.initState();
    game = OneSafeTileGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: game,
        // TODO: Add overlays for menu and game over screens
        // overlayBuilderMap: {
        //   'menu': (context, game) => MenuScreen(...),
        //   'gameOver': (context, game) => GameOverOverlay(...),
        // },
      ),
    );
  }
}
