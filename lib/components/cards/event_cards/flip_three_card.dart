import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class FlipThreeCard extends EventActionCard {
  FlipThreeCard() {
    eventEnum = EventCardEnum.FlipThree;
  }

  //No special execute on stay
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
      description: "The person you select must flip 3 cards!",
      descriptionTitle: "Flip Three",
    );
  }

  //Forces player to flip 3 cards
  @override
  Future<void> executeOnEvent() async {
    // Player can choose anyone
    if (cardUser!.isCpu()) {
      // UPDATE: make CPU select random, or highest probability of busting
      affectedPlayer = cardUser;
    } else {
      // Player choose another player or themselves
      await choosePlayer();
    }

    // Safety check, this should realistically never happen
    if (affectedPlayer != null) {
      print("SELECTED PLAYER For FLIP THREE: $affectedPlayer");

      // Selected player has to update mandatory hits
      affectedPlayer!.mandatoryHits += 3;
    }

    // Finish complete in handle draw
    finishEventCompleter();
  }

  @override
  void description() {
    print("${cardType.label} the person you select must flip 3 cards!");
  }
}
