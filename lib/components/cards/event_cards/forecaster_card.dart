//Chosen player is told when the next 4 cards are, but not necessarily in the actual order that they will appear
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' as mat;
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class ForecasterCard extends EventActionCard {
  ForecasterCard()
    : super(
        imagePath: "game_ui/test.png",
        descripTitleText: "Forecaster",
        descripText:
            "Forecasts the next 4 cards, but not necessarily in the order that they will appear!",
      ) {
    eventEnum = EventCardEnum.Forecaster;
  }

  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
  }

  @override
  Future<void> executeOnEvent() async {
    // If current player is null, return out
    if (game.gameManager.getCurrentPlayer == null) {
      resolveEventCompleter();
      return;
    }

    List<Card> cards = [];

    // draw 4 cards and animate them moving to center
    for (int i = 0; i < 4; ++i) {
      Card c = await game.gameManager.deck.draw();
      cards.add(c);

      // Make cards initially false so it can be relocated to center before it's adedd
      c.isVisible = false;

      // Add card and start it at deck setting
      await game.world.add(c);
      c.startAtDeckSetting();

      // Go to game center
      await _goToGameCenter(c);
    }

    // Animate cards going to correct offset
    await _cardSpreadAnimation(cards);

    // After all cards drawn and in correct place then flip only for humans
    if (!game.gameManager.getCurrentPlayer!.isCpu()) {
      for (int i = 0; i < 4; ++i) {
        cards[i].flip(duration: 0.3);
      }
    }

    // Show cards for a bit before putting them back
    await Future.delayed(Duration(milliseconds: 2000));

    // Flip cards (only when shown - for human) and put back to center
    // this is done in two for loops, so the order in which they are put back in center is not known
    if (!game.gameManager.getCurrentPlayer!.isCpu()) {
      for (var card in cards) {
        if (!card.isFaceDown) {
          await card.flip(duration: 0.2);
        }
      }
    }
    // Put all in center at once
    for (var card in cards) {
      await _goToGameCenter(card);
    }

    // Shuffle card order before putting cards back in after animation has finished
    cards.shuffle();

    // Put cards back to deck
    for (final card in cards) {
      await game.gameManager.deck.putBackToDeckAnimation(card);
    }

    //CPU action logic is handled by gameManager because gameManager handles second choice logic
    // discard the card
    resolveEventCompleter();
  }

  // Animates going to center
  Future<void> _goToGameCenter(Card card) async {
    final Vector2 gameCenter = game.gameManager.rotationCenter;

    // Animate card getting bigger and going to center
    card.priority = 100;
    card.scaleTo(Vector2.all(1.1), EffectController(duration: 0.3));
    await card.moveTo(
      gameCenter,
      EffectController(duration: 0.4, curve: mat.Curves.easeInOut),
    );
  }

  // Animates card spread
  Future<void> _cardSpreadAnimation(List<Card> cards) async {
    final Vector2 gameCenter = game.gameManager.rotationCenter;

    const double spread = 240.0;
    final offsets = [-1.5 * spread, -0.5 * spread, 0.5 * spread, 1.5 * spread];

    // Move to offset
    for (var i = 0; i < cards.length; ++i) {
      await cards[i].moveTo(
        Vector2(gameCenter.x + offsets[i], gameCenter.y),
        EffectController(
          duration: 0.4,
          curve: mat.Curves.easeInOut,
          startDelay: 0.2,
        ),
      );
    }
  }

  @override
  void description() {
    print(
      "${cardType.label} forecasts the next 4 cards, but not necessarily in the order that they will appear!",
    );
  }
}
