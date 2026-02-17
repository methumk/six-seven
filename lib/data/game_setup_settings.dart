class GameSetupSettings {
  // Player Settings
  int totalPlayerCount;
  int aiPlayerCount;
  // AI difficulty might be enum (e.g. easy, medium, hard)
  int aiDifficulty;

  //Audio Options
  double sfxVolume;
  bool isMuted;
  double bgmVolume;
  // Game Options
  bool showDeckDistribution;
  bool showFailureProbability;
  bool showOtherPlayersHand;
  double winningScore;

  GameSetupSettings({
    required this.totalPlayerCount,
    required this.aiPlayerCount,
    required this.aiDifficulty,
    required this.sfxVolume,
    required this.isMuted,
    required this.bgmVolume,
    required this.showDeckDistribution,
    required this.showFailureProbability,
    required this.showOtherPlayersHand,
    required this.winningScore,
  });

  GameSetupSettings copyWith({
    int? totalPlayerCount,
    int? aiPlayerCount,
    int? aiDifficulty,
    double? sfxVolume,
    bool? isMuted,
    double? bgmVolume,
    bool? showDeckDistribution,
    bool? showFailureProbability,
    bool? showOtherPlayersHand,
    double? winningScore,
  }) {
    return GameSetupSettings(
      totalPlayerCount: totalPlayerCount ?? this.totalPlayerCount,
      aiPlayerCount: aiPlayerCount ?? this.aiPlayerCount,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      bgmVolume: bgmVolume ?? this.bgmVolume,
      isMuted: isMuted ?? this.isMuted,
      showDeckDistribution: showDeckDistribution ?? this.showDeckDistribution,
      showFailureProbability:
          showFailureProbability ?? this.showFailureProbability,
      showOtherPlayersHand: showOtherPlayersHand ?? this.showOtherPlayersHand,
      winningScore: winningScore ?? this.winningScore,
    );
  }
}
