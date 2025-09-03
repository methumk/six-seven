import 'package:six_seven/components/players/player.dart';

class CpuPlayer extends Player {
  CpuPlayer({required super.playerNum});

  @override
  bool isCpu() {
    return true;
  }
}
