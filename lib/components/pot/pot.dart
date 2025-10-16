import 'dart:async';

import 'package:flame/components.dart';
import 'package:six_seven/components/pot/counting_number.dart';
import 'package:six_seven/pages/game/game_screen.dart';
import 'package:six_seven/utils/event_completer.dart';

class Pot extends PositionComponent with HasGameReference<GameScreen> {
  late final CountingNumberComponent _totalScore;
  EventCompleter? _completer;

  Pot({double startScore = 0, required Vector2 position, required Vector2 size})
    : super(position: position, anchor: Anchor.bottomCenter, size: size) {
    _totalScore = CountingNumberComponent(
      value: startScore,
      duration: 1.0,
      position: size / 2 + position,
    );
  }

  Future<void> addToPot(double newScore) async {
    _totalScore.updateValue(_totalScore.currValue + newScore);

    // Wait for score animation to finish
    await _totalScore.completer.wait();
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    add(_totalScore);
  }
}
