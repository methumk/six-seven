import 'dart:async';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/rounded_border_component.dart';
import 'package:six_seven/utils/flame_svg_component.dart';

class MinusCard extends ValueActionCard {
  MinusCard({required super.value})
    : super(
        cardType: CardType.valueActionMinusCard,
        actionText: "-",
        descripTitleText: "Subtract Value",
        descripText: "Current value gets decreased by $value",
      );

  @override
  String cardSvgPathBuilder() => "images/game_ui/minus_card_$valueAsString.svg";

  @override
  double executeOnStay(double currentValue) {
    currentValue -= value;
    return currentValue;
  }

  @override
  Future<void> buildFront(RoundedBorderComponent container) async {
    print("MINUS CARD BUILD FRONT");
    final svg = await game.getCardSvg(this);
    if (svg != null) {
      final svgComponent = await loadSvgFromSvg(svg);
      frontFace.setFillImage(svgComponent!);
    }
  }

  @override
  void description() {
    print("${cardType.label} - $value");
  }

  // @override
  // FutureOr<void> onLoad() async {
  //   super.onLoad();
  // }

  @override
  String toString() {
    return "Minus Card -$value";
  }
}
