// import 'package:six_seven/components/cards/card.dart';
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/value_action_cards/minus_card.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart';
import 'package:six_seven/components/cards/value_action_cards/plus_card.dart';
import 'package:six_seven/components/highlightable_text.dart';
import 'package:six_seven/pages/game/game_screen.dart';

abstract class Player extends PositionComponent
    with HasGameReference<GameScreen>, TapCallbacks {
  double totalValue = 0;
  double currentValue = 0;
  bool isDone = false;
  Set<double> numHand = Set();
  List<NumberCard> numberHand = [];
  List<PlusCard> addHand = [];
  List<MultCard> multHand = [];
  List<MinusCard> minusHand = [];
  //Minus hands are special in that positive duplicates can be canceled
  //by a minus card of same value.
  //To have fast checks, we instead need a hashmap
  Map<double, int> minusHandMap = {};

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
    for (double numberValue in numHand) {
      print("Number card of value: ${numberValue}");
    }
    for (var minusValue in minusHandMap.entries) {
      print("Number card of value: ${minusValue.key}");
    }
    for (PlusCard addCard in addHand) {
      addCard.description();
    }
    for (MultCard multCard in multHand) {
      multCard.description();
    }
    print("Player has a double chance card? ${doubleChance}");
    print("Tentative points from this round: $currentValue");
    print("Total points excluding this round: ${totalValue}");
  }

  //Method for handling when player stays
  void handleStay() {
    currentValue = 0;
    for (double numberValue in numHand) {
      currentValue += numberValue;
    }
    //You must do mult cards before add card
    for (MultCard multCard in multHand) {
      currentValue = multCard.executeOnStay(currentValue);
    }
    for (PlusCard addCard in addHand) {
      currentValue = addCard.executeOnStay(currentValue);
    }
    for (var minusValue in minusHandMap.entries) {
      for (int i = 1; i <= minusValue.value; i++) {
        currentValue -= minusValue.key;
      }
    }
    //If player flipped 6 cards, get bonus 6.7 points (multiplier not included)
    if (numHand.length == 6) {
      currentValue += 6.7;
    }
    //Else if player  flipped >= 7 cards, get bonus 6*7 = 42 points (multiplier not included)
    if (numHand.length >= 7) {
      currentValue += 42;
    }
  }

  //Method for resetting certain attributes
  void reset() {
    numHand.clear();
    addHand.clear();
    multHand.clear();
    minusHand.clear();
    minusHandMap.clear();
    isDone = false;
    currentValue = 0;
    doubleChance = false;
  }

  //Method for hitting
  void onHit(Card newCard) {
    print("You hit and got a card:");
    newCard.description();
    if (newCard is NumberCard) {
      hitNumberCard(newCard.value);
    } else if (newCard is ValueActionCard) {
      hitValueActionCard(newCard);
    }
  }

  //Method for when player busts
  void bust() {
    print("Bust!");
    isDone = true;
  }

  //Grant player a double chance status
  void grantDoubleChance() {
    doubleChance = true;
  }

  //sub-method for hitting a number card
  void hitNumberCard(double numberValue) {
    if (numHand.contains(numberValue)) {
      if (minusHandMap.containsKey(numberValue) &&
          minusHandMap[numberValue]! >= 1) {
        print(
          "You got a duplicate card, but you also have a minus card of the same value in magnitude! Hence that minus card cancels out the duplicate!",
        );
        minusHandMap[numberValue] = minusHandMap[numberValue]! - 1;
      } else if (doubleChance) {
        print("Your card was a duplicate, but your double chance saved you!");
        doubleChance = false;
      } else {
        bust();
      }
    } else {
      numHand.add(numberValue);
    }
  }

  //Sub-method for hitting a value action card
  void hitValueActionCard(ValueActionCard newCard) {
    if (newCard is PlusCard) {
      addHand.add(newCard);
    } else if (newCard is MultCard) {
      multHand.add(newCard);
    } else if (newCard is MinusCard) {
      double minusValue = newCard.value;
      if (minusHandMap.containsKey(minusValue)) {
        minusHandMap[minusValue] = minusHandMap[minusValue]! + 1;
      } else {
        minusHandMap[minusValue] = 1;
      }
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
}
