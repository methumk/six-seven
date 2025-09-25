//Choice draw: User can choose to reverse the polarity for any of the value action cards in their hand
import 'package:six_seven/components/cards/card.dart';

class Redeemer extends EventActionCard {
  Redeemer();

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
      "${cardType.label} User will have this card for the remainder the round. " +
          "If they get a duplicate number card, instead of busting, they get 67% of " +
          "the points from the round (not including duplicate).",
    );
  }
}
