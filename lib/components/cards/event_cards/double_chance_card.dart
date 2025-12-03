import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/data/enums/event_cards.dart';
import 'package:six_seven/components/players/player.dart';

class DoubleChanceCard extends HandEventActionCard {
  DoubleChanceCard() {
    eventEnum = EventCardEnum.DoubleChance;
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
      description: "The player that gets chosen is granted double chance!",
      descriptionTitle: "Double Chance",
    );
  }

  //Grants double chance
  @override
  Future<void> executeOnEvent() async {
    if (!cardUser!.doubleChance) {
      cardUser?.grantDoubleChance();
      affectedPlayer = cardUser;
    } else {
      //See if there are any readily available players.
      List<Player> worstPlayers = game.gameManager.totalLeaderBoard.bottomN(
        game.gameManager.totalPlayerCount,
      );
      //If there is an available player, let affectedPlayer be that player.
      //For CPU players, this affectedPlayer will be their choice for who
      //will get double chance.
      for (Player player in worstPlayers) {
        if (!player.isDone && !player.doubleChance) {
          affectedPlayer = player;
          break;
        }
      }
      //If no one is available to have double chance,
      //that is, affected user is still null, return early
      if (affectedPlayer == null) {
        print("No remaining player can have the double chance card.");
        game.gameManager.deck.addToDiscard([this]);
        finishEventCompleter();
        return;
      }
      //Else, there is an available player to give double chance to.
      //We don't have to worry about CPU because they will automatically choose the worst
      //player available, in terms of total score, to give the double chance to
      //All that is left is to check if they are not CPU
      else if (!cardUser!.isCpu()) {
        bool validChoice = false;
        while (!validChoice) {
          await choosePlayer();
          //If chosen player is active and has double chance, it is valid!
          if (!affectedPlayer!.doubleChance && !affectedPlayer!.isDone) {
            validChoice = true;
          } else {
            print("Chosen player is not valid. Please try again");
          }
        }
        // We got user input. Signal to choosePlayer event is now completed.
        //Then proceed with action using that input (stealingFromPlayer set)
        //after the if statements
      }
      //If user is CPU, they already have an affectplayer, don't need a case for it
    }
    //Give double chance to affected player
    affectedPlayer!.grantDoubleChance();
    await affectedPlayer?.onHit(this);
    finishEventCompleter();
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} the player that gets chosen is granted double chance!",
    );
  }
}
