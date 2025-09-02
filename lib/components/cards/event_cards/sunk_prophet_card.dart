//Sunk Prophet: Chosen player gets effect: Roll a 7 sided die. If you get 1-5, you lose
//7 points. Else, a 6 or 7 earns you 13 points. Do this seven times.
import 'package:six_seven/components/cards/card.dart';

class SunkProphet extends EventActionCard {
  SunkProphet();

  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  void executeOnEvent() {
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
