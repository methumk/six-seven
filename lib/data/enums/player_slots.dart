enum PlayerSlot {
  bottom,
  left,
  top,
  right;

  static PlayerSlot fromPlayerIndex(int index) =>
      PlayerSlot.values.firstWhere((e) => e.index == index);
}

enum PlayerCountSlotConfig {
  Zero([]),
  One([]),
  Two([PlayerSlot.bottom, PlayerSlot.top]),
  Three([PlayerSlot.bottom, PlayerSlot.left, PlayerSlot.right]),
  Four([PlayerSlot.bottom, PlayerSlot.left, PlayerSlot.top, PlayerSlot.right]);

  final List<PlayerSlot> label;
  const PlayerCountSlotConfig(this.label);

  static PlayerCountSlotConfig fromPlayerCount(int count) =>
      PlayerCountSlotConfig.values.firstWhere((e) => e.index == count);
}
