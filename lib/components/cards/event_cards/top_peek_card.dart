// Top peek: Can see the next card in the deck before making decision
import 'dart:async';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/data/enums/event_cards.dart';

class TopPeekCard extends EventActionCard {
  TopPeekCard()
    : super(
        imagePath: "game_ui/test.png",
        descripTitleText: "Top Peek",
        descripText:
            "The card user is allowed to take a peek at the next card in the deck!",
      ) {
    eventEnum = EventCardEnum.TopPeek;
  }

  //No special execute on stay
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  Future<void> executeOnEvent() async {
    if (!cardUser!.isCpu()) {
      Card peekCard = game.gameManager.deck.peek();
      game.world.add(peekCard);

      // Do peekCard animation
      await peekCard.peekAnimation();

      //Reset peek card size
      peekCard.resetCardSettings();
    }
    // TODO: handle another animation for players who don't get to see what the card is?

    resolveEventCompleter();
  }

  @override
  void description() {
    print(
      "${cardType.label} the card user is allowed to take a peek at the next card in the deck!",
    );
  }

  @override
  String toString() {
    return "Top Peek";
  }
}
