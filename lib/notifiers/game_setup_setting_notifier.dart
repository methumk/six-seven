import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:six_seven/data/constants/game_setup_settings_constants.dart';
import 'package:six_seven/data/game_setup_settings.dart';

class GameSetupSettingsNotifier extends Notifier<GameSetupSettings> {
  @override
  GameSetupSettings build() {
    // Initialize state
    return GameSetupSettings(
      totalPlayerCount: GameSetupSettingsConstants.defTotalPlayerCount,
      aiPlayerCount: GameSetupSettingsConstants.defAiPlayerCount,
      aiDifficulty: GameSetupSettingsConstants.defAiDifficulty,
      showDeckDistribution: GameSetupSettingsConstants.defShowDeckDistribution,
      showFailureProbability:
          GameSetupSettingsConstants.defShowFailureProbability,
      showOtherPlayersHand: GameSetupSettingsConstants.defShowOtherPlayersHand,
      winningScore: GameSetupSettingsConstants.defWinningScore,
    );
  }

  void updateTotalPlayerCount(int v) {
    state = state.copyWith(totalPlayerCount: v);
  }

  void updateAiPlayerCount(int v) {
    state = state.copyWith(aiPlayerCount: v);
  }

  void updateAiDifficulty(int v) {
    state = state.copyWith(aiDifficulty: v);
  }

  void updateShowDeckDistribution(bool v) {
    state = state.copyWith(showDeckDistribution: v);
  }

  void updateShowFailureProbability(bool v) {
    state = state.copyWith(showFailureProbability: v);
  }

  void updateShowOtherPlayersHand(bool v) {
    state = state.copyWith(showOtherPlayersHand: v);
  }

  void updateWinningScore(double v) {
    state = state.copyWith(winningScore: v);
  }
}

final gameSetupSettingProvider =
    NotifierProvider<GameSetupSettingsNotifier, GameSetupSettings>(
      GameSetupSettingsNotifier.new,
    );
