import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/cards/card_holders.dart';
import 'package:six_seven/components/glowable_text.dart';
import 'package:six_seven/components/players/player.dart';

enum Difficulty {
  easy(1),
  medium(2),
  hard(3),
  expert(4);

  final int level;
  const Difficulty(this.level);
}

class CpuPlayer extends Player {
  //Difficulty is an integer from 1 to 3, from 1 easiest to 3 hardest
  late final Difficulty difficulty;
  CpuPlayer({required super.playerNum, required this.difficulty});

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
  }
}
