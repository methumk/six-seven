import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class FreezeCard extends EventActionCard {
  FreezeCard() {
    eventEnum = EventCardEnum.Freeze;
  }

  //No special execute on stay function
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
          "The player that gets chosen will be frozen, forcing them to stay for the round!",
      descriptionTitle: "Freeze",
    );
  }

  //Freezes other player
  @override
  Future<void> executeOnEvent() async {
    //CPU Strategy: There will be a list of priorities, and CPU will choose starting from top priority,
    //and descending.
    //First priority: Find another active player with double chance card. If there's more than one player that meets this criteria,
    //choose the player with the highest (total value + current value).
    //Second priority: should no active player (other than cardUser) have a double chance card,  find an active player (other than
    //cardUser) with the highest (total value of points +current value of points).
    //Third priority:  should every active player (other than cardUser) have the same (total + current value) of points, just find another player
    //(other than cardUser) that is active, and freeze them.
    //Finally, if none of these criterias are met, this means the cardUser is the only player that is active. Since affectedUser = cardUser
    //when initialized, the cardUser will ultimately choose themself.

    if (cardUser!.isCpu()) {
      affectedPlayer = cardUser;
      print("Looking for double chancer player to freeze");

      firstPrioritySearch();
      //If affectedPlayer is still the cardUser, that means there was no player that met the first criteria
      //(there was no active player with doubleChance).
      //Proceed onto the second priority search
      if (affectedPlayer == cardUser) {
        secondPrioritySearch();
      }

      //If no player satisfies second priority, go to third priority search
      if (affectedPlayer == cardUser) {
        thirdPrioritySearch();
      }
      //If after all this, affectedPlayer == cardUser, it means that the only
      //player the CPU could choose to freeze is themself.
      //I chose to do three iterations instead of three variables to represent each priority
      //for one iteration in order for the code to be easy to read/ scalable. The number of players
      //should never exceed $7$ because it starts to get boring waiting for other players to move.
      //Currently, $n\leq 4$.
    }
    //For humans, they will choose an active player to freeze
    else {
      bool validChoice = false;
      while (!validChoice) {
        await choosePlayer();
        if (!affectedPlayer!.isDone) {
          validChoice = true;
        } else {
          print(
            "The player you chose is already done for the round! Choose another player",
          );
        }
      }
    }
    //The affectedPlayer has been chosen.
    //Make the affectedUser forced to stay
    print("Chosen player: ${affectedPlayer!.playerName}");
    await affectedPlayer!.handleStay();
    game.gameManager.donePlayers.add(affectedPlayer!);
    finishEventCompleter();
    return;
  }

  //Method for finding player in First Priority Search: Find the active player with double chance.
  //If more than one exists, find the player with the highest (total value + current value) points
  void firstPrioritySearch() {
    //FIRST PRIORITY: Finding active player with double chance card. If more than one exists, find the player
    //with the highest total value
    Player? bestDoubleChancePlayer;
    for (Player player in game.gameManager.players) {
      //If the player is the cardUser, does not have double chance, or is done, continue
      if (player == cardUser || !player.doubleChance || player.isDone) {
        continue;
      }
      //Since the player satisfies both conditions, we compare it to bestDoubleChancePlayer.
      //If bestDoubleChancePlayer doesn't have double chance, simply replace it with the player from the for loop.
      //Else, choose the player with the higher total value
      if (bestDoubleChancePlayer == null ||
          (player.totalValue + player.currentValue) >=
              (bestDoubleChancePlayer.totalValue +
                  bestDoubleChancePlayer.currentValue)) {
        bestDoubleChancePlayer = player;
      }
    }
    //If bestDoubleChancePlayer is not null, then a player that meets the first priority criteria has been found.
    //Assign it to affectedPlayer:
    if (bestDoubleChancePlayer != null) {
      affectedPlayer = bestDoubleChancePlayer;
    }
    return;
  }

  //Method for second priority search: Find an active player with highest (total value + current value) points
  void secondPrioritySearch() {
    print(
      "No player with double chance other than cardUser. Looking for active player with highest score:",
    );
    Player? highestScorePlayer;
    for (Player player in game.gameManager.players) {
      if (player == cardUser || player.isDone) {
        continue;
      }
      if (highestScorePlayer == null ||
          (player.totalValue + player.currentValue) >=
              (highestScorePlayer.totalValue +
                  highestScorePlayer.currentValue)) {
        highestScorePlayer = player;
      }
    }
    if (highestScorePlayer != null) {
      affectedPlayer = highestScorePlayer;
    }
    return;
  }

  //Method for third priority: Just find an active player
  void thirdPrioritySearch() {
    print("No active player has a single largest total value");
    for (Player player in game.gameManager.players) {
      if (player != cardUser && !player.isDone) {
        affectedPlayer = player;
        break;
      }
    }
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} the player that gets chosen will be frozen, forcing them to stay for the round!",
    );
  }
}
