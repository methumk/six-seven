//Chosen player is told when the next 4 cards are, but not necessarily in the actual order that they will appear
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class ForecasterCard extends EventActionCard {
  ForecasterCard() {
    eventEnum = EventCardEnum.Forecaster;
  }

  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    await initCardIcon("game_ui/test.png");
    initDescriptionText(
      description:
          "Forecasts the next 4 cards, but not necessarily in the order that they will appear!",
      descriptionTitle: "Forecaster",
    );
  }

  @override
  Future<void> executeOnEvent() async {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} forecasts the next 4 cards, but not necessarily in the order that they will appear!",
    );
  }
}
