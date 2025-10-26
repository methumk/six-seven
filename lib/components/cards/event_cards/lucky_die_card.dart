//Lucky Six Dice Card: Roll a seven sided die. If it is 1-5, gain 3.67 points.
//Else, lose 7 points. Can choose to roll up to 7 times.
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/players/player.dart';

class LuckyDieCard extends EventActionCard {
  LuckyDieCard();

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
          "Roll a 7 sided die. Getting 6 or 7 loses 7 points. Otherwise, win 3.67 points. Max roll 7 times!",
      descriptionTitle: "Lucky Die",
    );
  }

  @override
  Future<void> executeOnEvent() async {
    int points = await game.showRollDiceEvent();
    Player? p = game.gameManager.getCurrentPlayer;

    if (p == null) {
      return;
    }
    p.updateBonusValue(points.toDouble());
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} player of choice gets to roll a lucky seven sided die! A roll that is between 1 and 5 earns you 3.67 points, while a roll of 6 or 7 makes you lose 7 points!",
    );
  }
}
