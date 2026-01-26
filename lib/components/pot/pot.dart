import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:six_seven/components/pot/counting_number.dart';
import 'package:six_seven/pages/game/game_screen.dart';
import 'package:six_seven/utils/event_completer.dart';

class Pot extends PositionComponent with HasGameReference<GameScreen> {
  late final double startScore;
  late double totalScore;
  late final CountingNumberComponent _totalScore;
  late final TextComponent _potLabel;
  EventCompleter? _completer;

  Pot({
    required this.startScore,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, anchor: Anchor.bottomCenter, size: size) {
    totalScore = startScore;
    priority = -1;

    _totalScore = CountingNumberComponent(
      value: startScore,
      duration: 1.0,
      position: Vector2(0, size.y * -3),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
      priority: priority,
    );

    _potLabel = TextComponent(
      text: "Pot",
      anchor: Anchor.center,
      position: Vector2.all(0),
      textRenderer: TextPaint(style: TextStyle(fontSize: 25)),
      priority: priority,
    );
  }

  void reset() {
    totalScore = startScore;
    _totalScore.updateNoAnimation(startScore);
  }

  Future<void> addToPot(double newScore) async {
    print("adding to pot");
    totalScore += .1 * newScore;
    _totalScore.updateValue(totalScore, continueFromCurrentValue: true);

    // Wait for score animation to finish
    await _totalScore.completer.wait();
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    add(_totalScore);
    add(_potLabel);
  }
}
