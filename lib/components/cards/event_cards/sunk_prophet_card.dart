//Sunk Prophet: User must receive the following effect:
//Roll a 7 sided die. If you get a number of six or seven, gain 7.
//Else, lose 13 points. You must keep rolling until you roll a six or seven,
//or you lose 7 times in a row, in which your loss is capped at -30 lmfao :)
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/players/cpu_player.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class SunkProphet extends EventActionCard {
  SunkProphet()
    : super(
        imagePath: "game_ui/test.png",
        descripTitleText: "Sunk Prophet",
        descripText:
            "Roll a 7 sided die. Getting 6 or 7 gains 13 points. Otherwise, lose 7 points. Keep rolling a 7 max rolls or until your first 6 or 7!",
      ) {
    eventEnum = EventCardEnum.SunkProphet;
  }

  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  Future<void> executeOnEvent() async {
    //max cap integer
    int maxLossCap = -25;
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
      isLuckyDie: false,
    );

    //Compare points to max cap
    if (points < maxLossCap) {
      points = maxLossCap;
    }

    p.updateBonusValue(points.toDouble());

    // Resolve event complete to stop waiting
    resolveEventCompleter();
  }

  @override
  void description() {
    print(
      "${cardType.label} Roll a 7 sided die. Five of the sides have a -6 value, two of the sides have a +7 value! Max loss capped at -25 points.",
    );
  }
}
