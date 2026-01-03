enum PlayerSlot {
  bottom,
  left,
  top,
  right;

  static PlayerSlot fromPlayerIndex(int index) =>
      PlayerSlot.values.firstWhere((e) => e.index == index);

  static PlayerSlot getNextPlayerSlot(PlayerSlot curr, bool cw, int steps) {
    int update = cw == true ? steps : -steps;
    return fromPlayerIndex((curr.index + update) % 4);
  }
}

enum PlayerCountSlotConfig {
  zero([]),
  one([]),
  //if there are 2 players in the game
  two([PlayerSlot.bottom, PlayerSlot.top]),
  //if there are 3 players in the game
  three([PlayerSlot.bottom, PlayerSlot.left, PlayerSlot.right]),
  //if there are 4 players in the game
  four([PlayerSlot.bottom, PlayerSlot.left, PlayerSlot.top, PlayerSlot.right]);

  final List<PlayerSlot> label;
  const PlayerCountSlotConfig(this.label);

  static PlayerCountSlotConfig fromPlayerCount(int count) =>
      PlayerCountSlotConfig.values.firstWhere((e) => e.index == count);
}
