//Chosen player is told when the next 4 cards are, but not necessarily in the actual order that they will appear
import 'package:six_seven/components/cards/card.dart';

class ForecasterCard extends EventActionCard {
  ForecasterCard();

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
      "${cardType.label} forecasts the next 4 cards, but not necessarily in the order that they will appear!",
    );
  }
}
