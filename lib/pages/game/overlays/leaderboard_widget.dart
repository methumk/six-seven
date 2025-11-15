import 'package:flutter/material.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/utils/data_helpers.dart';
import 'package:six_seven/utils/leaderboard.dart';

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
      final ptl = widget.totalLeaderboard[i];
      for (int j = 0; j < widget.totalPlayer; ++j) {
        final pcl = widget.currentLeaderboard[j];
        if (ptl.playerNum == pcl.playerNum) {
          double potBonus = widget.potDistrib[ptl] ?? 0;
          ptl.totalValue += roundDouble(ptl.currentValue + potBonus, 2);
          // _combinedLeaderboard.updateFor(ptl);
          _combinedLeaderboard.add(ptl);
          break;
        }
      }
    }

    // Determine the rank changes
    _combinedList = _combinedLeaderboard.topN(widget.totalPlayer);
    for (int i = 0; i < widget.totalPlayer; ++i) {
      final pcomb = _combinedList[i];
      for (int j = 0; j < widget.totalPlayer; ++j) {
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
          RowHeader(),
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

class RowHeader extends StatelessWidget {
  const RowHeader({super.key});

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
          SizedBox(width: 30, child: Text('', textAlign: TextAlign.center)),
          Expanded(
            flex: 3,
            child: Text(
              "Ranking",
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(flex: 1, child: Text("")),
          Expanded(
            flex: 2,
            child: Text(
              "Total",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Current",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Pot",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
              roundDouble(player.totalValue, 2).toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              player.currentValue > 0
                  ? '+${roundDouble(player.currentValue, 2)}'
                  : '${roundDouble(player.currentValue, 2)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getColorValue(player.currentValue)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              potEarning > 0
                  ? '+${roundDouble(potEarning, 2)}'
                  : '${roundDouble(potEarning, 2)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: _getColorValue(potEarning)),
            ),
          ),
        ],
      ),
    );
  }
}
