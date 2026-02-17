class GameSetupSettingsConstants {
  // Default values
  static const int defTotalPlayerCount = 2;
  static const int defAiPlayerCount = 0;
  static const int defAiDifficulty = 0;
  static const double defSfxVolume = .5;
  static const bool defIsMuted = false;
  static const double defBgmVolume = .5;
  static const bool defShowDeckDistribution = false;
  static const bool defShowFailureProbability = false;
  static const bool defShowOtherPlayersHand = false;
  static const double defWinningScore = 200;

  // Player Settings
  static const int totalPlayerCountMin = 2;
  static const int totalPlayerCountMax = 4;
  static const int aiPlayerCountMin = 0;
  static const int aiPlayerCountMax = 3;

  // Thinking easy medium hard expert
  static const int aiDifficultyMin = 0;
  static const int aiDifficultyMax = 3;

  // Game Options
  static const double winningScoreMin = 200;
  static const double winningScoreMax = 1000;

  //Audio Opetions
  static const double sfxMin = 0.0;
  static const double sfxMax = 1.0;

  static const double bgmMin = 0.0;
  static const double bgmMax = 1.0;
}
