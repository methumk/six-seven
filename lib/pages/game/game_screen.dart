import 'dart:async';
import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/data/game_setup_settings.dart';
import 'package:six_seven/pages/game/game_manager.dart';

class GameScreen extends FlameGame with TapCallbacks, DragCallbacks {
  final BuildContext context;
  late final GameSetupSettings setupSettings;
  late final GameManager gameManager;
  late final Vector2 gameResolution;

  GameScreen({required this.context, required this.setupSettings}) {
    gameManager = GameManager(
      totalPlayerCount: setupSettings.totalPlayerCount,
      aiPlayerCount: setupSettings.aiPlayerCount,
      winningThreshold: setupSettings.winningScore,
    );
    gameResolution = Vector2(1280, 720);
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    // causes letter boxing
    camera.viewport = FixedResolutionViewport(resolution: gameResolution);
    add(gameManager);
  }

  Future<void> showExitDialog() async {
    print("EXIT DIALOG");
    // Pause the game ending
    pauseEngine();

    // Show Flutter dialog
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Exit Game?'),
            content: const Text('Do you want to go back?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
    );

    // result == true if user clicked Yes
    if (result == true) {
      // Navigate back or push a Flutter page
      Navigator.of(context).pop();
    } else {
      // Player cancelled, resume game
      resumeEngine();
    }
  }

  Future<void> showRoundPointsDialog(List<Player> players) async {
    print("Round points dialog");
    // Pause the game ending
    pauseEngine();
    final currentPointsMessage = List.generate(
      players.length,
      (i) =>
          "Player ${i}'s points earned from this round: ${players[i].currentValue}",
    ).join('\n');

    final totalPointsMessage = List.generate(
      players.length,
      (i) => "Player ${i}'s total points: ${players[i].totalValue}",
    ).join('\n');

    final message = "$currentPointsMessage\n$totalPointsMessage";
    // Show Flutter dialog
    await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Round statistics'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('ok'),
              ),
            ],
          ),
    );
    resumeEngine();
  }
}
