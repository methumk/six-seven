import 'dart:async';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/rounded_border_component.dart';
import 'package:six_seven/utils/flame_svg_component.dart';

class PlusCard extends ValueActionCard {
  PlusCard({required super.value})
    : super(
        cardType: CardType.valueActionPlusCard,
        actionText: "+",
        descripTitleText: "Plus Value",
        descripText: "Current value gets increased by $value",
      );

  @override
  String cardSvgPathBuilder() => "images/game_ui/plus_card_$valueAsString.svg";

  @override
  double executeOnStay(double cv) {
    return cv + value;
  }

  @override
  Future<void> buildFront(RoundedBorderComponent container) async {
    print("PLUS CARD BUILD FRONT");
    final svg = await game.getCardSvg(this);
    if (svg != null) {
      final svgComponent = await loadSvgFromSvg(svg);
      frontFace.setFillImage(svgComponent!);
    }
  }

  @override
  void description() {
    print("${cardType.label} + $value");
  }

  // @override
  // FutureOr<void> onLoad() async {
  //   super.onLoad();
  // }

  @override
  String toString() {
    return "Plus Card +$value";
  }
}
