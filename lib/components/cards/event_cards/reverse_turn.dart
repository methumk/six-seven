//Reverses turn order
import 'package:six_seven/components/cards/card.dart';

class ReverseTurn extends EventActionCard {
  ReverseTurn();

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
    print("${cardType.label} Reverses turn order!");
  }
}
