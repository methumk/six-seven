//Regressive Income Tax Card, probably a super harsh one of -15
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class SalesTax extends EventActionCard {
  SalesTax()
    : super(
        imagePath: "game_ui/test.png",
        descripTitleText: "Sales Tax",
        descripText:
            "Player gets to enforce a sales tax on their player of choice!",
      ) {
    eventEnum = EventCardEnum.SalesTax;
  }

  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    // await initCardIcon("game_ui/test.png");
    // initDescriptionText(
    //   description:
    //       "Player gets to enforce a sales tax on their player of choice!",
    //   descriptionTitle: "Sales Tax",
    // );
  }

  @override
  Future<void> executeOnEvent() async {
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
