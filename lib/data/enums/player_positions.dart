// Maps index when looping to the index
// Default is clock wise starting from bottom player (index 0)
import 'package:six_seven/data/enums/player_rotation.dart';

enum PlayerPositions {
  bottom,
  left,
  top,
  right;

  static PlayerPositions fromPlayerIndex(int index) =>
      PlayerPositions.values.firstWhere((e) => e.index == index);
}

enum PlayerCountConfiguration {
  Zero([]),
  One([]),
  Two([0, 2]),
  Three([0, 1, 3]),
  Four([0, 1, 2, 3]);

  final List<int> label;
  const PlayerCountConfiguration(this.label);

  static PlayerCountConfiguration fromPlayerCount(int count) =>
      PlayerCountConfiguration.values.firstWhere((e) => e.index == count);
}
