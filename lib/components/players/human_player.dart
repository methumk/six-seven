import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/cards/card.dart' as cd;
import 'package:six_seven/components/cards/card_holders.dart';
import 'package:six_seven/components/glowable_text.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/utils/data_helpers.dart';

class HumanPlayer extends Player {
  HumanPlayer({required super.playerNum, required super.currSlot});

  @override
  bool isCpu() {
    return false;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    nch = NumberCardHolder()..position = Vector2(0, button.radius * -.7);
    add(nch);

    dch = DynamicCardHolder()..position = Vector2(0, button.radius * -.7);
    add(dch);

    playerCurrentScore = GlowableText(
      smallTextSize: 9,
      smallColor: Colors.white,
      text: "Round Score: ${roundAndStringify(currentValue)}",
      position: Vector2(
        -button.radius - cd.Card.cardSize.x / 3.67,
        button.radius * -1.5 - cd.Card.cardSize.y,
      ),
    );
    add(playerCurrentScore);

    playerTotalScore = GlowableText(
      text: "Actual Total: ${roundAndStringify(totalValue)}",
      smallColor: Colors.white,
      smallTextSize: 9,
      position: Vector2(
        button.radius + cd.Card.cardSize.x / 3.67,
        button.radius * -1.5 - cd.Card.cardSize.y,
      ),
    );
    add(playerTotalScore);
  }
}
