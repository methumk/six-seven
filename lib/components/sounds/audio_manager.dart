import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  AudioManager._();
  static final AudioManager instance = AudioManager._();

  late double _bgmVolume;
  late double _sfxVolume;
  // late bool _isMuted;

  AudioManager() {
    _sfxVolume = .75;
    // _isMuted = false;
    _bgmVolume = .25;
  }

  Future<void> init() async {
    // Pre-cache everything so there's no playback delay
    await FlameAudio.audioCache.loadAll([
      // 'music/menu.mp3',
      'music/bgm.mp3',
      // 'sfx/jump.mp3',
      // 'sfx/shoot.mp3',
      // 'sfx/explosion.mp3',
      // 'sfx/coin.mp3',
    ]);

    FlameAudio.bgm.initialize();
  }

  //Getters
  get bgmVolume => _bgmVolume;
  get sfxVolume => _sfxVolume;
  set setSfxVolume(double newSfxVolume) {
    if (newSfxVolume < 0 || newSfxVolume > 1) {
      print("Sound Volume needs to be a double between 0,1");
      return;
    }
    _sfxVolume = newSfxVolume;
  }

  Future<void> playMusic(String filename) async {
    try {
      await FlameAudio.bgm.play(filename, volume: _bgmVolume);
    } catch (e) {
      print("Audio Manager playMusic - $e");
    }
  }

  Future<void> setBgmVolume(double newBgmVolume) async {
    try {
      _bgmVolume = newBgmVolume.clamp(0.0, 1.0);
      await FlameAudio.bgm.audioPlayer.setVolume(_bgmVolume);
    } catch (e) {
      print("Audio Manager setBgmVolume - $e");
    }
  }

  Future<void> stopMusic() async {
    try {
      await FlameAudio.bgm.stop();
    } catch (e) {
      print("Audio Manager stopMusic - $e");
    }
  }

  Future<void> pauseMusic() async {
    try {
      await FlameAudio.bgm.pause();
    } catch (e) {
      print("Audio Manager pauseMusic - $e");
    }
  }

  Future<void> resumeMusic() async {
    try {
      await FlameAudio.bgm.resume();
    } catch (e) {
      print("Audio Manager resumeMusic - $e");
    }
  }

  Future<void> switchMusic(String fileName) async {
    try {
      await FlameAudio.bgm.stop();
      await playMusic(fileName);
    } catch (e) {
      print("Audio Manager switchMusic - $e");
    }
  }

  // Destructor
  Future<void> onRemove() async {
    try {
      // soldierSfx.onRemove();
      // pupSfx.onRemove();
      await FlameAudio.bgm.dispose();
    } catch (e) {
      print("Audio Manager onRemove - $e");
    }
  }
}
