enum PlayerSlot {
  bottom,
  left,
  top,
  right;

  static PlayerSlot fromPlayerIndex(int index) =>
      PlayerSlot.values.firstWhere((e) => e.index == index);
}

enum PlayerCountSlotConfig {
  zero([]),
  one([]),
  two([PlayerSlot.bottom, PlayerSlot.top]),
  three([PlayerSlot.bottom, PlayerSlot.left, PlayerSlot.right]),
  four([PlayerSlot.bottom, PlayerSlot.left, PlayerSlot.top, PlayerSlot.right]);

  final List<PlayerSlot> label;
  const PlayerCountSlotConfig(this.label);

  static PlayerCountSlotConfig fromPlayerCount(int count) =>
      PlayerCountSlotConfig.values.firstWhere((e) => e.index == count);
}
