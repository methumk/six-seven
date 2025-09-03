//Magnifying Glass: Can see the next card in the deck before making decision
import 'package:six_seven/components/cards/card.dart';

class MagnifyingGlassCard extends EventActionCard {
  MagnifyingGlassCard();

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
      "${cardType.label} the player that gets chosen is allowed to take a peek at the next card in the deck!",
    );
  }
}
