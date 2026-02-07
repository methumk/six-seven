import 'dart:async';
import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart' hide Route;
import 'package:flame_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/players/cpu_player.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/data/game_setup_settings.dart';
import 'package:six_seven/pages/game/game_manager.dart';
import 'package:six_seven/pages/game/overlays/leaderboard_widget.dart';
import 'package:six_seven/pages/game/overlays/lucky_dice_widget.dart';
import 'package:six_seven/pages/game/overlays/sunk_prophet_widget.dart';
import 'package:six_seven/pages/home/home_screen.dart';

class GameScreen extends FlameGame with TapCallbacks, DragCallbacks {
  final BuildContext context;
  late final GameSetupSettings setupSettings;
  late final GameManager gameManager;
  late final Vector2 gameResolution;

  // Card SVGs
  // Load card svgs
  // number cards are with key nc_<number>
  // event cards are with key ec_<EventCardEnum.label>
  // value action cards are with key vc_<number> e.g. vc_-3, vc_+4
  final Map<String, Svg> cardSvgs = {};

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

    // Load all card svgs
    // Number card
    cardSvgs["nc_0"] = await Svg.load('images/game_ui/number_card_0.svg');
    cardSvgs["nc_1"] = await Svg.load('images/game_ui/number_card_1.svg');
    cardSvgs["nc_2"] = await Svg.load('images/game_ui/number_card_2.svg');
    cardSvgs["nc_3"] = await Svg.load('images/game_ui/number_card_3.svg');
    cardSvgs["nc_4"] = await Svg.load('images/game_ui/number_card_4.svg');
    cardSvgs["nc_5"] = await Svg.load('images/game_ui/number_card_5.svg');
    cardSvgs["nc_6"] = await Svg.load('images/game_ui/number_card_6.svg');
    cardSvgs["nc_7"] = await Svg.load('images/game_ui/number_card_7.svg');
    cardSvgs["nc_8"] = await Svg.load('images/game_ui/number_card_8.svg');
    cardSvgs["nc_9"] = await Svg.load('images/game_ui/number_card_9.svg');
    cardSvgs["nc_10"] = await Svg.load('images/game_ui/number_card_10.svg');
    cardSvgs["nc_11"] = await Svg.load('images/game_ui/number_card_11.svg');
    cardSvgs["nc_12"] = await Svg.load('images/game_ui/number_card_12.svg');
    cardSvgs["nc_13"] = await Svg.load('images/game_ui/number_card_13.svg');
    // TODO: Load value cards
    // TODO: Load event cards
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

  Future<void> endGameDialog(
    int playerCount,
    List<Player> totalLeaderboard,
    List<Player> currentLeaderboard,
    Map<Player, double> potDistribution,
  ) async {
    pauseEngine();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Center(child: Text('Final Results:')),
            content: LeaderboardWidget(
              totalPlayer: playerCount,
              totalLeaderboard: totalLeaderboard,
              currentLeaderboard: currentLeaderboard,
              potDistrib: potDistribution,
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    iconSize: 15,
                    padding: const EdgeInsets.all(18),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed:
                      () => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const HomeScreenContainer(),
                        ),
                        (Route<dynamic> route) => false,
                      ),
                  child: const Text(
                    'End Game',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
    );
  }
  // Future<void> showRoundPointsDialog(List<Player> players) async {
  //   print("Round points dialog");
  //   // Pause the game ending
  //   pauseEngine();
  //   final currentPointsMessage = List.generate(
  //     players.length,
  //     (i) =>
  //         "Player ${i}'s points earned from this round: ${players[i].currentValue}",
  //   ).join('\n');

  //   final totalPointsMessage = List.generate(
  //     players.length,
  //     (i) => "Player ${i}'s total points: ${players[i].totalValue}",
  //   ).join('\n');

  //   final message = "$currentPointsMessage\n$totalPointsMessage";
  //   // Show Flutter dialog
  //   await showDialog<bool>(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: Center(child: const Text('Leaderboard')),
  //           content: Text(message),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(true),
  //               child: const Text('ok'),
  //             ),
  //           ],
  //         ),
  //   );
  //   resumeEngine();
  // }

  Future<void> showLeaderboard(
    // BuildContext context,
    int playerCount,
    List<Player> totalLeaderboard,
    List<Player> currentLeaderboard,
    Map<Player, double> potDistribution,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Center(child: Text('Leaderboard')),
            content: LeaderboardWidget(
              totalPlayer: playerCount,
              totalLeaderboard: totalLeaderboard,
              currentLeaderboard: currentLeaderboard,
              potDistrib: potDistribution,
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(18),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<int> showRollDiceEvent({
    bool isAi = false,
    Difficulty aiDifficulty = Difficulty.expert,
    bool isLuckyDie = false,
  }) async {
    pauseEngine();
    int? dieScore = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Center(child: Text('Roll Dice')),
            content:
                isLuckyDie
                    ? LuckyDieWidget(isAi: isAi, aiDifficulty: aiDifficulty)
                    : SunkProphetWidget(isAi: isAi, aiDifficulty: aiDifficulty),
          ),
    );
    resumeEngine();

    return dieScore ?? 0;
  }
}
