import 'package:six_seven/components/cards/card.dart';

class MinusCard extends ValueActionCard {
  MinusCard({required super.value});

  @override
  double executeOnStay(double currentValue) {
    currentValue -= value;
    return currentValue;
  }

  @override
  void description() {
    print("${cardType.label} - $value");
  }
}
