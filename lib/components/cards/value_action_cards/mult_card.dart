import 'package:six_seven/components/cards/card.dart';

class MultCard extends ValueActionCard {
  MultCard({required super.value});

  @override
  double executeOnStay(double currentValue) {
    currentValue *= value;
    return currentValue;
  }

  @override
  void description() {
    print("${cardType.label} x $value");
  }
}
