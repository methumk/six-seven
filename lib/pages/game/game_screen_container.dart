import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/data/game_setup_settings.dart';
import 'package:six_seven/pages/game/game_screen.dart';

class GameScreenContainer extends StatefulWidget {
  final GameSetupSettings config;
  const GameScreenContainer({required this.config, super.key});

  @override
  State<GameScreenContainer> createState() => _TestingRangeContainerState();
}

class _TestingRangeContainerState extends State<GameScreenContainer> {
  late GameScreen sixSevenGame;

  @override
  void initState() {
    super.initState();

    sixSevenGame = GameScreen(setupSettings: widget.config);
  }

  @override
  void dispose() {
    print("game disposed");
    sixSevenGame.onRemove(); // Explicitly dispose of game
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: sixSevenGame,
        // TODO: add overlay for settings, end game state, card probabilities
        // overlayBuilderMap: {
        //   'GoodGameOver': (_, __) => GoodGameOver(game: sixSevenGame),
        //   'BadGameOver': (_, __) => BadGameOver(game: sixSevenGame),
        //   'Pause': (_, __) => Pause(game: sixSevenGame),
        // },
      ),
    );
  }
}
