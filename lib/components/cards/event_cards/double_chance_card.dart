import 'package:six_seven/components/cards/card.dart';

class DoubleChanceCard extends EventActionCard {
  DoubleChanceCard();

  //No special execute on stay
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  //Grants double chance
  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} the player that gets chosen is granted double chance!",
    );
  }
}
