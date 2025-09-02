//Lucky Six Dice Card: Roll a seven sided die. If it is 1-5, gain 6 points.
//Else, lose 7 points. Can choose to roll up to 7 times.
import 'package:six_seven/components/cards/card.dart';

class LuckySixSidedDieCard extends EventActionCard {
  LuckySixSidedDieCard();

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
      "${cardType.label} player of choice gets to roll a lucky seven sided die! A roll that is between 1 and 5 earns you 6 points, while a roll of 6 or 7 makes you lose 7 points!",
    );
  }
}
