// import 'package:six_seven/components/cards/card.dart';
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/card_holders.dart';
import 'package:six_seven/components/cards/value_action_cards/minus_card.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart';
import 'package:six_seven/components/cards/value_action_cards/plus_card.dart';
import 'package:six_seven/components/glowable_text.dart';
import 'package:six_seven/pages/game/game_screen.dart';

abstract class Player extends PositionComponent
    with HasGameReference<GameScreen>, TapCallbacks {
  double totalValue = 0;
  double currentValue = 0;
  bool isDone = false;
  late final NumberCardHolder nch;
  late final DynamicCardHolder dch;

  Set<double> get numHandSet => nch.numHandSet;
  List<NumberCard> get numberHand => nch.numberHand;
  List<PlusCard> get addHand => dch.addHand;
  List<MultCard> get multHand => dch.multHand;
  Map<double, List<MinusCard>> get minusHandMap => dch.minusHandMap;

  bool doubleChance = false;
  late int playerNum;

  // Animation rotation
  Vector2? moveTo;
  double currAngle = 0;
  int rotateNum = 0;
  bool isRotating = false;

  // UI Fields
  late final GlowableText playerName;

  Player({required this.playerNum}) : super(anchor: Anchor.bottomCenter);

  //method for seeing own hand of cards
  void showHand() {
    print("You have: ");
    for (double numberValue in nch.numHandSet) {
      print("Number card of value: ${numberValue}");
    }
    for (var minusValue in dch.minusHandMap.entries) {
      print("Number card of value: ${minusValue.key}");
    }
    for (PlusCard addCard in dch.addHand) {
      addCard.description();
    }
    for (MultCard multCard in dch.multHand) {
      multCard.description();
    }
    print("Player has a double chance card? ${doubleChance}");
    print("Tentative points from this round: $currentValue");
    print("Total points excluding this round: ${totalValue}");
  }

  //Method for handling when player stays
  void handleStay() {
    print("Handling stay");
    //Make isDone bool true
    isDone = true;
    currentValue = 0;
    for (double numberValue in nch.numHandSet) {
      currentValue += numberValue;
    }
    //You must do mult cards before add card
    for (MultCard multCard in dch.multHand) {
      currentValue = multCard.executeOnStay(currentValue);
    }
    for (PlusCard addCard in dch.addHand) {
      currentValue = addCard.executeOnStay(currentValue);
    }
    for (var minusValue in dch.minusHandMap.entries) {
      for (int i = 1; i <= minusValue.value.length; i++) {
        currentValue -= minusValue.key;
      }
    }
    //If player flipped 6 cards, get bonus 6.7 points (multiplier not included)
    if (nch.numHandSet.length == 6) {
      currentValue += 6.7;
    }
    //Else if player  flipped >= 7 cards, get bonus 6*7 = 42 points (multiplier not included)
    if (nch.numHandSet.length >= 7) {
      currentValue += 42;
    }
    //Remove all cards from player's hand
    handRemoval();
  }

  //Method for discarding cards on bust/staying
  void handRemoval() {
    game.gameManager.deck.addToDiscard(nch.numberHand);
    nch.removeAllCards();
    game.gameManager.deck.addToDiscard(dch.addHand);
    game.gameManager.deck.addToDiscard(dch.multHand);
    for (var minusCardList in dch.minusHandMap.values) {
      game.gameManager.deck.addToDiscard(minusCardList);
    }
    dch.removeAllCards();
  }

  //Method for resetting certain attributes
  void reset() {
    isDone = false;
    currentValue = 0;
    doubleChance = false;
  }

  //Method for hitting
  void onHit(Card newCard) {
    print("You hit and got a card:");
    newCard.description();
    if (newCard is NumberCard) {
      hitNumberCard(newCard);
    } else if (newCard is ValueActionCard) {
      dch.addCardtoHand(newCard);
    } else {
      // Only some event cards get added
      dch.addCardtoHand(newCard);
    }
  }

  //Method for when player busts
  void bust() {
    print("Bust!");
    isDone = true;
    handRemoval();
  }

  //Grant player a double chance status
  void grantDoubleChance() {
    doubleChance = true;
  }

  //sub-method for hitting a number card
  void hitNumberCard(NumberCard nc) {
    if (nch.numHandSet.contains(nc.value)) {
      if (dch.minusCardInHand(nc.value)) {
        print(
          "You got a duplicate card, but you also have a minus card of the same value (${nc.value}) in magnitude! Hence that minus card cancels out the duplicate!",
        );
        dch.removeSingleMinusCard(nc.value);
      } else if (doubleChance) {
        print("Your card was a duplicate, but your double chance saved you!");
        doubleChance = false;
      } else {
        bust();
      }
    } else {
      nch.addCardtoHand(nc);
    }
  }

  // Each rotation represents 1/4 of a circle (note this circle is tilted though)
  void rotate(int numberRotations) {
    rotateNum = numberRotations;
    // isRotating = true;
  }

  void _handleRotate(double dt) {
    if (isRotating) {
      // isRotating = false;
    }
  }

  // Must be overriden
  bool isCpu();

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _handleRotate(dt);
  }

  @override
  bool get debugMode => true;
}
