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

    playerName = GlowableText(
      smallTextSize: 15,
      smallColor: Colors.white,
      text: "Player $playerNum",
      position: Vector2.all(0),
    );
    add(playerName);

    nch = NumberCardHolder()..position = Vector2(0, playerName.size.y * -.7);
    add(nch);

    dch = DynamicCardHolder()..position = Vector2(0, playerName.size.y * -.7);
    add(dch);

    playerScore = GlowableText(
      smallTextSize: 13,
      smallColor: Colors.white,
      text: "Score: ${roundAndStringify(currentValue)}",
      position: Vector2(0, playerName.size.y * -1.5 - cd.Card.cardSize.y),
    );
    add(playerScore);
  }
}
