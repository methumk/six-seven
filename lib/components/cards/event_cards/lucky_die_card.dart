//Lucky Six Dice Card: Roll a seven sided die. If it is 1-5, gain 3.67 points.
//Else, lose 7 points. Can choose to roll up to 7 times.
import 'dart:async';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/data/enums/event_cards.dart';
import 'package:six_seven/components/players/cpu_player.dart';
import 'package:six_seven/components/players/player.dart';

class LuckyDieCard extends EventActionCard {
  LuckyDieCard() {
    eventEnum = EventCardEnum.LuckyDie;
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
          "Roll a 7 sided die. Five of the sides have a -6 value, two of the sides have a +7 value!",
      descriptionTitle: "Lucky Die",
    );
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
      "${cardType.label} Roll a 7 sided die. Five of the sides have a -6 value, two of the sides have a +7 value!",
    );
  }

  @override
  String toString() {
    return "Lucky Die";
  }
}
