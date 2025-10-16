// import 'package:six_seven/components/cards/card.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/cards/card.dart' as cd;
import 'package:six_seven/components/cards/card_holders.dart';
import 'package:six_seven/components/cards/event_cards/thief_card.dart';
import 'package:six_seven/components/cards/value_action_cards/minus_card.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart';
import 'package:six_seven/components/cards/value_action_cards/plus_card.dart';
import 'package:six_seven/components/glowable_text.dart';
import 'package:six_seven/data/enums/player_slots.dart';
import 'package:six_seven/pages/game/game_screen.dart';
import 'package:six_seven/utils/data_helpers.dart';

abstract class Player extends PositionComponent
    with HasGameReference<GameScreen>, TapCallbacks {
  double totalValue = 0;
  double currentValue = 0;
  bool isDone = false;
  late final NumberCardHolder nch;
  late final DynamicCardHolder dch;

  // rotation effect
  PlayerSlot currSlot;
  late PlayerSlot moveToSlot;
  SequenceEffect? _nextPlayerRotateEffect;
  bool _isRotating = false;
  bool get isRotating => _isRotating;

  Set<double> get numHandSet => nch.numHandSet;
  List<cd.NumberCard> get numberHand => nch.numberHand;
  List<PlusCard> get addHand => dch.addHand;
  List<MultCard> get multHand => dch.multHand;
  Map<double, List<MinusCard>> get minusHandMap => dch.minusHandMap;

  bool doubleChance = false;
  late int playerNum;

  // UI Fields
  late final GlowableText playerName;
  late ButtonComponent button;
  late CircleComponent physicalButton;
  //Bool for if button is clickable
  bool buttonIsClickable = false;
  late final GlowableText playerScore;

  Player({required this.playerNum, required this.currSlot})
    : super(anchor: Anchor.bottomCenter) {
    moveToSlot = currSlot;
    physicalButton = CircleComponent(
      radius: 14,
      paint:
          Paint()
            ..color =
                buttonIsClickable
                    ? Color.fromARGB(255, 122, 255, 255)
                    : Color.fromARGB(0, 255, 255, 255),
      children: [
        TextComponent(
          text: "Player $playerNum",
          textRenderer: TextPaint(
            style: const TextStyle(color: Colors.black, fontSize: 8),
          ),
          anchor: Anchor.center,
          position: Vector2(14, 14),
        ),
      ],
    );
    button = ButtonComponent(
      position: Vector2(10, -50),
      size: Vector2(14, 14),
      button: physicalButton,
      onPressed: () {
        if (buttonIsClickable) {
          final runningEvent = game.gameManager.runningEvent;
          runningEvent?.affectedPlayer = this;
          print("We're supposed to be robbing ${this.playerNum}");
          runningEvent?.inputSelect.resolve();
        } else {
          print("buttonIsClickable is false!");
        }
      },
    );
    add(button);
  }
  //setter for buttonIsClickable
  set buttonClickStatus(bool buttonStatus) {
    buttonIsClickable = buttonStatus;
    physicalButton.paint =
        Paint()
          ..color =
              buttonIsClickable
                  ? const Color.fromARGB(255, 122, 255, 255)
                  : const Color.fromARGB(0, 255, 255, 255);
  }

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

  //Method for updating current value (might noy be the final points of the round, just used for
  //ev comparison)
  void updateCurrentValue() {
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
    playerScore.updateText("Score: ${roundAndStringify(currentValue)}");
  }

  //Method for handling when player stays
  void handleStay() {
    print("Handling stay");
    //Make isDone bool true
    isDone = true;
    //Update current value to reflect final points accrued in this round
    updateCurrentValue();

    //Add currentValue to total accumulated points from player in the game
    totalValue += currentValue;
    //Remove all cards from player's hand
    handRemoval(saveScoreToPot: false);
  }

  //Method for discarding cards on bust/staying
  void handRemoval({bool saveScoreToPot = false}) {
    if (saveScoreToPot) {
      game.gameManager.pot.addToPot(currentValue);
    }

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
  void onHit(cd.Card newCard) {
    print("You hit and got a card:");
    newCard.description();
    if (newCard is cd.NumberCard) {
      hitNumberCard(newCard);
    } else if (newCard is cd.ValueActionCard) {
      dch.addCardtoHand(newCard);
    } else {
      // Only some event cards get added
      dch.addCardtoHand(newCard);
    }
    updateCurrentValue();
  }

  //Method for when player busts
  void bust() {
    print("Bust!");
    isDone = true;
    handRemoval(saveScoreToPot: true);
  }

  //Grant player a double chance status
  void grantDoubleChance() {
    doubleChance = true;
  }

  //sub-method for hitting a number card
  void hitNumberCard(cd.NumberCard nc) {
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

  // Starts rotating player around given path
  void startRotation(
    List<Path> rotationPaths, {
    double rotationDuration = 1.5,
  }) {
    // Only setup rotation if nextPlayerRotate effect is null (if it isn't it's still running)
    if (rotationPaths.isEmpty) return;

    List<MoveAlongPathEffect> mp = [];
    double duration = rotationDuration / rotationPaths.length;
    for (final p in rotationPaths) {
      mp.add(MoveAlongPathEffect(p, EffectController(duration: duration)));
    }

    if (mp.isNotEmpty) {
      _isRotating = true;
      _nextPlayerRotateEffect = SequenceEffect(
        mp,
        onComplete: () {
          _nextPlayerRotateEffect = null;
          _isRotating = false;
        },
      );
      add(_nextPlayerRotateEffect!);
    }
  }

  // Must be overriden
  bool isCpu();

  @override
  void onTapUp(TapUpEvent event) async {
    super.onTapUp(event);
    print("onTapUp registered!");
    // final runningEvent = game.gameManager.runningEvent;
    // runningEvent?.affectedPlayer = this;
    // print("We're supposed to be robbing ${this.playerNum}");
    // runningEvent?.inputSelect.resolve();

    // final currentPlayer =
    //     game.gameManager.players[game.gameManager.currentPlayerIndex];

    // //For thief card only, can't really steal from self
    //However if you are the only player left, this if statement would
    //basically selflock the code, so comment for now
    // if (runningEvent is ThiefCard && currentPlayer != this) {
    //   runningEvent.stealingFromPlayer = this;
    //   runningEvent.resolveInputSelectedCompleted();
    // }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  bool get debugMode => true;
}
