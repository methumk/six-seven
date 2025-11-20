// This is used to show hit/stay/bust
import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/players/overlays.dart/text_animations.dart';

class PlayerActionText extends TextAnimations {
  static const Color stayColor = Colors.yellow;
  static const Color bustColor = Colors.red;
  static const Color hitColor = Colors.green;
  static const Color shadowColor = Colors.white;

  static const double fontSize = 40;
  static const double startScale = 0.0;
  static const double endScale = 1.0;
  static const double appearDurationSec = 0.3;
  static const double initRemoveAnimationSec = 0.2;
  static const int holdHitTimeMs = 800;

  static const String stayText = "Stay!";
  static const String hitText = "Hit!";
  static const String bustedText = "Busted!";

  // Text shadow
  late List<Shadow> shadows;

  PlayerActionText({required super.position})
    : super(anchor: Anchor.center, priority: 100, text: "") {
    shadows = [
      const Shadow(offset: Offset(-2, 2), blurRadius: 3, color: shadowColor),
    ];
  }

  Future<void> setAsStaying({
    bool showRemoveAnimation = true,
    int? holdTextForMs,
  }) async => await setScalingAnimation(
    "Stay!",
    TextPaint(
      style: TextStyle(
        color: stayColor,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        shadows: shadows,
      ),
    ),
    showInitialRemoveAnimation: showRemoveAnimation,
    textAppearForSec: appearDurationSec,
    startScale: Vector2.all(startScale),
    endScale: Vector2.all(endScale),
    initRemoveAnimationSec: initRemoveAnimationSec,
    holdTextForMs: holdTextForMs,
  );

  Future<void> setAsBusted({
    bool showRemoveAnimation = true,
    int? holdTextForMs,
  }) async => await setScalingAnimation(
    "Busted!",
    TextPaint(
      style: TextStyle(
        color: bustColor,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        shadows: shadows,
      ),
    ),
    showInitialRemoveAnimation: showRemoveAnimation,
    textAppearForSec: appearDurationSec,
    startScale: Vector2.all(startScale),
    endScale: Vector2.all(endScale),
    initRemoveAnimationSec: initRemoveAnimationSec,
    holdTextForMs: holdTextForMs,
    shrinkAndRemoveAtEndSec: 0.3,
  );

  Future<void> setAsHitting({
    bool showRemoveAnimation = true,
    int? holdTextForMs = holdHitTimeMs,
  }) async => await setScalingAnimation(
    "Hit!",
    TextPaint(
      style: TextStyle(
        color: hitColor,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        shadows: shadows,
      ),
    ),
    showInitialRemoveAnimation: showRemoveAnimation,
    textAppearForSec: appearDurationSec,
    startScale: Vector2.all(startScale),
    endScale: Vector2.all(endScale),
    initRemoveAnimationSec: initRemoveAnimationSec,
    holdTextForMs: holdTextForMs,
    shrinkAndRemoveAtEndSec: 0.3,
  );
}
