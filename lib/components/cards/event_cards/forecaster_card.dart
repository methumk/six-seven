//Chosen player is told when the next 4 cards are, but not necessarily in the actual order that they will appear
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' as mat;
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class ForecasterCard extends EventActionCard {
  ForecasterCard() {
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
    await initCardIcon("game_ui/test.png");
    initDescriptionText(
      description:
          "Forecasts the next 4 cards, but not necessarily in the order that they will appear!",
      descriptionTitle: "Forecaster",
    );
  }

  @override
  Future<void> executeOnEvent() async {
    // If current player is null, return out
    if (game.gameManager.getCurrentPlayer == null) {
      resolveEventCompleter();
      return;
    }

    List<Card> cards = [];

    // draw 4 cards, shuffle them
    for (int i = 0; i < 4; ++i) {
      Card c = game.gameManager.deck.draw();
      cards.add(c);

      // Disable drag and tap movements
      c.toggleAllUserCardMovement(false);
      print("Drew card $c");
    }
    cards.shuffle();
    if (!game.gameManager.getCurrentPlayer!.isCpu()) {
      // Drawing 3 cards should show the cards in an animation in center
      await game.world.addAll(cards);

      // Start animation
      await _choiceDrawStartAnimation(cards);

      //
      // Reshuffle cards for extra measure, then re-add them to deck
      cards.shuffle();
      game.world.removeAll(cards);
    }
    //TO DO: If it was a CPU, have anims, but only show back cover of cards
    //so you can't see what each card actually is

    for (final card in cards) {
      card.resetCardSettings();
      game.gameManager.deck.putCardBack(card);
    }

    //CPU action logic is handled by gameManager because gameManager handles second choice logic
    // discard the card
    resolveEventCompleter();
  }

  Future<void> _choiceDrawStartAnimation(List<Card> cards) async {
    final Vector2 gameCenter = game.gameManager.rotationCenter;

    // Step 1: Move all cards to center (just fire and forget)
    for (final card in cards) {
      card.priority = 100;
      card.scale = Vector2.all(1.1);
      card.add(
        MoveEffect.to(
          gameCenter,
          EffectController(duration: 0.4, curve: mat.Curves.easeInOut),
        ),
      );
    }

    // Step 2: Fan them out (a bit later so it looks animated)
    await Future.delayed(const Duration(milliseconds: 400));
    const double spread = 240.0;
    final offsets = [-1.5 * spread, -0.5 * spread, 0.5 * spread, 1.5 * spread];

    for (var i = 0; i < cards.length && i < offsets.length; i++) {
      cards[i].add(
        MoveEffect.to(
          Vector2(gameCenter.x + offsets[i], gameCenter.y),
          EffectController(duration: 0.2, curve: mat.Curves.easeInOut),
        ),
      );
    }

    // Step 3: Wait 3 seconds total for the animations to be seen
    await Future.delayed(const Duration(seconds: 3));

    print('Animation complete and cards removed');
  }

  @override
  void description() {
    print(
      "${cardType.label} forecasts the next 4 cards, but not necessarily in the order that they will appear!",
    );
  }
}
