//Human PLayer class
import 'package:six_seven/components/players/player.dart';

class HumanPlayer extends Player {
  HumanPlayer({required super.playerNum});

  @override
  bool isCpu() {
    return false;
  }
}
