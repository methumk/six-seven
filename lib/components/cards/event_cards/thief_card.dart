//Thief: lets you choose a player and then steal all of their value action cards
import 'package:six_seven/components/cards/card.dart';

class ThiefCard extends EventActionCard {
  ThiefCard();
  //No special execute on stay
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
      "${cardType.label} you get to choose a player to steal all their value action cards!",
    );
  }
}
