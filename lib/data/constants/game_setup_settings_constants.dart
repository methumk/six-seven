class GameSetupSettingsConstants {
  // Default values
  static const int defTotalPlayerCount = 2;
  static const int defAiPlayerCount = 0;
  static const int defAiDifficulty = 0;
  static const bool defShowDeckDistribution = false;
  static const bool defShowFailureProbability = false;
  static const bool defShowOtherPlayersHand = false;
  static const double defWinningScore = 200;

  // Player Settings
  static const int totalPlayerCountMin = 2;
  static const int totalPlayerCountMax = 4;
  static const int aiPlayerCountMin = 0;
  static const int aiPlayerCountMax = 3;

  // Thinking easy medium hard right now
  static const int aiDifficultyMin = 0;
  static const int aiDifficultyMasx = 2;

  // Game Options
  static const double winningScoreMin = 200;
  static const double winningScoreMax = 1000;
}
