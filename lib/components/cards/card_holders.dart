import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/value_action_cards/minus_card.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart';
import 'package:six_seven/components/cards/value_action_cards/plus_card.dart';

class NumberCardHolder extends PositionComponent with TapCallbacks {
  Set<double> numHandSet = Set();
  final List<NumberCard> numberHand = [];
  static final Vector2 cardPosOffset = Vector2(Card.cardSize.x * .15, 0);
  int currCardPriority = 0;

  NumberCardHolder() : super(anchor: Anchor.bottomRight) {}

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
  }

  // Sets card position and priority
  void _setCard(NumberCard card) {
    Vector2 newCardPos = Vector2(
      position.x -
          Card.halfCardSize.x -
          ((numberHand.length + 1) * cardPosOffset.x),
      0,
    );
    card.position = newCardPos;
    // Newest card (on left is higher up than previous cards)
    card.priority = currCardPriority++;
  }

  bool hasValue(NumberCard nc) {
    for (var card in numberHand) {
      if (card.value == nc.value) return true;
    }
    return false;
  }

  void updateScale(double scale) {
    if (scale <= 0 || scale >= 1) return;
    for (final c in numberHand) {
      c.scale *= scale;
    }
  }

  void addCardtoHand(NumberCard card) {
    _setCard(card);
    numberHand.add(card);
    add(card);
  }

  void removeAllCards() {
    for (final c in numberHand) {
      remove(c);
    }
    currCardPriority = 0;
    numberHand.clear();
    numHandSet.clear();
  }
}

class DynamicCardHolder extends PositionComponent {
  static final Vector2 cardPosOffset = Vector2(Card.cardSize.x * .15, 0);
  final List<PlusCard> addHand = [];
  final List<MultCard> multHand = [];
  // final List<MinusCard> minusHand = [];
  final List<EventActionCard> eventHand =
      []; // Only for some events - most events get used
  int currCardPriority = 0;
  int minusHandLength = 0;
  Map<double, List<MinusCard>> minusHandMap = {};

  DynamicCardHolder() : super(anchor: Anchor.bottomLeft) {}

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
  }

  // Updates all card positions based on order (card assumed to be already added to arrays (lengths updated))
  // Order of rendering is Add/Minus/Mult/Event
  void _updateCardPosOnAdd(Card card) {
    int totalCardsAtPlacement = 0;
    Vector2 newCardPos = Vector2(position.x + Card.halfCardSize.x, 0);

    // Determine current placement total cards
    if (card is PlusCard) {
      totalCardsAtPlacement += addHand.length;
    } else if (card is MinusCard) {
      totalCardsAtPlacement += addHand.length + minusHandLength;
    } else if (card is MultCard) {
      totalCardsAtPlacement +=
          addHand.length + minusHandLength + multHand.length;
    } else if (card is EventActionCard) {
      totalCardsAtPlacement +=
          addHand.length + minusHandLength + multHand.length + eventHand.length;
    }
    newCardPos.x = newCardPos.x + (totalCardsAtPlacement * cardPosOffset.x);

    // Update current cards position and priority
    // NOTE: priority is the same as total cards at placement
    card.position = newCardPos;
    currCardPriority = totalCardsAtPlacement;
    card.priority = currCardPriority;

    // if plus --> update minus/mult/event
    // if minus --> update mult/event
    // if mult --> update event
    // Update the next cards positions
    bool updateNext = false;
    if (card is PlusCard) {
      for (final c in minusHandMap.entries) {
        final minusList = minusHandMap[c.key];
        if (minusList != null) {
          for (MinusCard mc in minusList) {
            mc.position = Vector2(
              position.x +
                  Card.halfCardSize.x +
                  (++currCardPriority * cardPosOffset.x),
              0,
            );
            mc.priority = currCardPriority;
          }
        }
      }
      // Update mult cards next
      updateNext = true;
    }
    if (updateNext || card is MinusCard) {
      for (var mtc in multHand) {
        mtc.position = Vector2(
          position.x +
              Card.halfCardSize.x +
              (++currCardPriority * cardPosOffset.x),
          0,
        );
        mtc.priority = currCardPriority;
      }
      updateNext = true;
    }
    if (updateNext || card is MultCard) {
      for (var eac in eventHand) {
        eac.position = Vector2(
          position.x +
              Card.halfCardSize.x +
              (++currCardPriority * cardPosOffset.x),
          0,
        );
        eac.priority = currCardPriority;
      }
    }
  }

  void _updateCardPositionOnMinusRemoval() {
    // Curr priority starts at number of add cards
    currCardPriority = addHand.length;

    // Update minus hand position
    for (final c in minusHandMap.entries) {
      final minusList = minusHandMap[c.key];
      if (minusList != null) {
        for (MinusCard mc in minusList) {
          mc.position = Vector2(
            position.x +
                Card.halfCardSize.x +
                (++currCardPriority * cardPosOffset.x),
            0,
          );
          mc.priority = currCardPriority;
        }
      }
    }

    // mult hand position update
    for (var mtc in multHand) {
      mtc.position = Vector2(
        position.x +
            Card.halfCardSize.x +
            (++currCardPriority * cardPosOffset.x),
        0,
      );
      mtc.priority = currCardPriority;
    }

    // Event hand position update
    for (var eac in eventHand) {
      eac.position = Vector2(
        position.x +
            Card.halfCardSize.x +
            (++currCardPriority * cardPosOffset.x),
        0,
      );
      eac.priority = currCardPriority;
    }
  }

  void addCardtoHand(Card c) {
    if (c is PlusCard) {
      addHand.add(c);
    } else if (c is MultCard) {
      multHand.add(c);
    } else if (c is MinusCard) {
      double minusValue = c.value;
      minusHandLength++;
      if (minusHandMap.containsKey(minusValue)) {
        var minusList = minusHandMap[minusValue];
        minusList!.add(c);
      } else {
        minusHandMap[minusValue] = [c];
      }
    } else if (c is EventActionCard) {
      eventHand.add(c);
    }

    _updateCardPosOnAdd(c);
    add(c);
  }

  void removeEventCard(EventActionCard ec) {
    remove(ec);
    eventHand.remove(ec);
  }

  void removeAllEventHand() {
    for (final c in eventHand) {
      remove(c);
    }
    eventHand.clear();
  }

  void removeAlladdHand() {
    for (final c in addHand) {
      remove(c);
    }
    addHand.clear();
  }

  bool minusCardInHand(double numberValue) =>
      minusHandMap.containsKey(numberValue) &&
      minusHandMap[numberValue]!.isNotEmpty;

  // Removes card from hand and updates all other card positions
  void removeSingleMinusCard(double minusValue) {
    final minusList = minusHandMap[minusValue];
    if (minusList != null && minusList.isNotEmpty) {
      var mc = minusList.removeLast();
      minusHandLength--;
      remove(mc);
      _updateCardPositionOnMinusRemoval();
    }
  }

  void removeAllMinusHand() {
    for (final c in minusHandMap.entries) {
      final minusList = minusHandMap[c.key];
      if (minusList != null) {
        for (MinusCard mc in minusList) {
          remove(mc);
        }
      }
    }
    minusHandMap.clear();
    minusHandLength = 0;
  }

  void removeAllMultHand() {
    for (final c in multHand) {
      remove(c);
    }
    multHand.clear();
  }

  void removeAllValueHands() {
    removeAlladdHand();
    removeAllMinusHand();
    removeAllMultHand();
  }

  void removeAllCards() {
    removeAllValueHands();
    removeAllEventHand();
    currCardPriority = 0;
  }
}
