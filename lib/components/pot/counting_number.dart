import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:six_seven/utils/data_helpers.dart';
import 'package:six_seven/utils/event_completer.dart';

class CountingNumberComponent extends TextComponent {
  double _startValue;
  double _targetValue;
  double _currentValue;
  double _progress = 1.0; // 1.0 = finished, 0.0 = just started
  double _duration; // total time for animation
  double _elapsed = 0.0;
  int decimals; // number of decimal places to show
  EventCompleter completer = EventCompleter();

  CountingNumberComponent({
    required double value,
    this.decimals = 2,
    double duration = 1.0, // seconds for full change
    super.position,
    super.textRenderer,
  }) : _startValue = value,
       _targetValue = value,
       _currentValue = value,
       _duration = duration,
       super(text: roundAndStringify(value));

  void updateNoAnimation(double newValue) {
    _startValue = newValue;
    _targetValue = newValue;
    _currentValue = newValue;
    text = roundAndStringify(newValue);
  }

  // continueFromCurrentValue will start the pot at the current value, Note this overrieds the _startValue
  void updateValue(
    double newValue, {
    double? duration,
    bool continueFromCurrentValue = false,
  }) {
    if ((newValue - _targetValue).abs() < 1e-9) return; // ignore tiny diffs

    // Update start value to current value if set
    if (continueFromCurrentValue) {
      _startValue = _currentValue;
    }

    completer.init();

    _targetValue = newValue;
    _elapsed = 0.0;
    _duration = duration ?? _duration;
    _progress = 0.0;

    // Optional: little "pop" when it changes
    add(
      ScaleEffect.to(
        Vector2.all(1.2),
        EffectController(
          duration: _duration / 2,
          reverseDuration: _duration / 2,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_progress >= 1.0) {
      completer.resolve();
      return;
    }

    _elapsed += dt;
    _progress = min(1.0, _elapsed / _duration);

    // Ease-out curve: starts fast, slows down near end
    final eased = Curves.easeOut.transform(_progress);

    _currentValue = _startValue + (_targetValue - _startValue) * eased;

    // text = _currentValue.toStringAsFixed(decimals);
    text = roundAndStringify(_currentValue);
  }

  double get currValue => _currentValue;
}
