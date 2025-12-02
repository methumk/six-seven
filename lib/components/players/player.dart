// import 'package:six_seven/components/cards/card.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/buttons/player_button.dart';
import 'package:six_seven/components/cards/card.dart' as cd;
import 'package:six_seven/components/cards/card_holders.dart';
import 'package:six_seven/components/cards/event_cards/double_chance_card.dart';
import 'package:six_seven/components/cards/event_cards/income_tax_card.dart';
import 'package:six_seven/components/cards/value_action_cards/minus_card.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart';
import 'package:six_seven/components/cards/value_action_cards/plus_card.dart';
import 'package:six_seven/components/glowable_text.dart';
import 'package:six_seven/components/players/overlays.dart/player_action_text.dart';
import 'package:six_seven/data/enums/event_cards.dart';
import 'package:six_seven/data/enums/player_slots.dart';
import 'package:six_seven/pages/game/game_screen.dart';
import 'package:six_seven/utils/data_helpers.dart';

enum PlayerStatus { active, bust, stay }

abstract class Player extends PositionComponent
    with HasGameReference<GameScreen>, TapCallbacks {
  double totalValue = 0;
  double currentValue = 0;
  double currentBonusValue = 0;
  double taxMultiplier = 1;
  PlayerStatus status = PlayerStatus.active;
  bool get isDone => status != PlayerStatus.active;

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

  //Bool for if player has double chance
  bool doubleChance = false;
  //bool for if player has redeemer
  bool hasRedeemer = false;
  //bool for if player had busted but redeemed 67%
  bool redeemerUsed = false;

  //bool for if player has an income tax card
  bool hasIncomeTax = false;

  late int playerNum;

  // UI Fields
  late final String playerName;
  late PlayerButton button;
  late final GlowableText playerScore;
  late final PlayerActionText playerActionText;

  Player({required this.playerNum, required this.currSlot})
    : super(anchor: Anchor.bottomCenter) {
    playerName = "Player $playerNum";
    moveToSlot = currSlot;
    button = PlayerButton(
      pos: Vector2(-20, 0),
      playerNum: playerNum,
      radius: 20,
      isCPU: isCpu(),
      onHit: () {
        if (button.buttonIsClickable) {
          final runningEvent = game.gameManager.runningEvent;
          runningEvent?.affectedPlayer = this;
          print("We're supposed to be robbing $playerNum");
          runningEvent?.inputSelect.resolve();
        } else {
          print("buttonIsClickable is false!");
        }
      },
    );
    add(button);
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
    print("Player has a redeemer card: ${hasRedeemer}");
    print("Tentative points from this round: $currentValue");
    print("Total points excluding this round: ${totalValue}");
  }

  // Update the bonus score
  void updateBonusValue(
    double additionalBonus, {
    bool clearExistingBonus = false,
  }) {
    currentValue -= currentBonusValue;
    if (clearExistingBonus) {
      currentBonusValue = additionalBonus;
    } else {
      currentBonusValue += additionalBonus;
    }
    currentValue += currentBonusValue;
    playerScore.updateText("Score: ${roundAndStringify(currentValue)}");
  }

  //Method for updating current value (might not be the final points of the round, just used for
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
    //Else if player  flipped >= 7 cards, get bonus 21.67 points (multiplier not included)
    if (nch.numHandSet.length >= 7) {
      currentValue += 21.67;
    }
    currentValue += currentBonusValue;

    if (hasIncomeTax && game.gameManager.currentRound > 1) {
      taxMultiplier = playerIncomeTaxRateAfterFirstRound(
        currentPlayer: this,
        playerRankings: game.gameManager.totalCurrentLeaderBoard.topN(
          game.gameManager.totalPlayerCount,
        ),
      );
      currentValue *= taxMultiplier;
    }
    playerScore.updateText("Score: ${roundAndStringify(currentValue)}");
  }

  // calculates the potential score if the given cards were added
  double calculatePlayerScoreWithCardsAdd({
    Set<cd.NumberCard> ncs = const {},
    List<MultCard> mlc = const [],
    List<PlusCard> pcs = const [],
    List<MinusCard> mnc = const [],
    List<cd.EventActionCard> eac = const [],
  }) {
    double potentialScore = 0;

    // Calculate number set
    for (double numberValue in nch.numHandSet) {
      potentialScore += numberValue;
    }
    for (var c in ncs) {
      potentialScore += c.value;
    }

    // Calculate mult card
    for (MultCard multCard in dch.multHand) {
      potentialScore = multCard.executeOnStay(potentialScore);
    }
    for (var c in mlc) {
      potentialScore = c.executeOnStay(potentialScore);
    }

    // Calculate plus cards
    for (PlusCard addCard in dch.addHand) {
      potentialScore = addCard.executeOnStay(potentialScore);
    }
    for (var c in pcs) {
      potentialScore = c.executeOnStay(potentialScore);
    }

    // Calculate minus card
    for (var minusValue in dch.minusHandMap.entries) {
      for (int i = 1; i <= minusValue.value.length; i++) {
        potentialScore -= minusValue.key;
      }
    }
    for (var c in mnc) {
      potentialScore -= c.value;
    }

    // Number hand bonus
    //If player flipped 6 cards, get bonus 6.7 points (multiplier not included)
    if (nch.numHandSet.length + ncs.length == 6) {
      potentialScore += 6.7;
    }
    //Else if player  flipped >= 7 cards, get bonus 21.67 points (multiplier not included)
    if (nch.numHandSet.length + ncs.length >= 7) {
      potentialScore += 21.67;
    }

    return potentialScore + currentBonusValue;
  }

  // calculates potential score if the given cards were removed
  double calculatePlayerScoreWithCardsRemoved({
    Set<double>? removedNumCards,
    List<MultCard>? removedMultCards,
    List<PlusCard>? removedPlusCards,
    List<cd.TaxHandEventActionCard>? removedTaxHandEventCards,
    Map<double, List<MinusCard>> minusCards = const {},
    required double hypotheticalTotalValue,
  }) {
    double potentialScore = 0;

    var newNumSet = Set.from(nch.numHandSet)..removeAll(removedNumCards ?? {});
    for (double numberValue in newNumSet) {
      potentialScore += numberValue;
    }
    //You must do mult cards before add card
    for (MultCard multCard in dch.multHand) {
      // if (multCards == null) {
      //   potentialScore = multCard.executeOnStay(potentialScore);
      //   print("MULT CARDS PROVIDED NULL | $potentialScore");
      // } else {
      //   if (!multCards.contains(multCard)) {
      //     potentialScore = multCard.executeOnStay(potentialScore);
      //     print("INCLUDING $multCard | $potentialScore");
      //   } else {
      //     print("NOT INCLUDING $multCard | $potentialScore");
      //   }
      // }
      if (removedMultCards == null || !removedMultCards.contains(multCard)) {
        potentialScore = multCard.executeOnStay(potentialScore);
      }
    }
    for (PlusCard addCard in dch.addHand) {
      // if (plusCards == null) {
      //   potentialScore = addCard.executeOnStay(potentialScore);
      //   print("PLUS CARDS PROVIDED NULL  | $potentialScore");
      // } else {
      //   if (!plusCards.contains(addCard)) {
      //     potentialScore = addCard.executeOnStay(potentialScore);
      //     print("INCLUDING $addCard | $potentialScore");
      //   } else {
      //     print("NOT INCLUDING $addCard | $potentialScore");
      //   }
      // }
      if (removedPlusCards == null || !removedPlusCards.contains(addCard)) {
        potentialScore = addCard.executeOnStay(potentialScore);
      }
    }
    for (var minusValue in dch.minusHandMap.entries) {
      int newLength =
          minusCards[minusValue.key] == null
              ? 0
              : minusCards[minusValue.key]!.length;
      for (int i = 0; i < minusValue.value.length - newLength; i++) {
        potentialScore -= minusValue.key;
      }
    }
    for (cd.EventActionCard handEventCard in dch.eventHand) {
      if (handEventCard is! cd.TaxHandEventActionCard) {
        continue;
      } else if (removedTaxHandEventCards == null ||
          !removedTaxHandEventCards.contains(handEventCard)) {
        double tentativeTaxMultiplier = handEventCard.playerTaxRate(
          currentPlayer: this,
        );
        potentialScore *= tentativeTaxMultiplier;
        hypotheticalTotalValue *= tentativeTaxMultiplier;
      }
    }

    //If player flipped 6 cards, get bonus 6.7 points (multiplier not included)
    if (newNumSet.length == 6) {
      potentialScore += 6.7;
    }
    //Else if player  flipped >= 7 cards, get bonus 21.67 points (multiplier not included)
    if (newNumSet.length >= 7) {
      potentialScore += 21.67;
    }

    return potentialScore + hypotheticalTotalValue + currentBonusValue;
  }

  //Method for handling when player stays
  Future<void> handleStay() async {
    print("Handling stay");
    //Make status bool true
    status = PlayerStatus.stay;

    // Set text as staying
    await playerActionText.setAsStaying();

    //Update current value to reflect final points accrued in this round
    updateCurrentValue();
    //Remove all cards from player's hand
    handRemoval(saveScoreToPot: true);
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
    game.gameManager.deck.addToDiscard(dch.eventHand);
    for (var minusCardList in dch.minusHandMap.values) {
      game.gameManager.deck.addToDiscard(minusCardList);
    }
    dch.removeAllCards();
  }

  // Will remove all plus cards from current hand and pass it to the transferTo player
  // NOTE: don't forget to update current value for both players manually
  void transferAddHand(Player transferToP, {bool updateDeckPosition = false}) {
    if (transferToP != this) {
      var remd = dch.removeAllAddHand(updateDeckPosition: updateDeckPosition);
      for (var c in remd) {
        transferToP.dch.addCardtoHand(c);
      }
    }
  }

  // Will remove all minus cards from current hand and pass it to the transferTo player
  // NOTE: don't forget to update current value for both players manually
  void transferMinusHand(
    Player transferToP, {
    bool updateDeckPosition = false,
  }) {
    if (transferToP != this) {
      var remd = dch.removeAllMinusHand(updateDeckPosition: updateDeckPosition);
      for (var c in remd) {
        transferToP.dch.addCardtoHand(c);
      }
    }
  }

  // Will remove all mult cards from current hand and pass it to the transferTo player
  // NOTE: don't forget to update current value for both players manually
  void transferMultHand(Player transferToP, {bool updateDeckPosition = false}) {
    if (transferToP != this) {
      var remd = dch.removeAllMultHand(updateDeckPosition: updateDeckPosition);
      for (var c in remd) {
        transferToP.dch.addCardtoHand(c);
      }
    }
  }

  //Method for resetting certain attributes
  Future<void> resetRound() async {
    status = PlayerStatus.active;
    totalValue += currentValue;
    currentValue = 0;
    currentBonusValue = 0;
    taxMultiplier = 1;
    hasIncomeTax = false;
    doubleChance = false;
    hasRedeemer = false;
    redeemerUsed = false;
    playerScore.updateText("Score: ${roundAndStringify(currentValue)}");
    await playerActionText.removeText();
  }

  //Method for hitting
  Future<void> onHit(cd.Card newCard) async {
    //Reset size; this call is useful for handEventActionCards
    //such as Double Chance card
    newCard.resetSize();
    print("You hit and got a card:");
    newCard.description();
    if (newCard is cd.NumberCard) {
      await hitNumberCard(newCard);
    } else if (newCard is cd.ValueActionCard) {
      dch.addCardtoHand(newCard);
    } else {
      // Only some event cards get added
      dch.addCardtoHand(newCard);
    }
    //If redeemer was used, current value was already updated. Player is done, will not update current value
    //for rest of the round. Return
    if (redeemerUsed) {
      redeemerUsed = false;
      return;
    } else {
      updateCurrentValue();
    }
  }

  //Method for when player busts
  Future<void> bust() async {
    print("Bust!");
    handRemoval(saveScoreToPot: true);
    currentValue = 0;
    currentBonusValue = 0;
    if (hasIncomeTax && game.gameManager.currentRound > 1) {
      taxMultiplier = playerIncomeTaxRateAfterFirstRound(
        currentPlayer: this,
        playerRankings: game.gameManager.totalCurrentLeaderBoard.topN(
          game.gameManager.totalPlayerCount,
        ),
      );
      totalValue *= taxMultiplier;
    }
    taxMultiplier = 1;
    status = PlayerStatus.bust;
    await playerActionText.setAsBusted();
  }

  //Grant player double chance status
  void grantDoubleChance() {
    doubleChance = true;
  }

  //Grant player redeemer status
  void grantRedeemer() {
    hasRedeemer = true;
  }

  //Grant player income tax
  void grantIncomeTax() {
    hasIncomeTax = true;
  }

  //sub-method for hitting a number card
  Future<void> hitNumberCard(cd.NumberCard nc) async {
    //If the number card was a duplicate, check for the following special cases (below)
    if (nch.numHandSet.contains(nc.value)) {
      //If there was a minus card of the same magnitude, discard the minus card and the duplicate number card
      if (dch.minusCardInHand(nc.value)) {
        print(
          "You got a duplicate card, but you also have a minus card of the same value (${nc.value}) in magnitude! Hence that minus card cancels out the duplicate!",
        );
        dch.removeSingleMinusCard(nc.value);
      } //If player had double chance, discard it along with the duplicate
      else if (doubleChance) {
        print("Your card was a duplicate, but your double chance saved you!");
        doubleChance = false;
        DoubleChanceCard? doubleChanceCard = dch.removeDoubleChanceCardInHand();
        if (doubleChanceCard != null) {
          game.gameManager.deck.addToDiscard([doubleChanceCard]);
        } //The following line is there for debugging purpose
        else {
          print(
            "You had doubleChance = True, but you did not have a Double Chance Card. This should not happen. Please Debug",
          );
        }
      } //If player had redeemer, let them redeem 67% of points
      else if (hasRedeemer) {
        print(
          "You got a duplicate number card and busted, but your redeemer card allowed you to redeem 67% of your current value of points!",
        );

        redeemerUsed = true;
        //Another niche for redeemer: if player was last, they are treated as if they stayed, and thus get access to the entire pot!
        //Make status bool true
        status = PlayerStatus.stay;
        // Set text as staying
        await playerActionText.setAsStaying();
        //Update current value to reflect final points accrued in this round
        updateCurrentValue();
        //make current value 67% after the updateCurrentValue call method
        print("Current Value before 67%: ${currentValue}");
        currentValue *= .67;
        playerScore.updateText("Score: ${roundAndStringify(currentValue)}");
        print("Current value after 67%: ${currentValue}");
        //Remove all cards from player's hand
        handRemoval(saveScoreToPot: true);
      } else {
        await bust();
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
    playerActionText = PlayerActionText(position: Vector2(0, -80));
    add(playerActionText);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  String toString() {
    return "Player(isAi: ${isCpu()}, #:$playerNum, cv: $currentValue, bv: $currentBonusValue, tv: $totalValue)";
  }
}
