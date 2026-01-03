//Reverses turn order
import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' as mat;
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/players/overlays.dart/event_announcement_text.dart';
import 'package:six_seven/data/enums/event_cards.dart';
import 'package:six_seven/data/enums/player_rotation.dart';

class ReverseTurnCard extends EventActionCard {
  mat.Color announcementColor = mat.Colors.blue;
  late EventAnnouncementText announcementText;

  ReverseTurnCard()
    : super(
        imagePath: "game_ui/test.png",
        descripTitleText: "Reverse Turn",
        descripText: "Reverses turn order!",
      ) {
    eventEnum = EventCardEnum.ReverseTurn;
    announcementText = EventAnnouncementText(position: Vector2.all(0));
  }

  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    game.world.add(announcementText);
  }

  @override
  Future<void> executeOnEvent() async {
    // TODO: show animation for changing direction order
    game.gameManager.flipRotationDirection();

    var newRotation =
        game.gameManager.rotationDirection == PlayerRotation.clockWise
            ? "Clockwise"
            : "Counter Clock Wise";

    // Announcement
    await announcementText.setGrowingText(
      "Now Rotating $newRotation",
      45,
      announcementColor,
      appearDurationSec: 1.3,
      showInitRemoveAnimation: false,
      holdTextForMs: 800,
      shrinkAndRemoveAtEndSec: .9,
    );

    // Resolve event complete to stop waiting
    resolveEventCompleter();
  }

  @override
  void description() {
    print("${cardType.label} Reverses turn order!");
  }

  @override
  String toString() {
    return "Reverse Turn Card";
  }
}
