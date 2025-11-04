//Choice draw: User can choose to reverse the polarity for any of the value action cards in their hand
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class DiscarderCard extends EventActionCard {
  DiscarderCard() {
    eventEnum = EventCardEnum.Discarder;
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
      description: "You must remove one event or operator card from your hand.",
      descriptionTitle: "Discarder",
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
      "${cardType.label} User can choose to reverse the polarity for any of the value action cards in their hand.",
    );
  }
}
