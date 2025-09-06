import 'package:six_seven/components/players/player.dart';

enum Difficulty {
  easy(1),
  medium(2),
  hard(3),
  expert(4);

  final int level;
  const Difficulty(this.level);
}

class CpuPlayer extends Player {
  //Difficulty is an integer from 1 to 3, from 1 easiest to 3 hardest
  late final Difficulty difficulty;
  CpuPlayer({required super.playerNum, required this.difficulty});

  @override
  bool isCpu() {
    return true;
  }
}
