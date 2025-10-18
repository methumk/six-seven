import 'dart:async';
import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/data/game_setup_settings.dart';
import 'package:six_seven/pages/game/game_manager.dart';
import 'package:six_seven/utils/leaderboard.dart';

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
            title: Center(child: const Text('Leaderboard')),
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
}

class LeaderboardWidget extends StatefulWidget {
  final List<Player> totalLeaderboard;
  final List<Player> currentLeaderboard;
  final Map<Player, double> potDistrib;
  final int totalPlayer;

  const LeaderboardWidget({
    super.key,
    required this.totalLeaderboard,
    required this.currentLeaderboard,
    required this.potDistrib,
    required this.totalPlayer,
  });

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  late List<Player> _combinedList;
  final Leaderboard<Player> _combinedLeaderboard = Leaderboard<Player>(
    compare: (a, b) {
      // order by score descending, break ties by id
      final cmp = b.totalValue.compareTo(a.totalValue);
      return cmp != 0 ? cmp : a.playerNum.compareTo(b.playerNum);
    },
  );
  final Map<String, int> _rankChange = {};

  @override
  void initState() {
    super.initState();

    // Update total values and create new combined leader board (previous total + current total)
    for (int i = 0; i < widget.totalPlayer; ++i) {
      for (int j = 0; j < widget.totalPlayer; ++j) {
        final ptl = widget.totalLeaderboard[i];
        final pcl = widget.currentLeaderboard[j];
        if (ptl.playerName == pcl.playerName) {
          double potBonus = widget.potDistrib[ptl] ?? 0;
          ptl.totalValue += ptl.currentValue + potBonus;
          _combinedLeaderboard.updateFor(ptl);
          break;
        }
      }
    }

    // Determine the rank changes
    _combinedList = _combinedLeaderboard.topN(widget.totalPlayer);
    for (int i = 0; i < widget.totalPlayer; ++i) {
      for (int j = 0; j < widget.totalPlayer; ++j) {
        final pcomb = _combinedList[i];
        final pprev = widget.totalLeaderboard[j];
        if (pcomb.playerName == pprev.playerName) {
          _rankChange[pcomb.playerName] = j - i;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      height: 300,
      child: Column(
        children: [
          for (int i = 0; i < widget.totalPlayer; ++i)
            LeaderboardRow(
              rank: i + 1,
              player: _combinedList[i],
              rankChange: _rankChange[_combinedList[i].playerName] ?? 0,
              potEarning: widget.potDistrib[_combinedList[i]] ?? 0,
            ),
        ],
      ),
    );
  }
}

class LeaderboardRow extends StatelessWidget {
  final int rank;
  final Player player;
  final int rankChange;
  final double potEarning;

  const LeaderboardRow({
    super.key,
    required this.rank,
    required this.player,
    required this.rankChange,
    required this.potEarning,
  });

  Icon _rankChangeIcon() {
    if (rankChange > 0) {
      return const Icon(Icons.arrow_upward, color: Colors.green, size: 20);
    } else if (rankChange < 0) {
      return const Icon(Icons.arrow_downward, color: Colors.red, size: 20);
    } else {
      return const Icon(Icons.remove, color: Colors.grey, size: 20);
    }
  }

  Color _getColorValue(double value) {
    if (value > 0) {
      return Colors.green;
    } else if (value < 0) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('$rank', textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 3,
            child: Text(
              player.playerName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 1, child: Center(child: _rankChangeIcon())),
          Expanded(
            flex: 2,
            child: Text(
              player.totalValue.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              player.currentValue > 0
                  ? '+${player.currentValue}'
                  : '${player.currentValue}',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getColorValue(player.currentValue)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              potEarning > 0 ? '+${potEarning}' : '${potEarning}',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getColorValue(potEarning)),
            ),
          ),
        ],
      ),
    );
  }
}
