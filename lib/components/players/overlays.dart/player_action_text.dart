// This is used to show hit/stay/bust
import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class PlayerActionText extends TextComponent {
  static const Color stayColor = Colors.yellow;
  static const Color bustColor = Colors.red;
  static const Color hitColor = Colors.green;
  static const Color shadowColor = Colors.white;

  static const double fontSize = 40;
  static const double startScale = 0.0;
  static const double endScale = 1.0;
  static const double appearDuration = 0.3; // seconds
  static const double disappearDuration = 0.2;
  static const int holdHitTimeMs = 850;

  static const String stayText = "Stay!";
  static const String hitText = "Hit!";
  static const String bustedText = "Busted!";

  late List<Shadow> shadows;
  Future<void>? _currentAnimation; // track ongoing animation

  PlayerActionText({required super.position})
    : super(anchor: Anchor.center, priority: 100) {
    text = "";
    size = Vector2.all(0);
    shadows = [
      const Shadow(offset: Offset(-2, 2), blurRadius: 3, color: shadowColor),
    ];
    scale = Vector2.all(startScale);
  }

  Future<void> _animateScale(Vector2 targetScale, double duration) {
    final completer = Completer<void>();
    add(
      ScaleEffect.to(
        targetScale,
        EffectController(duration: duration, curve: Curves.easeOut),
        onComplete: () => completer.complete(),
      ),
    );
    return completer.future;
  }

  /// Shrinks text and optionally removes it
  Future<void> _shrinkAndRemove() async {
    // Wait for current animation to finish
    if (_currentAnimation != null) {
      await _currentAnimation;
    }

    _currentAnimation = _animateScale(Vector2.all(0), disappearDuration);
    await _currentAnimation;
    text = "";
    size = Vector2.all(0);
    _currentAnimation = null;
  }

  Future<void> _setAnimated(
    String newText,
    Color color,
    int? holdTextForMs,
    bool showInitialRemoveAnimation,
  ) async {
    if (text == newText) return; // skip if same text

    if (showInitialRemoveAnimation) {
      await _shrinkAndRemove();
    }

    // Update text style
    textRenderer = TextPaint(
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        shadows: shadows,
      ),
    );

    text = newText;

    // Animate pop-in
    _currentAnimation = _animateScale(Vector2.all(endScale), appearDuration);
    await _currentAnimation;
    _currentAnimation = null;

    // Remove text (no animation)
    if (holdTextForMs != null) {
      await Future.delayed(Duration(milliseconds: holdTextForMs));
      text = "";
      size = Vector2.all(0);
    }
  }

  Future<void> removeText() async {
    if (_currentAnimation != null) {
      await _currentAnimation;
    }

    text = "";
    size = Vector2.all(0);
    _currentAnimation = null;
  }

  Future<void> setAsStaying({
    bool showRemoveAnimation = true,
    int? holdTextForMs,
  }) async =>
      _setAnimated("Stay!", stayColor, holdTextForMs, showRemoveAnimation);

  Future<void> setAsBusted({
    bool showRemoveAnimation = true,
    int? holdTextForMs,
  }) async =>
      _setAnimated("Busted!", bustColor, holdTextForMs, showRemoveAnimation);

  Future<void> setAsHitting({
    bool showRemoveAnimation = true,
    int? holdTextForMs = holdHitTimeMs,
  }) async =>
      _setAnimated("Hit!", hitColor, holdTextForMs, showRemoveAnimation);
}
