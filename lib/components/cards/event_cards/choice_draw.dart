//Choice draw: User draws two cards, chooses one card to keep, discards other card
import 'package:six_seven/components/cards/card.dart';

class ChoiceDraw extends EventActionCard {
  ChoiceDraw();

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
      "${cardType.label} User draws two cards, and chooses one of the cards to keep while discarding the other!",
    );
  }
}
