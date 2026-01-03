//Lucky Six Dice Card: Roll a seven sided die. If it is 1-5, gain 3.67 points.
//Else, lose 7 points. Can choose to roll up to 7 times.
import 'dart:async';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/data/enums/event_cards.dart';
import 'package:six_seven/components/players/cpu_player.dart';
import 'package:six_seven/components/players/player.dart';

class LuckyDieCard extends EventActionCard {
  LuckyDieCard()
    : super(
        imagePath: "game_ui/test.png",
        descripTitleText: "Lucky Die",
        descripText:
            "Roll a 7 sided die. Rolling a 1,2,3,4, or 5 gets you those points respectively. Rolling a 6 or 7 gets you -6 or -7 points respectively. Max roll 7 times!",
      ) {
    eventEnum = EventCardEnum.LuckyDie;
  }

  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  Future<void> executeOnEvent() async {
    Player? p = game.gameManager.getCurrentPlayer;
    if (p == null) {
      return;
    }

    // Calculate difficulty
    var difficulty = Difficulty.expert;
    if (p is CpuPlayer) {
      difficulty = p.difficulty;
    }

    // Set either AI or CPU interaction with dialogue
    int points = await game.showRollDiceEvent(
      isAi: p.isCpu(),
      aiDifficulty: difficulty,
      isLuckyDie: true,
    );

    p.updateBonusValue(points.toDouble());

    // Resolve event complete to stop waiting
    resolveEventCompleter();
  }

  @override
  void description() {
    print(
      "${cardType.label} player of choice gets to roll a lucky seven sided die! A roll that is between 1 and 5 earns you 1 to 5 points, while a roll of 6 or 7 makes you lose 6 to 7 points!",
    );
  }

  @override
  String toString() {
    return "Lucky Die";
  }
}
