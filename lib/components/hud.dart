import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:six_seven/components/buttons/text_button.dart';
import 'package:six_seven/pages/game/game_screen.dart';

class Hud extends PositionComponent with HasGameReference<GameScreen> {
  late final TextButton _stayBtn;
  late final TextButton _hitBtn;
  late final SpriteButtonComponent _backBtn;
  late final SpriteButtonComponent _settingBtn;
  late final SpriteButtonComponent? _probabilityBtn;
  late final bool enableProbability;

  bool hitAndStayDisabled = false;
  late final Image? _downBtnImg;
  late final Image? _upBtnImg;
  late final Image? _disableDownBtnImg;
  late final Image? _disableUpBtnImg;

  late Future<void> Function() stayPressed;
  late Future<void> Function() hitPressed;
  late Future<void> Function() backPressed;

  Hud({
    required this.hitPressed,
    required this.stayPressed,
    required this.backPressed,
    required this.enableProbability,
  });

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    _downBtnImg = await Flame.images.load("game_ui/button_down.png");
    _upBtnImg = await Flame.images.load("game_ui/button_up.png");
    _disableDownBtnImg = await Flame.images.load(
      "game_ui/disabled_btn_down.png",
    );
    _disableUpBtnImg = await Flame.images.load("game_ui/disabled_btn_up.png");
    final backBtnDownImg = await Flame.images.load("game_ui/back_btn_down.png");
    final backBtnUpImg = await Flame.images.load("game_ui/back_btn_up.png");
    final settingDownImg = await Flame.images.load("game_ui/setting_down.png");
    final settingUpImg = await Flame.images.load("game_ui/setting_up.png");

    // NOTE: with fixed resolution in game_screen.dart, the buttons will always stay in their correct position even with resolution update
    // Located on left
    _stayBtn = TextButton(
      text: "Stay",
      stayPressed: stayPressed,
      pos: Vector2(game.size.x * .05, game.size.y * .95),
      upBtnSize: Vector2(60, 18),
      upBtnImg: _upBtnImg!,
      downBtnSize: Vector2(60, 20),
      downBtnImg: _downBtnImg!,
      anchor: Anchor.bottomLeft,
      size: Vector2(120, 36),
    );

    // Located on right
    _hitBtn = TextButton(
      text: "Hit",
      stayPressed: hitPressed,
      pos: Vector2(game.size.x * .95, game.size.y * .95),
      upBtnSize: Vector2(60, 18),
      upBtnImg: _upBtnImg!,
      downBtnSize: Vector2(60, 20),
      downBtnImg: _downBtnImg!,
      anchor: Anchor.bottomRight,
      size: Vector2(120, 36),
    );

    _backBtn = SpriteButtonComponent(
      button: Sprite(backBtnUpImg, srcSize: Vector2(17, 18)),
      buttonDown: Sprite(backBtnDownImg, srcSize: Vector2(18, 20)),
      position: Vector2(game.size.x * .05, game.size.y * .05),
      anchor: Anchor.topLeft,
      size: Vector2(36, 36),
      onPressed: backPressed,
    );

    _settingBtn = SpriteButtonComponent(
      button: Sprite(settingUpImg, srcSize: Vector2(18, 20)),
      buttonDown: Sprite(settingDownImg, srcSize: Vector2(18, 20)),
      position: Vector2(game.size.x * .95, game.size.y * .05),
      anchor: Anchor.topRight,
      size: Vector2(36, 36),
    );

    print("Settings top right: ${_settingBtn.position}");
    if (enableProbability) {
      print("Adding probability button");
      final probDownImg = await Flame.images.load("game_ui/prob_down.png");
      final probUpImg = await Flame.images.load("game_ui/prob_up.png");

      _probabilityBtn = SpriteButtonComponent(
        button: Sprite(probUpImg, srcSize: Vector2(18, 20)),
        buttonDown: Sprite(probDownImg, srcSize: Vector2(18, 20)),
        position: Vector2(
          _settingBtn.position.x - _settingBtn.size.x - game.size.x * .01,
          game.size.y * .05,
        ),
        anchor: Anchor.topRight,
        size: Vector2(36, 36),
      );

      print("Probability top right: ${_probabilityBtn!.position}");
      add(_probabilityBtn);
    }
    add(_settingBtn);
    add(_backBtn);
    add(_stayBtn);
    add(_hitBtn);
  }

  void disableHitAndStayBtns() {
    if (_disableUpBtnImg == null ||
        _disableDownBtnImg == null ||
        hitAndStayDisabled)
      return;

    // Make the up and down both the disabled up, so it doesn't look clickable
    _stayBtn.changeImage(
      _disableUpBtnImg,
      _disableUpBtnImg,
      Vector2(60, 18),
      Vector2(60, 18),
    );
    _hitBtn.changeImage(
      _disableUpBtnImg,
      _disableUpBtnImg,
      Vector2(60, 18),
      Vector2(60, 18),
    );
    hitAndStayDisabled = true;
  }

  void enableHitAndStayBtns() {
    if (_upBtnImg == null || _downBtnImg == null || !hitAndStayDisabled) return;
    _stayBtn.changeImage(
      _upBtnImg,
      _downBtnImg,
      Vector2(60, 18),
      Vector2(60, 20),
    );
    _hitBtn.changeImage(
      _upBtnImg,
      _downBtnImg,
      Vector2(60, 18),
      Vector2(60, 20),
    );
    hitAndStayDisabled = false;
  }
}
