//Choice draw: User can choose to reverse the polarity for any of the value action cards in their hand
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class RedeemerCard extends HandEventActionCard {
  RedeemerCard() {
    eventEnum = EventCardEnum.Redeemer;
  }

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
          "User will have this card for the remainder the round. If they get a duplicate number card, instead of busting, they get 67% of the points from the round (not including duplicate)!",
      descriptionTitle: "Redeemer",
    );
  }

  //Grants redeemer
  @override
  Future<void> executeOnEvent() async {
    if (!cardUser!.hasRedeemer) {
      cardUser?.grantRedeemer();
      affectedPlayer = cardUser;
    } else {
      //See if there are any readily available players.
      List<Player> worstPlayers = game.gameManager.endGameLeaderBoard.bottomN(
        game.gameManager.totalPlayerCount,
      );
      //If there is an available player, let affectedPlayer be that player.
      //For CPU players, this affectedPlayer will be their choice for who
      //will get redeemer.
      for (Player player in worstPlayers) {
        if (!player.isDone && !player.hasRedeemer) {
          affectedPlayer = player;
          break;
        }
      }
      //If no one is available to have redeemer,
      //that is, affected user is still null, return early
      if (affectedPlayer == null) {
        print("No remaining player can have the redeemer card.");
        game.gameManager.deck.addToDiscard([this]);
        finishEventCompleter();
        return;
      }
      //Else, there is an available player to give redeemer to.
      //We don't have to worry about CPU because they will automatically choose the worst
      //player available, in terms of total score, to give the redeemer to
      //All that is left is to check if they are not CPU
      else if (!cardUser!.isCpu()) {
        bool validChoice = false;
        while (!validChoice) {
          await choosePlayer();
          //If chosen player is active and has redeemer, it is valid!
          if (!affectedPlayer!.hasRedeemer && !affectedPlayer!.isDone) {
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
    //Give redeemer to affected player
    affectedPlayer!.grantRedeemer();
    await affectedPlayer?.onHit(this);
    finishEventCompleter();
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} User will have this card for the remainder the round. " +
          "If they get a duplicate number card, instead of busting, they get 67% of " +
          "the points from the round (not including duplicate).",
    );
  }
}
