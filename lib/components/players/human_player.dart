import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
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

    TextPaint textRender = TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
    playerName = TextComponent(
      text: "Player ${playerNum}",
      position: Vector2.all(0),
      anchor: Anchor.center,
      textRenderer: textRender,
    );
    add(playerName);
  }
}
