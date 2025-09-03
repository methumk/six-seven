import 'package:six_seven/components/players/player.dart';

class Cpu extends Player {
  Cpu({required super.playerNum});

  @override
  bool isCpu() {
    return true;
  }
}
