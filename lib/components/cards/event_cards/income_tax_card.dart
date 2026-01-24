//Progressive Income Tax Card
import 'dart:async';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class IncomeTax extends TaxHandEventActionCard {
  IncomeTax()
    : super(
        imagePath: "game_ui/test.png",
        descripTitleText: "Income Tax",
        descripText: "Enforces a progressive income tax on the player!",
      ) {
    eventEnum = EventCardEnum.IncomeTax;
  }

  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  //Grants Income tax
  @override
  Future<void> executeOnEvent() async {
    if (!cardUser!.hasIncomeTax) {
      cardUser?.grantIncomeTax();
      affectedPlayer = cardUser;
    } else {
      //See if there are any readily available players.
      List<Player> worstPlayers = game.gameManager.totalLeaderBoard.bottomN(
        game.gameManager.totalPlayerCount,
      );
      //If there is an available player, let affectedPlayer be that player.
      //For CPU players, this affectedPlayer will be their choice for who
      //will get Income tax.
      for (Player player in worstPlayers) {
        if (!player.isDone && !player.hasIncomeTax) {
          affectedPlayer = player;
          break;
        }
      }
      //If no one is available to have Income tax,
      //that is, affected user is still null, return early
      if (affectedPlayer == null) {
        print("No remaining player can have the Income tax card.");
        game.gameManager.deck.addToDiscard([this]);
        finishEventCompleter();
        return;
      }
      //Else, there is an available player to give Income tax to.
      //We don't have to worry about CPU because they will automatically choose the worst
      //player available, in terms of total score, to give the Income tax to
      //All that is left is to check if they are not CPU
      else if (!cardUser!.isCpu()) {
        bool validChoice = false;
        while (!validChoice) {
          await choosePlayer(
            buttonClickVerf: (Player? p) {
              return p != null && p != cardUser;
            },
          );
          //If chosen player is active and has Income tax, it is valid!
          if (!affectedPlayer!.hasIncomeTax && !affectedPlayer!.isDone) {
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
    //Give Income tax to affected player
    affectedPlayer!.grantIncomeTax();
    await affectedPlayer?.onHit(this);
    finishEventCompleter();
    return;
  }

  //Method for determining tax rate
  @override
  double playerTaxRate({required Player currentPlayer}) {
    //At the first round, total + current is 0. If this is the case,
    //tax rate shouldn't affect anyone
    if (game.gameManager.currentRound == 1) {
      return 1.0;
    }
    //Else calculate the player income tax rate for rounds after the first round
    return playerIncomeTaxRateAfterFirstRound(
      currentPlayer: currentPlayer,
      playerRankings: game.gameManager.totalCurrentLeaderBoard.topN(
        game.gameManager.totalPlayerCount,
      ),
    );
  }

  @override
  void description() {
    print("${cardType.label} enforces a progressive income tax on the player!");
  }
}

//Method for determining tax rate,
//after the first round has finished
double playerIncomeTaxRateAfterFirstRound({
  required Player currentPlayer,
  required List<Player> playerRankings,
}) {
  double taxRate = 1.0;

  late int ranking;
  for (int i = 0; i < playerRankings.length; i++) {
    if (playerRankings[i] == currentPlayer) {
      ranking = i + 1;
      break;
    }
  }
  //Tax System: 1.If player is best player in total + current value,  they get
  //taxed the most at 20%, so their total and current score decreases by 20%.
  //2.If player is in the worst ranking (ranking == total players), they get a tax refund of 20%, meaning
  //their total value increases by 20%.
  //3. If player is at, or above, the middle rank of (1+ total players)/ 2, their tax is 10%.
  //4. If player is not top ranking and is below average in rankings,
  //they are taxed at 6.7%

  //best player
  double averageRank = (1 + playerRankings.length) / 2;
  if (ranking == 1) {
    print(
      "Player is number 1 in total+current value! 20% tax to total and current value",
    );
    taxRate *= .8;
  } //Bottom player
  else if (ranking == playerRankings.length) {
    print(
      "Player is in last place! They earn a tax refund of 20% to total and current value",
    );
    taxRate *= 1.2;
  } //At, or better than average. Notice the smaller the ranking value, the better the rank is
  else if (ranking <= averageRank) {
    print(
      "Player is at, or better than the middle rank! Player is not a top player, so 10% to total and current value",
    );
    taxRate *= .9;
  } //Worse than average
  else if (ranking > averageRank) {
    print(
      "Player is performing less than the middle rank! 6.7% tax to total and current value",
    );
    taxRate *= 1 - .067;
  } //The following shouldn't happen; it means that player does not satisfy any of the cases
  else {
    print(
      "Your player's ranking didn't meet any of the criteria, which shouldn't be possible. Rank:${ranking}. Please debug",
    );
  }
  return taxRate;
}
