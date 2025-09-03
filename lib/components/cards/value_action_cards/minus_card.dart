import 'dart:ui';

import 'package:flame/components.dart';
import 'package:six_seven/components/cards/card.dart';

class MinusCard extends ValueActionCard {
  MinusCard({required super.value});

  @override
  double executeOnStay(double currentValue) {
    currentValue -= value;
    return currentValue;
  }

  @override
  void description() {
    print("${cardType.label} - $value");
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final rect = size.toRect();
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(Card.borderRadius),
    );
    canvas.drawRRect(rrect, paint);
  }
}
