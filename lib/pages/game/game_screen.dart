// TODO
// The actual flame game
import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:six_seven/data/game_setup_settings.dart';
import 'package:six_seven/pages/game/game_manager.dart';

class GameScreen extends FlameGame with TapCallbacks, DragCallbacks {
  late final GameSetupSettings setupSettings;
  late final GameManager gameManager;

  GameScreen({required this.setupSettings}) {
    gameManager = GameManager(
      totalPlayerCount: setupSettings.totalPlayerCount,
      aiPlayerCount: setupSettings.aiPlayerCount,
      winningThreshold: setupSettings.winningScore,
    );
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    // causes letter boxing
    camera.viewport = FixedResolutionViewport(resolution: Vector2(1280, 720));
    add(gameManager);
  }
}
