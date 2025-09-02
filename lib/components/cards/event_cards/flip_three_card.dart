import 'package:six_seven/components/cards/card.dart';

class FlipThreeCard extends EventActionCard {
  FlipThreeCard();

  //No special execute on stay
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  //Forces player to flip 3 cards
  @override
  void executeOnEvent() {
    //To Do: implement
    return;
  }

  @override
  void description() {
    print("${cardType.label} the player that gets chosen must flip 3 cards!");
  }
}
