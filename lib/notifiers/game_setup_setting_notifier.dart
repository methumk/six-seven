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
      sfxVolume: GameSetupSettingsConstants.defSfxVolume,
      isMuted: GameSetupSettingsConstants.defIsMuted,
      bgmVolume: GameSetupSettingsConstants.defBgmVolume,
      aiDifficulty: GameSetupSettingsConstants.defAiDifficulty,
      showDeckDistribution: GameSetupSettingsConstants.defShowDeckDistribution,
      showFailureProbability:
          GameSetupSettingsConstants.defShowFailureProbability,
      showOtherPlayersHand: GameSetupSettingsConstants.defShowOtherPlayersHand,
      winningScore: GameSetupSettingsConstants.defWinningScore,
    );
  }

  void updateTotalPlayerCount(int v) {
    final newAiCount = state.aiPlayerCount.clamp(
      GameSetupSettingsConstants.aiPlayerCountMin,
      v - 1,
    );

    state = state.copyWith(totalPlayerCount: v, aiPlayerCount: newAiCount);
  }

  void updateAiPlayerCount(int v) {
    final clampedAiCount = v.clamp(
      GameSetupSettingsConstants.aiPlayerCountMin,
      state.totalPlayerCount - 1,
    );
    state = state.copyWith(aiPlayerCount: clampedAiCount);
  }

  void updateSfxVolume(double v) {
    final clampedSfxVolume = v.clamp(
      GameSetupSettingsConstants.sfxMin,
      GameSetupSettingsConstants.sfxMax,
    );
    state = state.copyWith(sfxVolume: clampedSfxVolume);
  }

  void updateBgmVolume(double v) {
    final clampedBgmVolume = v.clamp(
      GameSetupSettingsConstants.bgmMin,
      GameSetupSettingsConstants.bgmMax,
    );
    state = state.copyWith(bgmVolume: clampedBgmVolume);
  }

  void updateMuteOption(bool v) {
    state = state.copyWith(isMuted: v);
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
