import 'dart:collection';

import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  // late final SoldierFireSfx soldierSfx;
  // late final PowerUpSfx pupSfx;

  late double _bgmVolume;
  late double _sfxVolume;
  late bool _isMuted;
  late AudioPlayer _bgmPlayer;
  AudioManager() {
    this._sfxVolume = .75;
    this._isMuted = false;
    this._bgmVolume = .25;
  }

  Future<void> onLoad() async {
    //SoldierSfx
    // soldierSfx = SoldierFireSfx(sfxVolume: _sfxVolume, isMuted: _isMuted);
    // soldierSfx.onLoad();

    // //PowerUpSfx
    // pupSfx = PowerUpSfx(sfxVolume: _sfxVolume, isMuted: _isMuted);
    // pupSfx.onLoad();

    //Bgm
    _bgmPlayer = AudioPlayer();
    print("Loaded audio!");
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

  Future<void> playBgm() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.stop();
    await _bgmPlayer.play(AssetSource('audio/music.mp3'), volume: _bgmVolume);
  }

  Future<void> setBgmVolume(double newBgmVolume) async {
    if (newBgmVolume < 0 || newBgmVolume > 1) {
      print("BGM Volume needs to be a double between 0,1");
      return;
    }
    _bgmVolume = newBgmVolume;
    await _bgmPlayer.setVolume(_bgmVolume);
  }

  //Pause music
  Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
  }

  //Resume music
  Future<void> resumeBgm() async {
    await _bgmPlayer.resume();
  }

  //Stop music
  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  //Destructor
  Future<void> onRemove() async {
    // soldierSfx.onRemove();
    // pupSfx.onRemove();
    await _bgmPlayer.dispose();
  }
}
