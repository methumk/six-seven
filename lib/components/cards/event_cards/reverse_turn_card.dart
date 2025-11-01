//Reverses turn order
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/deck.dart';

class ReverseTurnCard extends EventActionCard {
  ReverseTurnCard() {
    eventEnum = EventCardEnum.ReverseTurn;
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
      description: "Reverses turn order!",
      descriptionTitle: "Reverse Turn",
    );
  }

  @override
  Future<void> executeOnEvent() async {
    // TODO: show animation for changing direction order
    game.gameManager.flipRotationDirection();

    // Resolve event complete to stop waiting
    resolveEventCompleter();
  }

  @override
  void description() {
    print("${cardType.label} Reverses turn order!");
  }
}
