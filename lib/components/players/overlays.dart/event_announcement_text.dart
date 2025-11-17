// This will be used to show a central event announcement message as a growing and shrinking animation
import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/players/overlays.dart/text_animations.dart';

class EventAnnouncementText extends TextAnimations {
  static const Color shadowColor = Colors.white;

  // Text shadow
  late List<Shadow> shadows;

  EventAnnouncementText({required super.position})
    : super(anchor: Anchor.center, priority: 100, text: "") {
    shadows = [
      const Shadow(offset: Offset(-2, 2), blurRadius: 3, color: shadowColor),
    ];
  }

  Future<void> setGrowingText(
    String setText,
    double fontSize,
    Color setcolor, {
    double startScale = 0,
    double endScale = 1.0,
    double appearDurationSec = 0.3,
    double initRemoveAnimationSec = 0.3,
    bool showInitRemoveAnimation = true,
    int? holdTextForMs,
    double? shrinkAndRemoveAtEndSec,
  }) async => await setScalingAnimation(
    setText,
    TextPaint(
      style: TextStyle(
        color: setcolor,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        shadows: shadows,
      ),
    ),
    showInitialRemoveAnimation: showInitRemoveAnimation,
    textAppearForSec: appearDurationSec,
    startScale: Vector2.all(startScale),
    endScale: Vector2.all(endScale),
    initRemoveAnimationSec: initRemoveAnimationSec,
    holdTextForMs: holdTextForMs,
    shrinkAndRemoveAtEndSec: shrinkAndRemoveAtEndSec,
  );
}
