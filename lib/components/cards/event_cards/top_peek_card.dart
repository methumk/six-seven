//Magnifying Glass: Can see the next card in the deck before making decision
import 'dart:async';

import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/players/cpu_player.dart';

class TopPeekCard extends EventActionCard {
  TopPeekCard();

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
      description:
          "The player that gets chosen is allowed to take a peek at the next card in the deck!",
      descriptionTitle: "Top Peek",
    );
  }

  @override
  Future<void> executeOnEvent() async {
    if (cardUser!.isCpu()) {
      game.gameManager.buttonPressed = false;
      game.gameManager.expertPeek(cardUser as CpuPlayer);
    } else {
      Card peekCard = game.gameManager.deck.peek();
      game.world.add(peekCard);

      //Do peekCard animation
      peekCard.drawAnimation.init();
      await peekCard.peekAnimation();
      await peekCard.drawAnimation.wait();

      //Reset peek card size
      peekCard.resetSize();
      game.gameManager.buttonPressed = false;
      game.gameManager.hud.enableHitAndStayBtns();
      String decision = await game.gameManager.hud.waitForHitOrStay();
      if (decision == 'hit') {
        await game.gameManager.callOnHitPressed();
      } else if (decision == 'stay') {
        await game.gameManager.callOnStayPressed();
      }
    }
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} the player that gets chosen is allowed to take a peek at the next card in the deck!",
    );
  }
}
