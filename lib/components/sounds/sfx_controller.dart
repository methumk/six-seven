import 'dart:collection';
import 'package:flame_audio/flame_audio.dart';

abstract class SfxController {
  late double sfxVolume;
  HashMap audioMap = HashMap();
  late bool isMuted;
  SfxController({required this.sfxVolume, required this.isMuted});

  void addSfx(String sfxName, String mp3) async {
    AudioPool sfx = await FlameAudio.createPool(
      mp3,
      minPlayers: 1,
      maxPlayers: 5,
    );
    audioMap[sfxName] = sfx;
  }

  set setSfxVolume(double newSfxVolume) {
    sfxVolume = newSfxVolume;
  }

  set changeMute(bool muteOption) {
    isMuted = muteOption;
  }

  Future<void> onLoad() async {}

  //Since SoundController doesn't extend any parent classes, we have to manually call this once game ends
  Future<void> onRemove() async {
    for (var sfx in audioMap.keys) {
      sfx.dispose();
    }
    FlameAudio.bgm.stop();
  }
}
