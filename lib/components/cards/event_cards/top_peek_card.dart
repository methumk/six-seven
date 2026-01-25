// Top peek: Can see the next card in the deck before making decision
import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' show Curves;
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class TopPeekCard extends EventActionCard {
  TopPeekCard()
    : super(
        imagePath: "game_ui/test.png",
        descripTitleText: "Top Peek",
        descripText:
            "The card user is allowed to take a peek at the next card in the deck!",
      ) {
    eventEnum = EventCardEnum.TopPeek;
  }

  //No special execute on stay
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  Future<void> peekTopCardAnimation() async {
    // Actually draw top card
    var top = await game.gameManager.deck.draw();

    // Make top invisible and add it to game tree
    top.isVisible = false;
    game.world.add(top);

    // Set visibility and location after it has been created
    top.startAtDeckSetting();

    // Animate to center
    await top.moveTo(
      game.gameManager.rotationCenter,
      EffectController(duration: .3),
    );
    await top.flip(duration: 0.3);
    await top.scaleBy(Vector2.all(1.2), EffectController(duration: .5));
    await top.scaleBy(
      Vector2.all(1.1),
      EffectController(
        duration: 0.7,
        reverseDuration: 0.5,
        curve: Curves.easeInOut,
        repeatCount: 3,
      ),
    );

    // Put card back into deck, removes card from ui, and updates card deck model
    await game.gameManager.deck.putBackToDeckAnimation(top);
  }

  @override
  Future<void> executeOnEvent() async {
    if (!cardUser!.isCpu()) {
      // Do peekCard animation, this will auto put the card back and remove it from parent
      await peekTopCardAnimation();
    }
    // TODO: handle another animation for players who don't get to see what the card is?

    resolveEventCompleter();
  }

  @override
  void description() {
    print(
      "${cardType.label} the card user is allowed to take a peek at the next card in the deck!",
    );
  }

  @override
  String toString() {
    return "Top Peek";
  }
}
