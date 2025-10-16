//Sunk Prophet: User must receive the following effect:
//Roll a 7 sided die. If you get a number of six or seven, gain 7.
//Else, lose 13 points. You must keep rolling until you roll a six or seven,
//or you lose 7 times in a row, in which your loss is capped at -30 lmfao :)
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';

class SunkProphet extends EventActionCard {
  SunkProphet();

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
          "Roll a 7 sided die. Getting 6 or 7 gains 13 points. Otherwise, lose 7 points. Keep rolling a 7 max rolls or until your first 6 or 7!",
      descriptionTitle: "Sunk Prophet",
    );
  }

  @override
  Future<void> executeOnEvent() async {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} player of choice is forced to roll a 13-sided die! A roll that is not a 6 or 7 loses them 7 points, while a roll of 6 or 7 gains them 13 points! They must continue to roll until they roll a 6 or 7.",
    );
  }
}
