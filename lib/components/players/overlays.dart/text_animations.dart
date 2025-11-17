import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class TextAnimations extends TextComponent {
  Future<void>? _currentAnimation; // track ongoing animation

  TextAnimations({
    required super.position,
    super.text = "",
    super.priority = 100,
    super.anchor = Anchor.center,
  }) {
    size = Vector2.all(0);
    scale = Vector2.all(0);
  }

  // =========================================================
  // Start Scaling animation
  // =========================================================
  // _animateScale = Adds the scale effect
  // _shrinkAndRemove = Optional function to handle shrinking and removing previous text
  // setScalingAnimation = Controlling function to handle the text scale animation
  Future<void> _animateScale(Vector2 targetScale, double durationSec) {
    final completer = Completer<void>();
    add(
      ScaleEffect.to(
        targetScale,
        EffectController(duration: durationSec, curve: Curves.easeOut),
        onComplete: () => completer.complete(),
      ),
    );
    return completer.future;
  }

  /// Shrinks text and optionally removes it
  Future<void> _shrinkAndRemove(double disappearDurationSec) async {
    // Wait for current animation to finish
    if (_currentAnimation != null) {
      await _currentAnimation;
    }

    _currentAnimation = _animateScale(Vector2.all(0), disappearDurationSec);
    await _currentAnimation;
    text = "";
    size = Vector2.all(0);
    _currentAnimation = null;
  }

  Future<void> setScalingAnimation(
    String newText,
    TextPaint textStyle, {
    bool showInitialRemoveAnimation = false,
    double textAppearForSec = 1.0,
    Vector2? startScale,
    Vector2? endScale,
    double? initRemoveAnimationSec,
    int? holdTextForMs,
    double? shrinkAndRemoveAtEndSec,
  }) async {
    if (text == newText) return; // skip if same text

    // Optionally show animation of old text being shrunk and removed
    if (showInitialRemoveAnimation &&
        initRemoveAnimationSec != null &&
        initRemoveAnimationSec > 0) {
      await _shrinkAndRemove(initRemoveAnimationSec);
    }

    // Update text style and text
    if (startScale != null) {
      scale = startScale;
    }
    endScale ??= Vector2.all(1);
    textRenderer = textStyle;
    text = newText;

    // Animate pop-in
    _currentAnimation = _animateScale(endScale, textAppearForSec);
    await _currentAnimation;
    _currentAnimation = null;

    // if hold text set then text will remove after holding
    if (holdTextForMs != null) {
      // Do delay then chose to shrink or just remove
      await Future.delayed(Duration(milliseconds: holdTextForMs));

      // If shrink not enable then manually clear
      if (shrinkAndRemoveAtEndSec == null) {
        // this is already handled in shrink and remove
        text = "";
        size = Vector2.all(0);
      }
    }

    // Shrink and remove text if desired
    if (shrinkAndRemoveAtEndSec != null) {
      await _shrinkAndRemove(shrinkAndRemoveAtEndSec);
    }
  }
  // =========================================================
  // End Scaling Animation Helpers
  // =========================================================

  // Remove Text
  Future<void> removeText() async {
    if (_currentAnimation != null) {
      await _currentAnimation;
    }

    text = "";
    size = Vector2.all(0);
    _currentAnimation = null;
  }
}
