// The player stack is a stack that keeps track of the number of times a player must hit/stay (or one or the other on special cases)
// when an event has been played. If no events, this stack should be empty. Flip 3 event, for example, will add players with the count to this stack.
// A player reference will be attacked with the amount of times they are forced to play. Once that number becomes 0 they will be removed from the stack
import 'package:six_seven/components/players/player.dart';

class PlayerForcePlayCount {
  late final Player player;
  late int count;
  PlayerForcePlayCount({required this.player, required this.count});

  @override
  String toString() {
    return "FPC(p: $player, c: $count)";
  }
}

class PlayerStack {
  final List<PlayerForcePlayCount> _stack = [];
  bool get isEmpty => _stack.isEmpty;
  bool get isNotEmpty => _stack.isNotEmpty;

  // Total count is the total number of runs to completely empty the stack
  int totalCount = 0;

  PlayerStack();

  void addPlayer(Player p, int forcePlayTimes) {
    if (forcePlayTimes <= 0) return;
    if (isEmpty) {
      _stack.add(PlayerForcePlayCount(player: p, count: forcePlayTimes));
    } else {
      // if existing is same player only update their count
      var top = _stack.last;
      if (top.player == p) {
        top.count += forcePlayTimes;
      } else {
        _stack.add(PlayerForcePlayCount(player: p, count: forcePlayTimes));
      }
    }

    totalCount += forcePlayTimes;
  }

  int? getTopPlayerCount() {
    var pfpc = peekTopPlayer();
    if (pfpc != null) {
      return pfpc.count;
    }
    return null;
  }

  PlayerForcePlayCount? peekTopPlayer() {
    if (_stack.isNotEmpty) {
      return _stack.last;
    }
    return null;
  }

  PlayerForcePlayCount? removeTopPlayer() {
    if (_stack.isNotEmpty) {
      var playerCount = _stack.last.count;
      totalCount -= playerCount;
      return _stack.removeLast();
    }
    return null;
  }

  // Decrements the number of times to player has to play
  // Will remove player once the score has become 0
  PlayerForcePlayCount? decrementTopPlayer({int decrementBy = 1}) {
    if (_stack.isNotEmpty) {
      var top = _stack.last;

      top.count -= decrementBy;
      var currCount = getTopPlayerCount();
      if (decrementBy >= currCount!) {
        totalCount -= currCount;
      } else {
        totalCount -= decrementBy;
      }

      // Remove the value if zeroed
      if (top.count <= 0) {
        return _stack.removeLast();
      }
    }
    return null;
  }

  @override
  String toString() {
    return "$_stack";
  }
}
