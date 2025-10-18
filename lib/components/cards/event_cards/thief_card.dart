//Thief: lets you choose a player and then steal all of their value action cards
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/value_action_cards/minus_card.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart';
import 'package:six_seven/components/cards/value_action_cards/plus_card.dart';
import 'package:six_seven/components/players/player.dart';

class ThiefCard extends EventActionCard {
  ThiefCard();
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
  }

  @override
  Future<void> executeOnEvent() async {
    if (!cardUser!.isCpu()) {
      await choosePlayer();
      // We got user input. Signal to choosePlayer event is now completed.
      //Then proceed with action using that input (stealingFromPlayer set)
      //after the if statements
      finishEventCompleter();
    } else {
      print("card user is CPU: employing CPU action");
      //Since there's going to be a lot of event action cards, probably best
      //to just get the most optimal play for CPU regardless of CPU difficulty
      //Optimal play: let $X$ be the current value of all the number cards of the CPU card user.
      //Then for each active player not equal to the CPU card user, let $a$ be the cumulative multiplier
      //effect derived from multiplying every multiplier card from that active player, and let $b$ be the cumulative
      //sum value derived from summing every plus/minus card from that active player (CPU isn't stealing yet, it is looking at
      //the hypothetical value). Store that player as the chosen player.
      //Then compute the hypothetical value $aX + b$ for that player. Iterate through the active players, and if there is anoyhter active player with a higher
      //$aX+b$ value, store that player instead. After the iteration, the chosen player who is left will be chosen for the card.

      double currentHypotheticalValue = cardUser!.currentValue;

      //We need to calculate X, the number card values of cardUser, here.
      //If there is more than one event action card, it might be better to
      //have this be an attribute for player instead. -Sean
      double numberCardsValue = 0;
      for (NumberCard numberCard in cardUser!.numberHand) {
        numberCardsValue += numberCard.value;
      }

      affectedPlayer = cardUser;
      for (Player player in game.gameManager.players) {
        if (!player.isDone) {
          double multipliers = 1;
          double plusMinusValues = 0;
          for (MultCard multCard in player.multHand) {
            multipliers *= multCard.value;
          }
          for (PlusCard plusCard in player.addHand) {
            plusMinusValues += plusCard.value;
          }
          for (List<MinusCard> minusCardList in player.minusHandMap.values) {
            for (MinusCard minusCard in minusCardList) {
              plusMinusValues -= minusCard.value;
            }
          }
          double rivalHypotheticalValue =
              multipliers * numberCardsValue + plusMinusValues;
          if (rivalHypotheticalValue >= currentHypotheticalValue) {
            affectedPlayer = player;
          }
        }
      }
    }
    //If affectedPlayer is the same as the cardUser, then there's
    //nothing to steal. Return early
    if (affectedPlayer == cardUser) {
      return;
    }

    //Else, steal all the value cards
    if (affectedPlayer?.addHand != null) {
      final List<PlusCard> addHand = affectedPlayer!.addHand;
      while (addHand.isNotEmpty) {
        PlusCard addCard = addHand.removeLast();
        cardUser?.dch.addCardtoHand(addCard);
      }
    }
    if (affectedPlayer?.multHand != null) {
      final List<MultCard> multHand = affectedPlayer!.multHand;
      while (multHand.isNotEmpty) {
        MultCard multCard = multHand.removeLast();
        cardUser?.dch.addCardtoHand(multCard);
      }
    }
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} you get to choose a player to steal all their value action cards!",
    );
  }
}
