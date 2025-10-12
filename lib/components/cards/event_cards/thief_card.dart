//Thief: lets you choose a player and then steal all of their value action cards
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
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
    //To do: implement

    // Wait for user to select input
    // We expect input to be set when this is reolved
    await game.gameManager.runningEvent!.waitForInputSelectedCompletion();

    // We got user input... proceed with action using that input (stealingFromPlayer set)
    if (affectedPlayer?.addHand != null) {
      final List<PlusCard> addHand = affectedPlayer!.addHand;
      while (addHand != []) {
        PlusCard addCard = addHand.removeLast();
        cardUser?.dch.addCardtoHand(addCard);
      }
    }
    if (affectedPlayer?.multHand != null) {
      final List<MultCard> multHand = affectedPlayer!.multHand;
      while (multHand != []) {
        MultCard multCard = multHand.removeLast();
        cardUser?.dch.addCardtoHand(multCard);
      }
    }

    //Should player have a choice in whether they want to get negative cards too or not?
    //Currently, minusHand not included in the robbery, tentative. -Sean
    await game.gameManager.runningEvent!.waitForEventCompletion();
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} you get to choose a player to steal all their value action cards!",
    );
  }
}
