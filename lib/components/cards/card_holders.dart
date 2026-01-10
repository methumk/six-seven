import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/event_cards/double_chance_card.dart';
import 'package:six_seven/components/cards/value_action_cards/minus_card.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart';
import 'package:six_seven/components/cards/value_action_cards/plus_card.dart';

class NumberCardHolder extends PositionComponent with DragCallbacks {
  Set<double> numHandSet = Set();
  final List<NumberCard> numberHand = [];
  static final Vector2 cardPosOffset = Vector2(Card.cardSize.x * .27, 0);
  int currCardPriority = 0;

  NumberCardHolder() : super(anchor: Anchor.bottomRight);

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
  }

  int getTotalHandLength() {
    return numberHand.length;
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
    numHandSet.add(card.value);
    add(card);
    card.onDragEndReturnTo(card.position, card.priority);
  }

  void removeAllCards({bool removeFromUi = true}) {
    if (removeFromUi) {
      for (final c in numberHand) {
        if (c.isMounted) {
          c.removeFromParent();
        }
      }
    }

    currCardPriority = 0;
    numberHand.clear();
    numHandSet.clear();
  }
}

class DynamicCardHolder extends PositionComponent {
  static final Vector2 cardPosOffset = Vector2(Card.cardSize.x * .25, 0);
  final List<PlusCard> addHand = [];
  final List<MultCard> multHand = [];
  // final List<MinusCard> minusHand = [];
  final List<EventActionCard> eventHand =
      []; // Only for some events - most events get used
  int currCardPriority = 0;
  int minusHandLength = 0;
  Map<double, List<MinusCard>> minusHandMap = {};

  // Get the total value card length
  int get valueCardLength => minusHandLength + addHand.length + multHand.length;

  DynamicCardHolder() : super(anchor: Anchor.bottomLeft);

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
    card.onDragEndReturnTo(card.position, card.priority);

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
            mc.onDragEndReturnTo(mc.position, mc.priority);
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
        mtc.onDragEndReturnTo(mtc.position, mtc.priority);
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
        eac.onDragEndReturnTo(eac.position, eac.priority);
      }
    }
  }

  // Call this after you have removed the card from the array
  // Order of rendering is Add/Minus/Mult/Event
  void _updateDeckPositionsOnCardRemoval(CardType cardType) {
    int cardTypeIndex = 0;
    int cardPriority = 0;
    // Vector2 cardPos = Vector2(position.x + Card.halfCardSize.x, 0);

    if (cardType == CardType.valueActionMinusCard) {
      cardTypeIndex = 1;
      cardPriority = addHand.length;
      // cardPos.x = cardPos.x + (addHand.length * cardPosOffset.x);
    } else if (cardType == CardType.valueActionMultCard) {
      cardTypeIndex = 2;
      cardPriority = addHand.length + minusHandLength;
      // cardPos.x = cardPos.x + (cardPriority * cardPosOffset.x);
    } else if (cardType == CardType.eventActionCard) {
      cardTypeIndex = 3;
      cardPriority = addHand.length + minusHandLength + multHand.length;
      // cardPos.x = cardPos.x + (cardPriority * cardPosOffset.x);
    }

    // update add cards
    if (cardTypeIndex == 0) {
      for (final c in addHand) {
        c.position = Vector2(
          position.x + Card.halfCardSize.x + (++cardPriority * cardPosOffset.x),
          0,
        );
        c.priority = cardPriority;
        c.onDragEndReturnTo(c.position, c.priority);
      }
    }

    // update minus cards
    if (cardTypeIndex <= 1) {
      for (final c in minusHandMap.entries) {
        final minusList = minusHandMap[c.key];
        if (minusList == null) continue;

        // Update all minus cards
        for (MinusCard mc in minusList) {
          mc.position = Vector2(
            position.x +
                Card.halfCardSize.x +
                (++cardPriority * cardPosOffset.x),
            0,
          );
          mc.priority = cardPriority;
          mc.onDragEndReturnTo(mc.position, mc.priority);
        }
      }
    }

    // update mult cards
    if (cardTypeIndex <= 2) {
      for (final c in multHand) {
        c.position = Vector2(
          position.x + Card.halfCardSize.x + (++cardPriority * cardPosOffset.x),
          0,
        );
        c.priority = cardPriority;
        c.onDragEndReturnTo(c.position, c.priority);
      }
    }

    // update event cards
    if (cardTypeIndex <= 3) {
      for (final c in eventHand) {
        c.position = Vector2(
          position.x + Card.halfCardSize.x + (++cardPriority * cardPosOffset.x),
          0,
        );
        c.priority = cardPriority;
        c.onDragEndReturnTo(c.position, c.priority);
      }
    }

    // Update priority
    currCardPriority = cardPriority;
  }

  // Returns the entire deck as a single list
  // Order is minus first, then event,  then mult, then add,
  List<Card> getAsSingleList() {
    List<Card> allCards = [];
    minusHandMap.forEach((key, minusList) {
      for (var c in minusList) {
        allCards.add(c);
      }
    });
    for (var c in eventHand) {
      allCards.add(c);
    }
    for (var c in multHand) {
      allCards.add(c);
    }
    for (var c in addHand) {
      allCards.add(c);
    }

    return allCards;
  }

  int getTotalHandLength() {
    return addHand.length +
        multHand.length +
        eventHand.length +
        minusHandLength;
  }

  bool isEmpty() {
    return getTotalHandLength() == 0;
  }

  // Attaches a top up selector function to all cards in the hand
  void setCardSelectedOnTapUp(void Function(Card)? onTapUpSelector) {
    for (var c in addHand) {
      c.onTapUpSelector = onTapUpSelector;
    }
    for (var c in multHand) {
      c.onTapUpSelector = onTapUpSelector;
    }
    for (var c in eventHand) {
      c.onTapUpSelector = onTapUpSelector;
    }
    minusHandMap.forEach((key, value) {
      for (var c in value) {
        c.onTapUpSelector = onTapUpSelector;
      }
    });
  }

  // Attaches a top up selector function to all cards in the hand
  void setCardSelectedOnTapDown(void Function(Card)? onTapDownSelector) {
    for (var c in addHand) {
      c.onTapDownSelector = onTapDownSelector;
    }
    for (var c in multHand) {
      c.onTapDownSelector = onTapDownSelector;
    }
    for (var c in eventHand) {
      c.onTapDownSelector = onTapDownSelector;
    }
    minusHandMap.forEach((key, value) {
      for (var c in value) {
        c.onTapDownSelector = onTapDownSelector;
      }
    });
  }

  // Removes tap up selector attached to all cards in the card holder
  void clearCardSelectedOnTapUp() {
    for (var c in addHand) {
      c.onTapUpSelector = null;
    }
    for (var c in multHand) {
      c.onTapUpSelector = null;
    }
    for (var c in eventHand) {
      c.onTapUpSelector = null;
    }
    minusHandMap.forEach((key, value) {
      for (var c in value) {
        c.onTapUpSelector = null;
      }
    });
  }

  // Removes tap down selector attached to all cards in the card holder
  void clearCardSelectedOnTapDown() {
    for (var c in addHand) {
      c.onTapDownSelector = null;
    }
    for (var c in multHand) {
      c.onTapDownSelector = null;
    }
    for (var c in eventHand) {
      c.onTapDownSelector = null;
    }
    minusHandMap.forEach((key, value) {
      for (var c in value) {
        c.onTapDownSelector = null;
      }
    });
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

  // Change border color of cards in deck to show that they are selectable
  // NOTE: this does not make them selectable, just changes the UI element
  // Toggleing selectable false will update all settings back to regular card settings
  void toggleCardShowSelectable(
    bool selectable, {
    Color? selectColor,
    bool changePlusCards = true,
    bool changeMultCards = true,
    bool changeMinusCards = true,
    bool changeEventCards = true,
  }) {
    if (selectable && selectColor == null) return;
    if (changePlusCards) {
      for (var c in addHand) {
        if (selectable) {
          c.setBorderColor(selectColor!);
        } else {
          c.resetCardSettings();
        }
      }
    }
    if (changeMultCards) {
      for (var c in multHand) {
        if (selectable) {
          c.setBorderColor(selectColor!);
        } else {
          c.resetCardSettings();
        }
      }
    }
    if (changeMinusCards) {
      minusHandMap.forEach((key, value) {
        for (var c in value) {
          if (selectable) {
            c.setBorderColor(selectColor!);
          } else {
            c.resetCardSettings();
          }
        }
      });
    }
    if (changeEventCards) {
      for (var c in eventHand) {
        if (selectable) {
          c.setBorderColor(selectColor!);
        } else {
          c.resetCardSettings();
        }
      }
    }
  }

  // Removes a card by reference
  void removeCard(Card c) {
    if (c is PlusCard) {
      print("REMOVING PLUS CARD");
      removePlusCard(c);
    } else if (c is MultCard) {
      print("REMOVING MULT CARD");
      removeMultCard(c);
    } else if (c is MinusCard) {
      print("REMOVING MINUS CARD");
      removeSingleMinusCard(c.value);
    } else if (c is EventActionCard) {
      print("REMOVING EVENT ACTION CARD");
      removeEventCard(c);
    }
  }

  void removeEventCard(EventActionCard ec, {bool updateDeckPosition = true}) {
    bool removed = eventHand.remove(ec);
    if (removed) {
      ec.removeFromParent();
    }

    if (removed && updateDeckPosition) {
      _updateDeckPositionsOnCardRemoval(CardType.eventActionCard);
    }
  }

  void removeAllEventHand({
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) {
    for (final c in eventHand) {
      if (c.isMounted && removeFromUi) {
        c.removeFromParent();
      }
    }
    eventHand.clear();
    if (updateDeckPosition) {
      _updateDeckPositionsOnCardRemoval(CardType.eventActionCard);
    }
  }

  void removePlusCard(
    PlusCard c, {
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) {
    bool removed = addHand.remove(c);
    if (removed && removeFromUi && c.isMounted) {
      c.removeFromParent();
    }

    if (removed && updateDeckPosition) {
      _updateDeckPositionsOnCardRemoval(CardType.valueActionPlusCard);
    }
  }

  List<PlusCard> removeAllAddHand({
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) {
    List<PlusCard> remd = [];

    for (final c in addHand) {
      if (c.isMounted && removeFromUi) {
        c.removeFromParent();
      }
      remd.add(c);
    }
    addHand.clear();
    if (updateDeckPosition) {
      _updateDeckPositionsOnCardRemoval(CardType.valueActionPlusCard);
    }
    return remd;
  }

  bool minusCardInHand(double numberValue) =>
      minusHandMap.containsKey(numberValue) &&
      minusHandMap[numberValue]!.isNotEmpty;

  // Returns the entire minus card hand as a list
  // NOTE: this doesn't remove the cards from the hand, so these will be references
  List<MinusCard> getAllMinusCards() {
    List<MinusCard> mcs = [];

    for (final c in minusHandMap.entries) {
      final minusList = minusHandMap[c.key];
      if (minusList != null) {
        for (MinusCard mc in minusList) {
          mcs.add(mc);
        }
      }
    }
    return mcs;
  }

  // Removes card from hand and updates all other card positions
  void removeSingleMinusCard(
    double minusValue, {
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) {
    final minusList = minusHandMap[minusValue];
    if (minusList != null && minusList.isNotEmpty) {
      var mc = minusList.removeLast();
      minusHandLength--;
      if (mc.isMounted && removeFromUi) {
        mc.removeFromParent();
      }
      if (updateDeckPosition) {
        _updateDeckPositionsOnCardRemoval(CardType.valueActionMinusCard);
      }
    }
  }

  DoubleChanceCard? removeDoubleChanceCardInHand({
    bool updateDeckPosition = true,
  }) {
    DoubleChanceCard? doubleChanceCard;
    for (EventActionCard card in eventHand) {
      if (card is DoubleChanceCard) {
        doubleChanceCard = card;
        eventHand.remove(card);
        //Remove it visually from game tree
        remove(card);
        break;
      }
    }

    if (updateDeckPosition) {
      _updateDeckPositionsOnCardRemoval(CardType.eventActionCard);
    }
    return doubleChanceCard;
  }

  List<MinusCard> removeAllMinusHand({
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) {
    List<MinusCard> remd = [];
    for (final c in minusHandMap.entries) {
      final minusList = minusHandMap[c.key];
      if (minusList != null) {
        for (MinusCard mc in minusList) {
          if (mc.isMounted && removeFromUi) {
            mc.removeFromParent();
          }
          remd.add(mc);
        }
      }
    }
    minusHandMap.clear();
    minusHandLength = 0;
    if (updateDeckPosition) {
      _updateDeckPositionsOnCardRemoval(CardType.eventActionCard);
    }
    return remd;
  }

  void removeMultCard(
    MultCard c, {
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) {
    bool removed = multHand.remove(c);
    if (removed && c.isMounted && removeFromUi) {
      c.removeFromParent();
    }
    if (removed && updateDeckPosition) {
      _updateDeckPositionsOnCardRemoval(CardType.valueActionMultCard);
    }
  }

  List<MultCard> removeAllMultHand({
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) {
    List<MultCard> remd = [];
    for (final c in multHand) {
      if (c.isMounted && removeFromUi) {
        c.removeFromParent();
      }
      remd.add(c);
    }
    multHand.clear();
    if (updateDeckPosition) {
      _updateDeckPositionsOnCardRemoval(CardType.valueActionMultCard);
    }
    return remd;
  }

  void removeAllValueHands({
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) {
    removeAllAddHand(
      updateDeckPosition: updateDeckPosition,
      removeFromUi: removeFromUi,
    );
    removeAllMinusHand(
      updateDeckPosition: updateDeckPosition,
      removeFromUi: removeFromUi,
    );
    removeAllMultHand(
      updateDeckPosition: updateDeckPosition,
      removeFromUi: removeFromUi,
    );
    // This will update everything
    if (updateDeckPosition) {
      _updateDeckPositionsOnCardRemoval(CardType.valueActionPlusCard);
    }
  }

  // TODO: verify that cards don't have to removed from UI
  void removeAllCards({
    bool updateDeckPosition = false,
    bool removeFromUi = true,
  }) {
    removeAllValueHands(
      updateDeckPosition: updateDeckPosition,
      removeFromUi: removeFromUi,
    );
    removeAllEventHand(
      updateDeckPosition: updateDeckPosition,
      removeFromUi: removeFromUi,
    );
    _updateDeckPositionsOnCardRemoval(CardType.valueActionPlusCard);
  }
}
