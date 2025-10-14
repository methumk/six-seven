import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/cards/card.dart' as cd;
import 'package:six_seven/components/cards/card_holders.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart'
    as cd;
import 'package:six_seven/components/cards/value_action_cards/plus_card.dart'
    as cd;
import 'package:six_seven/components/glowable_text.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/utils/data_helpers.dart';

enum Difficulty {
  easy(0),
  medium(1),
  hard(2),
  expert(3);

  final int level;
  const Difficulty(this.level);
}

Difficulty fromLevel(int level) =>
    Difficulty.values.firstWhere((d) => d.level == level);

class CpuPlayer extends Player {
  //Difficulty is an integer from 1 to 3, from 1 easiest to 3 hardest
  late final Difficulty difficulty;
  CpuPlayer({
    required super.playerNum,
    required this.difficulty,
    required super.currSlot,
  });

  @override
  bool isCpu() {
    return true;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    playerName = GlowableText(
      smallTextSize: 15,
      smallColor: Colors.green,
      text: "Player $playerNum",
      position: Vector2.all(0),
    );
    add(playerName);

    nch = NumberCardHolder()..position = Vector2(0, playerName.size.y * -.7);
    add(nch);

    dch = DynamicCardHolder()..position = Vector2(0, playerName.size.y * -.7);
    add(dch);

    playerScore = GlowableText(
      smallTextSize: 10,
      smallColor: Colors.white,
      text: roundAndStringify(currentValue),
      position: Vector2(0, playerName.size.y * -1.5 - cd.Card.cardSize.y),
    );
    add(playerScore);
  }

  //Method for if peeked card is a mult card.
  //If multiplier <1, is bad card so return true, else false
  bool isPeekedMultCardBad(cd.MultCard mc) {
    if (mc.value < 1) {
      print("Mult card has a multiplier <1. Stay!");
      return true;
    } else {
      print("Mult card has a multiplier >=1. Hit!");
      return false;
    }
  }

  //Method for if peeked card is a number card.
  //If it is a duplicate number card and will bust, return true, else false
  bool isPeekedNumberCardDuplicate(cd.NumberCard nc) {
    if (nch.numHandSet.contains(nc.value)) {
      if (dch.minusCardInHand(nc.value) || doubleChance) {
        print("No harm in hitting for ai");
        return false;
      } else {
        print("Next card will make cpu bust. Thus stay");
        return true;
      }
    } else {
      print("Number card is not a duplicate. Hit!");
      return false;
    }
  }
}
