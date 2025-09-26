//Choice draw: User draws three cards, chooses one card to keep, discards other card
import 'dart:async';
import 'package:six_seven/components/cards/card.dart';

class ChoiceDraw extends EventActionCard {
  ChoiceDraw();

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
          "User draws three cards, and chooses one of the cards to keep while discarding the rest!",
      descriptionTitle: "Choice",
    );
  }

  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} User draws three cards, and chooses one of the cards to keep while discarding the rest!",
    );
  }
}
