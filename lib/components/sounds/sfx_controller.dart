import 'package:flame_audio/flame_audio.dart';

class SfxController {
  SfxController._();
  static final SfxController instance = SfxController._();

  static const int _initPoolSize = 10;
  final List<(String, AudioPlayer)> _players =
      []; // String holds the file path as audio player loses this info

  /// Primes _initPoolSize amount of audio players to be ready to run
  Future<void> init() async {
    for (int i = 0; i < _initPoolSize; i++) {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      _players.add(("", player));
    }
  }

  /// Finds the next available index in players to add audio or reuse
  /// Returns (bool: reusing index, int: index in players)
  /// If reusing, just play the audio player at the index
  /// If not reusing, the index indicates a player that needs to be reloaded with new audio
  /// NOTE: List can get arbitratrily long if more than 10 sfx running at same time, as there is no clean up of empty space (but empty space can be reused)
  Future<(bool, int)> _findOpenCursor(String filename) async {
    int idx = 0;
    for (idx; idx < _players.length; ++idx) {
      final p = _players[idx];
      final pfilename = p.$1;
      final player = p.$2;

      // Player has no source file and isn't playing
      if (pfilename == filename) {
        // Player has finished
        if (player.state != PlayerState.playing) {
          if (player.state == PlayerState.disposed) {
            // Reload
            return (false, idx);
          }
          // Reuse
          return (true, idx);
        }
      } else {
        // Different audio has finished
        if (player.state != PlayerState.playing) {
          // Reload
          _players[idx] = (filename, _players[idx].$2);
          return (false, idx);
        }
      }
    }

    // Didn't find available slot create a new one
    final player = AudioPlayer();
    await player.setReleaseMode(ReleaseMode.stop);
    _players.add((filename, player));
    return (false, idx);
  }

  Future<void> play(String fileName, {double volume = 1.0}) async {
    try {
      final (bool, int) ret = await _findOpenCursor(fileName);
      late final AudioPlayer player;
      bool reuse = ret.$1;
      int index = ret.$2;
      player = _players[index].$2;

      if (reuse) {
        // reuse audio player
        await player.setVolume(volume);
        await player.resume();
      } else {
        final url = await FlameAudio.audioCache.load(fileName);
        await player.setVolume(volume);
        await player.play(DeviceFileSource(url.path));
      }
    } catch (e) {
      print("ERROR SFX controller - play - $e");
    }
  }

  /// Disposes all audio players
  Future<void> dispose() async {
    for (final p in _players) {
      await p.$2.dispose();
    }
    _players.clear();
  }
}
