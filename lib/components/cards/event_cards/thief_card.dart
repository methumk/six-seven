//Thief: lets you choose a player and then steal all of their value action cards
import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/value_action_cards/minus_card.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart';
import 'package:six_seven/components/cards/value_action_cards/plus_card.dart';
import 'package:six_seven/components/players/overlays.dart/event_announcement_text.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class ThiefCard extends EventActionCard {
  Color announcementFailColor = Colors.red;
  Color announcementColor = Colors.blue;
  late EventAnnouncementText playerStealingAnnouncement;
  ThiefCard() {
    eventEnum = EventCardEnum.Thief;

    // Adding to world, so 0 will be center
    playerStealingAnnouncement = EventAnnouncementText(
      position: Vector2.all(0),
    );
  }

  //No special execute on stay
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
          "You get to choose a player to steal all their value action cards!",
      descriptionTitle: "Thief",
    );
    game.world.add(playerStealingAnnouncement);
  }

  bool _canUseThiefOnPlayer(Player? p) {
    return p != null &&
        !p.isDone &&
        p.playerName != cardUser!.playerName &&
        p.dch.valueCardLength > 0;
  }

  bool canUseThiefCard() {
    int count = 0;
    for (var player in game.gameManager.players) {
      if (_canUseThiefOnPlayer(player)) {
        count++;
      }
    }
    return count > 0;
  }

  @override
  Future<void> executeOnEvent() async {
    bool canUse = canUseThiefCard();
    if (!canUse) {
      print("No players to select for thief!");
      await playerStealingAnnouncement.setGrowingText(
        "No players with value action cards to steal from!",
        45,
        announcementFailColor,
        appearDurationSec: 1.3,
        showInitRemoveAnimation: false,
        holdTextForMs: 800,
        shrinkAndRemoveAtEndSec: .9,
      );
      finishEventCompleter();
      return;
    } else {
      print("Thief card can be used $canUse");
    }

    if (!cardUser!.isCpu()) {
      bool validChoice = false;
      while (!validChoice) {
        await choosePlayer(buttonClickVerf: _canUseThiefOnPlayer);
        if (!affectedPlayer!.isDone) {
          validChoice = true;
        } else {
          print(
            "Player you chose is already done! Please choose another player",
          );
        }
      }
      // // We got user input. Signal to choosePlayer event is now completed.
      // //Then proceed with action using that input (stealingFromPlayer set)
      // //after the if statements
      // finishEventCompleter();
    } else {
      print("card user is CPU: employing CPU action");
      //Since there's going to be a lot of event action cards, probably best
      //to just get the most optimal play for CPU regardless of CPU difficulty
      //Optimal play: let $X$ be the current value of all the number cards of the CPU card user.
      //Then for each active player not equal to the CPU card user, let $a$ be the cumulative multiplier
      //effect derived from multiplying every multiplier card from that active player ON TOP of the multiplier cards from card user,
      // and let $b$ be the cumulative sum value derived from summing every plus/minus card from that active player  ON TOP OF
      //the plus minus cards from the card user. (CPU isn't stealing yet, it is looking at
      //the hypothetical value it will get from stealing.). Store that player as the chosen player.
      //Then compute the hypothetical value $aX + b$ for that player. Iterate through the active players, and if there is anoyhter active player with a higher
      //$aX+b$ value, store that player instead. After the iteration, the chosen player who is left will be chosen for the card.

      double numberCardsValue = 0;
      for (NumberCard numberCard in cardUser!.numberHand) {
        numberCardsValue += numberCard.value;
      }
      //If numberCardsValue is $0$ because there are no number cards in user's hand yet,
      //Treat number cards value as $1$ such that multipliers can affect it
      if (numberCardsValue == 0) {
        numberCardsValue = 1;
      }
      double currentMultValue = 1;
      for (MultCard multCard in cardUser!.multHand) {
        currentMultValue *= multCard.value;
      }

      double currentPlusValue = 0;
      for (PlusCard plusCard in cardUser!.addHand) {
        currentPlusValue += plusCard.value;
      }

      double currentMinusValue = 0;
      for (List<MinusCard> minusCardList in cardUser!.minusHandMap.values) {
        for (MinusCard minusCard in minusCardList) {
          currentMinusValue -= minusCard.value;
        }
      }

      double currentHypotheticalValue =
          currentMultValue * numberCardsValue + currentPlusValue;

      affectedPlayer = cardUser;
      for (Player player in game.gameManager.players) {
        if (!player.isDone && player != cardUser) {
          double multipliers = 1;
          double plusMinusValues = 0;
          for (MultCard multCard in player.multHand) {
            multipliers *= multCard.value;
          }
          //Add current multipliers of card user
          multipliers *= currentMultValue;
          for (PlusCard plusCard in player.addHand) {
            plusMinusValues += plusCard.value;
          }
          //Add current plus values of card user
          plusMinusValues += currentPlusValue;
          for (List<MinusCard> minusCardList in player.minusHandMap.values) {
            for (MinusCard minusCard in minusCardList) {
              plusMinusValues -= minusCard.value;
            }
          }
          //Add current minus values of card user
          plusMinusValues -= currentMinusValue;

          //Calculate rival hypothetical value and compare it to the current hypothetical value
          double rivalHypotheticalValue =
              multipliers * numberCardsValue + plusMinusValues;
          print(
            "Current chosen player: ${affectedPlayer!.playerName}, total value: ${currentHypotheticalValue}",
          );
          print(
            "Rival player: ${player.playerName}, rival player's value: ${rivalHypotheticalValue}",
          );
          if (rivalHypotheticalValue >= currentHypotheticalValue) {
            affectedPlayer = player;
            currentHypotheticalValue = rivalHypotheticalValue;
          }
        }
      }
    }

    //For either human player or CPU player, the affectedUser is chosen. Proceed to steal the cards

    print("chosen player: ${affectedPlayer!.playerName}");
    //If affectedPlayer is the same as the cardUser, then there's
    //nothing to steal. Return early
    if (affectedPlayer == cardUser || affectedPlayer == null) {
      print("exiting early!");
      finishEventCompleter();
      return;
    }

    // Show chosen player as announcement
    await playerStealingAnnouncement.setGrowingText(
      "Player ${cardUser!.playerNum} stealing Player ${affectedPlayer!.playerNum} value cards!",
      45,
      announcementColor,
      appearDurationSec: 1.3,
      showInitRemoveAnimation: false,
      holdTextForMs: 800,
      shrinkAndRemoveAtEndSec: .9,
    );

    // Steal all value cards besides event
    affectedPlayer!.transferAddHand(cardUser!, updateDeckPosition: true);
    affectedPlayer!.transferMinusHand(cardUser!, updateDeckPosition: true);
    affectedPlayer!.transferMultHand(cardUser!, updateDeckPosition: true);

    // Update current status
    affectedPlayer?.updateCurrentValue();
    cardUser?.updateCurrentValue();

    // Signal to event completer
    finishEventCompleter();
  }

  @override
  void description() {
    print(
      "${cardType.label} you get to choose a player to steal all their value action cards!",
    );
  }

  @override
  String toString() {
    return "Thief Card";
  }
}
