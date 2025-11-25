import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' as mat;
import 'package:six_seven/components/buttons/text_button.dart';
import 'package:six_seven/pages/game/game_screen.dart';

class HitCount extends CircleComponent {
  late final TextComponent _hitText;
  int hitCount = 0;
  late final TextPaint textPaint;
  late final double showRadiusSize;
  late bool enabled;

  // Starts off hidden (radius 0)
  HitCount(
    Color color, {
    required super.position,
    required this.textPaint,
    required this.showRadiusSize,
  }) : super(anchor: Anchor.center, radius: 0, priority: 10) {
    enabled = false;

    paint = Paint()..color = color;

    // Starts off hidden, until set hit Count is called
    _hitText = TextComponent(
      priority: priority + 1,
      anchor: Anchor.center,
      textRenderer: textPaint,
    );
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // add(_textWrapper);
    await add(_hitText);
  }

  Future<void> hideHitCount() async {
    enabled = false;
    radius = 0;
    _hitText.text = "";
    _hitText.size = Vector2.all(0);
  }

  Future<void> showHitCount({int? newCount}) async {
    enabled = true;
    if (newCount != null) {
      hitCount = newCount;
    }
    radius = showRadiusSize;
    _hitText.size = Vector2.all(radius * 2);
    _hitText.position = Vector2.all(radius);
    _hitText.text = "$hitCount";
  }
}

class Hud extends PositionComponent with HasGameReference<GameScreen> {
  late final TextButton _stayBtn;
  late final TextButton _hitBtn;
  late final SpriteButtonComponent _backBtn;
  late final SpriteButtonComponent _settingBtn;
  late final SpriteButtonComponent? _probabilityBtn;
  late final bool enableProbability;

  // Number times player is able to hit continuously (UI only) - pops up as small circle notification over hit
  static const Color hitCountColor = mat.Colors.red;
  static const double hitCountRadius = 12;
  static const double hitCountFontSize = 12;
  late final HitCount _hitCount;
  int get currentHitCount => _hitCount.hitCount;

  bool hitAndStayDisabled = false;
  late final Image? _downBtnImg;
  late final Image? _upBtnImg;
  late final Image? _disableDownBtnImg;
  late final Image? _disableUpBtnImg;

  late Future<void> Function() stayPressed;
  late Future<void> Function() hitPressed;
  late Future<void> Function() backPressed;

  Completer<String>? _decisionCompleter;

  Future<String> waitForHitOrStay() {
    _decisionCompleter = Completer<String>();
    return _decisionCompleter!.future;
  }

  void _completeDecision(String decision) {
    if (_decisionCompleter != null && !_decisionCompleter!.isCompleted) {
      _decisionCompleter!.complete(decision);
    }
  }

  void setupButtonHandlers() {
    hitPressed = () async => _completeDecision('hit');
    stayPressed = () async => _completeDecision('stay');
  }

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

    Vector2 hitCountPos = Vector2(
      _hitBtn.position.x,
      _hitBtn.position.y - _hitBtn.size.y,
    );
    _hitCount = HitCount(
      mat.Colors.red,
      position: hitCountPos,
      showRadiusSize: hitCountRadius,
      textPaint: TextPaint(
        style: mat.TextStyle(
          color: mat.Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: hitCountFontSize,
          shadows: [
            const Shadow(
              offset: Offset(0, 0),
              blurRadius: hitCountFontSize,
              color: mat.Colors.black,
            ),
          ],
        ),
      ),
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
    addAll([_settingBtn, _backBtn, _stayBtn, _hitBtn, _hitCount]);

    setupButtonHandlers();
  }

  void disableHitAndStayBtns() {
    if (_disableUpBtnImg == null ||
        _disableDownBtnImg == null ||
        hitAndStayDisabled) {
      return;
    }

    // Disable hit count badge on disable
    _hitCount.hideHitCount();

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

  // If accumulate is set, the hitCount will be added to the existing hit count
  void setHitCountBadge(int hitCount, {bool accumulateHitCount = true}) {
    if (accumulateHitCount) {
      _hitCount.hitCount += hitCount;
    }
    _hitCount.showHitCount(newCount: hitCount);
  }

  // ResetHitCount will reset the hit count to specified value if null, otherwise original value will be preserved
  void hideHitCountBadge({int? resetHitCount}) {
    if (resetHitCount != null) {
      _hitCount.hitCount = resetHitCount;
    }
    _hitCount.hideHitCount();
  }
}
