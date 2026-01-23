import 'dart:async';
import 'package:flutter/material.dart' as mat;
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/value_action_cards/minus_card.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart';
import 'package:six_seven/components/cards/value_action_cards/plus_card.dart';
import 'package:six_seven/components/players/cpu_player.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class DiscarderCard extends EventActionCard {
  DiscarderCard()
    : super(
        imagePath: "game_ui/test.png",
        descripTitleText: "Discarder",
        descripText:
            "You must remove one event or operator card from your hand.",
      ) {
    eventEnum = EventCardEnum.Discarder;
  }

  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    // await initCardIcon("game_ui/test.png");
    // initDescriptionText(
    //   description: "You must remove one event or operator card from your hand.",
    //   descriptionTitle: "Discarder",
    // );
  }

  Future<Card> _determineAiChoice(CpuPlayer currPlayer) async {
    // easy - random pick
    // medium/hard/expert
    Card? selected;
    double selectedScore = 0;
    List<Card> cardsInDeck = currPlayer.dch.getAsSingleList();

    print("Ai entire card length $cardsInDeck : ${cardsInDeck.length}");
    // Figure out which card to remove based on difficulty
    if (currPlayer.difficulty == Difficulty.easy) {
      // Make random choice
      cardsInDeck.shuffle();
      selected = cardsInDeck.removeLast();
    } else {
      // med/hard/expert always makes best move
      for (var c in cardsInDeck) {
        if (selected == null) {
          selected = c;
          if (selected is MinusCard) {
            print("SELECTED MINUS CARD");
            selectedScore = currPlayer.calculatePlayerScoreWithCardsRemoved(
              minusCards: {
                selected.value: [selected],
              },
              hypotheticalTotalValue: currPlayer.totalValue,
            );
          } else if (selected is MultCard) {
            print("SELECTED MULT CARD");
            selectedScore = currPlayer.calculatePlayerScoreWithCardsRemoved(
              removedMultCards: [selected],
              hypotheticalTotalValue: currPlayer.totalValue,
            );
          } else if (selected is PlusCard) {
            print("SELECTED PLUS CARD");
            selectedScore = currPlayer.calculatePlayerScoreWithCardsRemoved(
              removedPlusCards: [selected],
              hypotheticalTotalValue: currPlayer.totalValue,
            );
          }
          print(
            "AI selected initial card to remove as $c with score $selectedScore",
          );
        } else if (selected is TaxHandEventActionCard) {
          print("SELECTED TAX CARD");
          selectedScore = currPlayer.calculatePlayerScoreWithCardsRemoved(
            removedTaxHandEventCards: [selected],
            hypotheticalTotalValue: currPlayer.totalValue,
          );
        } else {
          double removalScore = 0;
          if (c is MinusCard) {
            removalScore = currPlayer.calculatePlayerScoreWithCardsRemoved(
              minusCards: {
                c.value: [c],
              },
              hypotheticalTotalValue: currPlayer.totalValue,
            );
          } else if (c is MultCard) {
            if (c.value == 0) {
              selected = c;
              break;
            }
            removalScore = currPlayer.calculatePlayerScoreWithCardsRemoved(
              removedMultCards: [c],
              hypotheticalTotalValue: currPlayer.totalValue,
            );
          } else if (c is PlusCard) {
            removalScore = currPlayer.calculatePlayerScoreWithCardsRemoved(
              removedPlusCards: [c],
              hypotheticalTotalValue: currPlayer.totalValue,
            );
          } else if (c is TaxHandEventActionCard) {
            currPlayer.calculatePlayerScoreWithCardsRemoved(
              removedTaxHandEventCards: [c],
              hypotheticalTotalValue: currPlayer.totalValue,
            );
          }

          // If removal creates bigger score
          if (removalScore > selectedScore) {
            print(
              "AI updating removal card from $selected to $c | score: $selectedScore --> $removalScore",
            );
            selectedScore = removalScore;
            selected = c;
          } else {
            print(
              "AI did not update selected card to curr card $selected to $c | score: $selectedScore <-- $removalScore",
            );
          }
        }
      }
    }

    // Wait and show border color change to indicate which card ai is removing
    // After delay of 1050 ms, return card to normal
    selected!.setBorderColor(mat.Colors.red);
    await Future.delayed(Duration(milliseconds: 1050));
    selected.resetCardSettings();

    return selected;
  }

  @override
  Future<void> executeOnEvent() async {
    // Check if current player has event or value card to be removed
    if (game.gameManager.getCurrentPlayer == null) {
      resolveEventCompleter();
      return;
    }
    Player currPlayer = game.gameManager.getCurrentPlayer!;

    // Don't continue if no cards in holder
    if (currPlayer.dch.isEmpty()) {
      print("No cards in DCH to discard - Early Return");
      resolveEventCompleter();
      return;
    }

    // Change border to show cards can be clicked
    currPlayer.dch.toggleCardShowSelectable(true, selectColor: mat.Colors.blue);
    print("Curr player $currPlayer now toggled ON DCH");

    // card expected to be set through the if statement
    late Card selected;

    // CPU and Human decision
    if (currPlayer.isCpu()) {
      print("DISCARDER - CPU DECISION");
      selected = await _determineAiChoice(currPlayer as CpuPlayer);
    } else {
      print("DISCARDER - HUMAN DECISION");
      currPlayer.dch.setCardsClickable(true);
      final completer = Completer<Card>();
      currPlayer.dch.setCardSelectedOnTapUp((Card c) async {
        if (!completer.isCompleted) completer.complete(c);
      });

      selected = await completer.future;
      currPlayer.dch.setCardsClickable(false);
    }

    // Remove selected card and update the value
    print("Discarding card: ${selected}");
    switch (selected.eventEnum) {
      case EventCardEnum.DoubleChance:
        currPlayer.doubleChance = false;
        break;
      case EventCardEnum.Redeemer:
        currPlayer.hasRedeemer = false;
        break;
      case EventCardEnum.IncomeTax:
        currPlayer.hasIncomeTax = false;
        currPlayer.taxMultiplier = 1.0;
      default:
        print("Selected card was not a handEventAction card. Continue onwards");
    }
    // Turn off border color that's used to indicate cards selectable
    currPlayer.dch.toggleCardShowSelectable(false);

    // First remove from hand backend, don't update deck position and keep the ui still there
    await currPlayer.dch.removeCard(
      selected,
      removeFromUi: false,
      updateDeckPosition: false,
    );

    // Update current handle value
    currPlayer.updateCurrentValue();

    // Update deck spacing after update
    await currPlayer.dch.updateCardPositionOnRemoval();

    // discard the card
    resolveEventCompleter();
  }

  @override
  void description() {
    print(
      "${cardType.label} User can choose to reverse the polarity for any of the value action cards in their hand.",
    );
  }
}
