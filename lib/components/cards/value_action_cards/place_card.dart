import 'package:six_seven/components/cards/card.dart';

class PlusCard extends ValueActionCard {
  PlusCard({required super.value});

  @override
  double executeOnStay(double currentValue) {
    currentValue += value;
    return currentValue;
  }

  @override
  void description() {
    print("${cardType.label} + $value");
  }
}
