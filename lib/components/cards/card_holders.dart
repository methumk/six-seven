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
  int minusCardLength = 0;
  Map<double, List<MinusCard>> minusHandMap = {};

  DynamicCardHolder() : super(anchor: Anchor.bottomLeft) {}

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
  }

  void _setCard(Card card) {
    int totalCards =
        addHand.length + multHand.length + minusCardLength + eventHand.length;

    Vector2 newCardPos = Vector2(
      position.x + Card.halfCardSize.x + (totalCards * cardPosOffset.x),
      0,
    );
    card.position = newCardPos;
    // Newest card (on left is higher up than previous cards)
    card.priority = currCardPriority++;
  }

  void addCardtoHand(Card c) {
    if (c is PlusCard) {
      addHand.add(c);
    } else if (c is MultCard) {
      multHand.add(c);
    } else if (c is MinusCard) {
      double minusValue = c.value;
      minusCardLength++;
      if (minusHandMap.containsKey(minusValue)) {
        var minusList = minusHandMap[minusValue];
        minusList!.add(c);
      } else {
        minusHandMap[minusValue] = [c];
      }
    } else if (c is EventActionCard) {
      eventHand.add(c);
    }

    _setCard(c);
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

  void removeSingleMinusCard(double minusValue) {
    final minusList = minusHandMap[minusValue];
    if (minusList != null && minusList.isNotEmpty) {
      var mc = minusList.removeLast();
      remove(mc);
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
    minusCardLength = 0;
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
