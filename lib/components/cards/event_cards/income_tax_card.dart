//Progressive Income Tax Card
import 'package:six_seven/components/cards/card.dart';

class IncomeTax extends EventActionCard {
  IncomeTax();
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
    print("${cardType.label} enforces a progressive income tax on the player!");
  }
}
