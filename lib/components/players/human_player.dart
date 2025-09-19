import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/glowable_text.dart';
import 'package:six_seven/components/players/player.dart';

class HumanPlayer extends Player {
  HumanPlayer({required super.playerNum});

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
  }
}
