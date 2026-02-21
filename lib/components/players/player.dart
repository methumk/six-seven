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
import 'package:six_seven/data/enums/player_slots.dart';
import 'package:six_seven/pages/game/game_screen.dart';
import 'package:six_seven/utils/data_helpers.dart';

enum PlayerStatus { active, bust, stay }

abstract class Player extends PositionComponent
    with HasGameReference<GameScreen>, TapCallbacks {
  // If a card forces user to hit a certain amount of times
  // Zero means they can hit or stay
  int mandatoryHits = 0;
  bool get mustHit => mandatoryHits > 0;

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
  late final GlowableText playerCurrentScore;
  late final GlowableText playerTotalScore;
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
          print("Player $playerNum has been chosen!");
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
    playerCurrentScore.updateText(
      "Round Score: ${roundAndStringify(currentValue)}",
    );
    playerTotalScore.updateText(
      "Actual Total: ${roundAndStringify(totalValue)}",
    );
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
      print("Bonus for 6 number cards!");
      currentValue += 6.7;
    }
    //Else if player  flipped >= 7 cards, get bonus 21.67 points (multiplier not included)
    if (nch.numHandSet.length >= 7) {
      print("Bonus for >=7 number cards!");
      currentValue += 21.67;
    }
    currentValue += currentBonusValue;

    //Both current value and total value are affected by tax multiplier
    //current value affected by tax in updateCurrentValue. total value affected by
    //tax multiplier on stay,bust
    currentValue *= taxMultiplier;
    updateTaxMultiplier();
    playerCurrentScore.updateText(
      "Round Score: ${roundAndStringify(currentValue)}",
    );
    playerTotalScore.updateText(
      "Actual Total: ${roundAndStringify(totalValue)}",
    );
  }

  //Calculates sum of number cards only
  double sumNumberCards() {
    double currentNumberValue = 0;
    for (double numberValue in nch.numHandSet) {
      currentNumberValue += numberValue;
    }
    return currentNumberValue;
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

  /// Set the deck nch or dch hands as draggable
  Future<void> setHandDraggable({
    bool enableNch = true,
    bool enableDch = true,
  }) async {
    if (isDone) return;
    await dch.setDraggable(enableDch);
    await nch.setDraggable(enableNch);
  }

  //Method for handling when player stays
  Future<void> handleStay() async {
    print("Handling stay");
    //Make status bool true
    status = PlayerStatus.stay;
    await setHandDraggable(enableDch: false, enableNch: false);

    // Set text as staying
    await playerActionText.setAsStaying();

    //Update current value to reflect final points accrued in this round
    updateCurrentValue();
    print("Does player have income tax: ${hasIncomeTax}");
    print("Current game round: ${game.gameManager.currentRound}");
    updateTaxMultiplier();
    print("Tax rate: ${taxMultiplier}");
    totalValue *= taxMultiplier;
    //Remove all cards from player's hand
    await handRemoval(saveScoreToPot: true);
    playerCurrentScore.updateText(
      "Round Score: ${roundAndStringify(currentValue)}",
    );
    playerTotalScore.updateText(
      "Actual Total: ${roundAndStringify(totalValue)}",
    );
  }

  //Method for discarding cards on bust/staying
  Future<void> handRemoval({bool saveScoreToPot = false}) async {
    if (saveScoreToPot) {
      game.gameManager.pot.addToPot(currentValue);
    }

    List<cd.Card> discardingHand = [];

    // Number hand gets discarded first, then all dch
    for (var c in nch.numberHand.reversed) {
      discardingHand.add(c as cd.Card);
    }
    for (var c in dch.cardHandOrder.reversed) {
      discardingHand.add(c);
    }

    // Let discard handle removing card from UI, no reason to update deck for DCH cuz all cards removed
    await nch.removeAllCards(removeFromUi: false);
    await dch.removeAllCards(removeFromUi: false, updateDeckPosition: false);

    // Animate each card going to discard
    await game.gameManager.deck.sendAllToDiscardPileAnimation(
      discardingHand,
      delayMs: 50,
    );
  }

  Future<void> transferCards(
    Player transferTo, {
    bool includeNumbers = false,
    bool includePlus = false,
    bool includeMinus = false,
    bool includeMult = false,
    bool includeEvent = false,
  }) async {
    // Iterate through number hand and transfer
    // NOTE: this might cause bust in the transfer player
    final nchLength = nch.getTotalHandLength();
    for (var i = nchLength - 1; i >= 0; i--) {
      final c = nch.numberHand[i];
      if (includeNumbers) {
        await nch.removeNumberCard(
          c,
          removeFromUi: true,
          updateDeckPosition: true,
        );
        bool duplicate = await transferTo.nch.animateCardArrival(c);
        if (duplicate) {
          // Duplicate should call bust of the player card is transferring to. The other cards will not be transferred
          await transferTo.bust();
          return;
        } else {
          // Add to backend if animation to card position is possible
          transferTo.nch.addCardtoHand(c);

          // Update current value after move for both players
          updateCurrentValue();
          transferTo.updateCurrentValue();
        }
      }
    }

    // Iterate through DCH and transfer
    final dchLength = dch.cardHandOrder.length;
    for (var i = dchLength - 1; i >= 0; i--) {
      final c = dch.cardHandOrder[i];
      bool removed = false;
      if (c is PlusCard && includePlus) {
        await dch.removePlusCard(
          c,
          removeFromUi: true,
          updateDeckPosition: true,
        );
        removed = true;
      } else if (c is MinusCard && includeMinus) {
        await dch.removeMinusCard(
          c,
          removeFromUi: true,
          updateDeckPosition: true,
        );
        removed = true;
      } else if (c is MultCard && includeMult) {
        await dch.removeMultCard(
          c,
          removeFromUi: true,
          updateDeckPosition: true,
        );
        removed = true;
      } else if (c is cd.HandEventActionCard && includeEvent) {
        await dch.removeEventCard(
          c,
          removeFromUi: true,
          updateDeckPosition: true,
        );
        removed = true;
      }

      // If card was removed then animate card movement and update values
      if (removed) {
        // Animate and move card
        await transferTo.dch.addCardtoHand(c);

        // Update current value after move for both players
        updateCurrentValue();
        transferTo.updateCurrentValue();
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
    mandatoryHits = 0;
    doubleChance = false;
    hasRedeemer = false;
    redeemerUsed = false;
    playerCurrentScore.updateText(
      "Round Score: ${roundAndStringify(currentValue)}",
    );
    playerTotalScore.updateText(
      "Actual Total: ${roundAndStringify(totalValue)}",
    );
    await playerActionText.removeText();
  }

  //Method for hitting
  Future<void> onHit(cd.Card newCard) async {
    //Reset size; this call is useful for handEventActionCards
    //such as Double Chance card
    newCard.resetSize();

    // Determine if card added to the hand caused it to bust
    if (newCard is cd.NumberCard) {
      await hitNumberCard(newCard);
    } else if (newCard is cd.ValueActionCard ||
        newCard is cd.HandEventActionCard) {
      await dch.addCardtoHand(newCard);
    }

    print("You hit and got a card: ");
    newCard.description();
    print(
      "DCH length: ${dch.getTotalHandLength()}, NCH: ${nch.getTotalHandLength()}",
    );

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
    await setHandDraggable(enableDch: false, enableNch: false);
    status = PlayerStatus.bust;
    await playerActionText.setAsBusted();
    await handRemoval(saveScoreToPot: true);
    currentValue = 0;
    currentBonusValue = 0;
    print("Does player have income tax: ${hasIncomeTax}");
    updateTaxMultiplier();
    print("Current game round: ${game.gameManager.currentRound > 1}");
    print("Tax rate: ${taxMultiplier}");
    //Do tax multiplier
    //tax multiplier is updated by value notifier on hasIncomeTax,
    //so player tax rate should be automatically calculated
    totalValue *= taxMultiplier;
    taxMultiplier = 1;
    mandatoryHits = 0;
    playerCurrentScore.updateText(
      "Round Score: ${roundAndStringify(currentValue)}",
    );
    playerTotalScore.updateText(
      "Actual Total: ${roundAndStringify(totalValue)}",
    );
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
    // Add card initially regardless
    bool cardIsDuplicate = await nch.animateCardArrival(nc);

    // Delay for UI effect
    await Future.delayed(Duration(milliseconds: 250));

    // Check the card for duplicate and special cases and return drawn number card if necessary
    //If the number card was a duplicate, check for the following special cases (below)
    if (cardIsDuplicate) {
      //If there was a minus card of the same magnitude, discard the minus card and the duplicate number card
      if (dch.minusCardInHand(nc.value)) {
        print(
          "You got a duplicate card, but you also have a minus card of the same value (${nc.value}) in magnitude! Hence that minus card cancels out the duplicate!",
        );

        // Let sendAllToDiscard handle ui removal, and update deck after discarding
        MinusCard? minusCard = await dch.removeSingleMinusCard(
          nc.value,
          removeFromUi: false,
          updateDeckPosition: false,
        );

        if (minusCard != null) {
          await game.gameManager.deck.sendAllToDiscardPileAnimation([
            minusCard,
            nc,
          ], delayMs: 50);
          // After card is discarded, then update the DCH
          await dch.updateCardPositionOnRemoval();
        }
      } //If player had double chance, discard it along with the duplicate
      else if (doubleChance) {
        print("Your card was a duplicate, but your double chance saved you!");

        doubleChance = false;
        // Let sendAllToDiscard handle ui removal, and update deck after discarding
        DoubleChanceCard? doubleChanceCard = await dch
            .removeDoubleChanceCardInHand(
              removeFromUi: false,
              updateDeckPosition: false,
            );

        if (doubleChanceCard != null) {
          await game.gameManager.deck.sendAllToDiscardPileAnimation([
            doubleChanceCard,
            nc,
          ], delayMs: 50);
          // After card is discarded, then update the DCH
          await dch.updateCardPositionOnRemoval();
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
        // Add card even though it's a duplicate so it can get removed manually
        nch.addCardtoHand(nc);

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

        //Multiply total score by income tax
        print("Does player have income tax: ${hasIncomeTax}");
        updateTaxMultiplier();
        print("Current game round: ${game.gameManager.currentRound > 1}");
        print("Tax rate: ${taxMultiplier}");
        totalValue *= taxMultiplier;
        playerCurrentScore.updateText(
          "Round Score: ${roundAndStringify(currentValue)}",
        );
        playerTotalScore.updateText(
          "Actual Total: ${roundAndStringify(totalValue)}",
        );
        print("Current value after 67%: ${currentValue}");
        //Remove all cards from player's hand
        await handRemoval(saveScoreToPot: true);
      } else {
        // Add card even though it's a duplicate so it can get removed manually
        nch.addCardtoHand(nc);
        await bust();
      }
    } else {
      // Safe to add to handle
      nch.addCardtoHand(nc);
    }
  }

  // Starts rotating player around given path
  Future<void> startRotation(
    List<Path> rotationPaths, {
    double rotationDuration = 1.5,
  }) async {
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
        onComplete: () async {
          _nextPlayerRotateEffect = null;
          _isRotating = false;

          await setHandDraggable(enableDch: true, enableNch: true);
        },
      );
      await add(_nextPlayerRotateEffect!);
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

  void updateTaxMultiplier() {
    //If income tax is true after round 1, calculate income tax
    if (hasIncomeTax && game.gameManager.currentRound > 1) {
      taxMultiplier = playerIncomeTaxRateAfterFirstRound(
        currentPlayer: this,
        playerRankings: game.gameManager.totalCurrentLeaderBoard.topN(
          game.gameManager.totalPlayerCount,
        ),
      );
    } else {
      taxMultiplier = 1.0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  String toString() {
    return ("P(#:${playerNum})");
    // return "P(isAi: ${isCpu()}, #:$playerNum, cv: $currentValue, bv: $currentBonusValue, tv: $totalValue)";
  }
}
