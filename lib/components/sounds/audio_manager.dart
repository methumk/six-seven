import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  // late final SoldierFireSfx soldierSfx;
  // late final PowerUpSfx pupSfx;

  AudioManager._();
  static final AudioManager instance = AudioManager._();

  late double _bgmVolume;
  late double _sfxVolume;
  late bool _isMuted;
  AudioManager() {
    this._sfxVolume = .75;
    this._isMuted = false;
    this._bgmVolume = .25;
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
    //Set new sfx volume
    // soldierSfx.setSfxVolume = _sfxVolume;
    // pupSfx.setSfxVolume = _sfxVolume;
  }

  Future<void> playMusic(String filename) async {
    await FlameAudio.bgm.play(filename, volume: _bgmVolume);
  }

  Future<void> setBgmVolume(double newBgmVolume) async {
    _bgmVolume = newBgmVolume.clamp(0.0, 1.0);
    await FlameAudio.bgm.audioPlayer?.setVolume(_bgmVolume);
  }

  Future<void> stopMusic() async {
    await FlameAudio.bgm.stop();
  }

  Future<void> pauseMusic() async {
    await FlameAudio.bgm.pause();
  }

  Future<void> resumeMusic() async {
    await FlameAudio.bgm.resume();
  }

  Future<void> switchMusic(String fileName) async {
    await FlameAudio.bgm.stop();
    await playMusic(fileName);
  }

  //Destructor
  Future<void> onRemove() async {
    // soldierSfx.onRemove();
    // pupSfx.onRemove();
    await FlameAudio.bgm.dispose();
  }
}
