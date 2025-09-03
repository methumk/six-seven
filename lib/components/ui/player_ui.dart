import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:six_seven/components/players/cpu_player.dart';
import 'package:six_seven/components/players/human_player.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/pages/game/game_screen.dart';

class PlayerUI extends PositionComponent
    with HasGameReference<GameScreen>, TapCallbacks {
  late final Player _player;

  PlayerUi({required int playerNum, required bool isCpu}) {
    if (isCpu) {
      _player = CpuPlayer(playerNum: playerNum);
    } else {
      _player = HumanPlayer(playerNum: playerNum);
    }
  }
}
