//Regressive Income Tax Card
import 'package:six_seven/components/cards/card.dart';

class SalesTax extends EventActionCard {
  SalesTax();
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
      "${cardType.label} player gets to enforce a sales tax on their player of choice!",
    );
  }
}
