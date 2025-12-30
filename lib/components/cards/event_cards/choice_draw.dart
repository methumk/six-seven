//Choice draw: User draws three cards, chooses one card to keep, discards other card
import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart' as mat;
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/event_cards/double_chance_card.dart';
import 'package:six_seven/components/cards/event_cards/top_peek_card.dart';
import 'package:six_seven/components/cards/value_action_cards/minus_card.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart';
import 'package:six_seven/components/cards/value_action_cards/plus_card.dart';
import 'package:six_seven/components/players/cpu_player.dart';
import 'package:six_seven/data/enums/event_cards.dart';
import 'package:six_seven/components/players/player.dart';

class ChoiceDraw extends EventActionCard {
  // Signaling variable, to tell game manager's handleDrawCard, to draw the same event
  bool drawEventCardAgain = false;

  ChoiceDraw()
    : super(
        imagePath: "game_ui/test.png",
        descripTitleText: "Choice",
        descripText:
            "User draws three cards, and chooses one of the cards to keep while discarding the rest!",
      ) {
    eventEnum = EventCardEnum.ChoiceDraw;
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

  Future<void> _choiceDrawStartAnimation(List<Card> cards) async {
    final Vector2 gameCenter = game.gameManager.rotationCenter;
    // Move all cards to center
    for (final card in cards) {
      card.priority = 100; // ensure they're visible above everything
      card.scaleTo(Vector2.all(1.1), EffectController(duration: 0.3));
      await card.moveTo(
        gameCenter,
        EffectController(duration: 0.4, curve: mat.Curves.easeInOut),
      ); // custom tween helper
    }

    // Fan out cards
    const spread = 180.0; // pixel offset between cards
    final offsets = [-spread, 0, spread];
    for (int i = 0; i < offsets.length; i++) {
      // Move left and right cards only
      if (i != 1) {
        await cards[i].moveTo(
          Vector2(gameCenter.x + offsets[i], gameCenter.y),
          EffectController(duration: 0.2, curve: mat.Curves.easeInOut),
        );
      } else {
        // Simulate delay to keep flips uniform
        await Future.delayed(Duration(milliseconds: 200));
      }
      cards[i].flip(duration: 0.3);
    }
  }

  Future<Card> _determineAiChoice(
    List<Card> cards,
    CpuPlayer currPlayer,
  ) async {
    Difficulty aiDifficulty = currPlayer.difficulty;

    // Medium difficulty randomly decides to hard or random (easy) decision
    if (aiDifficulty == Difficulty.medium) {
      int medChoice = Random().nextInt(2);
      aiDifficulty = medChoice == 0 ? Difficulty.hard : Difficulty.easy;
    }

    if (aiDifficulty == Difficulty.expert || aiDifficulty == Difficulty.hard) {
      // Expert will take into consideration existing hand
      Card? selected;
      Card? potentialEventChoice;
      for (var card in cards) {
        if (selected == null) {
          selected = card;
        } else {
          // Only select double chance if there are no other better cards to get
          if (card is DoubleChanceCard && !currPlayer.doubleChance) {
            if (aiDifficulty == Difficulty.hard) return card;
            potentialEventChoice = card;
            continue;
          }
          // Always skip minus cards and event cards that are inherently negative
          if (card is MinusCard) {
            if (selected is MinusCard && selected.value > card.value) {
              selected = card;
            }
          }
          // Select only better event cards
          else if (card is EventActionCard) {
            // Hard difficutly ai will gamble on event, over a potentially better selected option
            if (aiDifficulty == Difficulty.hard) {
              if (Random().nextInt(2) == 0) {
                print("CPU randomly selected event $card");
                selected = card;
                continue;
              }
            } else {
              // TODO: update this section when adding more event cards
              if (potentialEventChoice == null) {
                potentialEventChoice = card;
              } else {
                // hierarchy of event cards we take greedily
                if (card is DoubleChanceCard) {
                  potentialEventChoice = card;
                } else if (card is TopPeekCard &&
                    potentialEventChoice is! DoubleChanceCard) {
                  potentialEventChoice = card;
                }
                // ... update with other event cards
              }
            }
          }
          // Handle plus cards (use heurisitic of plus cards greater than 4 being better than mult cards less than 1.2)
          else if (card is PlusCard) {
            if (aiDifficulty == Difficulty.hard ||
                selected is MinusCard ||
                (selected is PlusCard && selected.value < card.value)) {
              selected = card;
            } else if (selected is MultCard &&
                selected.value < 1.2 &&
                card.value > 4) {
              selected = card;
            }
          }
          // Handle mult cards (mult cards assumed to be worse than plus cards)
          else if (card is MultCard) {
            // Anything below 1 is useless, 1 might be helpful if all other options bad
            if (card.value <= 0.75) {
              continue;
            }
            if (aiDifficulty == Difficulty.hard ||
                selected is MinusCard ||
                (selected is MultCard && selected.value < card.value)) {
              selected = card;
            } else if (selected is PlusCard &&
                selected.value <= 4 &&
                card.value >= 1.2) {
              selected = card;
            }
          }
        }
      }

      // if selected is minus and event choice exists pick choice
      // Otherwise always pick selected
      if (aiDifficulty == Difficulty.expert &&
          selected! is MinusCard &&
          potentialEventChoice != null) {
        return potentialEventChoice;
      }
      return selected!;
    }

    // For easy randomly chose
    int cpuChoice = Random().nextInt(cards.length);
    return cards[cpuChoice];
  }

  @override
  Future<void> executeOnEvent() async {
    // If current player is null, return out
    if (game.gameManager.getCurrentPlayer == null) {
      resolveEventCompleter();
      return;
    }

    Player currPlayer = game.gameManager.getCurrentPlayer!;

    List<Card> cards = [];
    Card? selected;

    // draw 3 cards, let the user pick which one they key, and discard the rest
    for (int i = 0; i < 3; ++i) {
      Card c = game.gameManager.deck.draw();
      cards.add(c);

      // Hide card and then add it to world, then set default start at deck settings
      c.isVisible = false;
      await game.world.add(c);
      c.startAtDeckSetting();

      print("Drew card $c");
    }

    // // Drawing 3 cards should show the cards in an animation in center
    // await game.world.addAll(cards);

    // Start animation
    await _choiceDrawStartAnimation(cards);

    if (currPlayer.isCpu()) {
      // CPU Player
      selected = await _determineAiChoice(cards, currPlayer as CpuPlayer);
      print("CPU SELECTED $selected");

      // Show user which card CPU selected
      await Future.delayed(Duration(milliseconds: 500));
      selected.setBorderColor(mat.Colors.green);
      await Future.delayed(Duration(milliseconds: 800));
    } else {
      // Human Player
      // let the user pick which card they want through a selector
      // Allow tapping after animation to select cards
      final completer = Completer<Card>();
      for (final card in cards) {
        card.setClickable(true);
        card.onTapUpSelector = (Card c) async {
          if (!completer.isCompleted) completer.complete(c);
        };
      }

      // Selected card
      selected = await completer.future;
      print("SELECTED $selected");
    }

    // Remove unselected cards from view, Restore card setting changes, add to discard pile
    cards.remove(selected);
    await game.gameManager.deck.sendAllToDiscardPileAnimation(
      cards,
      flipTime: 0.3,
    );

    // Add card to hand, or start new event
    if (selected is NumberCard || selected is ValueActionCard) {
      print('Selected card is number getting added to number hand $selected');
      currPlayer.onHit(selected);
    } else {
      print("Selected card is event card $selected");

      // TODO: if we have choice_draw itself, we probably don't need a separate drawEventCardAgain
      // Tell game managers draw, we need to call handleDrawCard again
      drawEventCardAgain = true;
      await game.gameManager.deck.putBackToDeckAnimation(
        selected,
      ); // Put at top of deck (handle Draw, will pull from top deck with animation)
    }

    // discard the card
    resolveEventCompleter();
  }

  @override
  void description() {
    print(
      "${cardType.label} User draws three cards, and chooses one of the cards to keep while discarding the rest!",
    );
  }

  @override
  String toString() {
    return "Choice Draw";
  }
}
