// Maps index when looping to the index
enum PlayerCountConfiguration {
  Zero(""),
  One(""),
  Two("02.."),
  Three("013."),
  Four("0123");

  final String label;
  const PlayerCountConfiguration(this.label);

  static PlayerCountConfiguration fromPlayerCount(int count) =>
      PlayerCountConfiguration.values.firstWhere((e) => e.index == count);
}

// Index is of a for loop 0-3 (max players), playercount is total player count
// Returns the current index in the array the player should go to depending on player count
int getSetUpPosition(int playerCount, int index) {
  if (playerCount <= 1 && playerCount > 4 && index < 0 && index > 3) {
    return -1;
  }

  PlayerCountConfiguration pcc = PlayerCountConfiguration.fromPlayerCount(
    playerCount,
  );

  int? number = int.tryParse(pcc.label[index]);
  return number ?? -1;
}
