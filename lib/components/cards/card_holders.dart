import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
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

  NumberCardHolder() : super(anchor: Anchor.bottomRight) {
    priority = 10;
    currCardPriority += priority;
  }

  int getTotalHandLength() {
    return numberHand.length;
  }

  Vector2 _getNewCardPos() {
    return Vector2(
      position.x -
          Card.halfCardSize.x -
          ((numberHand.length + 1) * cardPosOffset.x),
      0,
    );
  }

  bool isDuplicate(NumberCard nc) {
    return numHandSet.contains(nc.value);
  }

  void updateScale(double scale) {
    if (scale <= 0 || scale >= 1) return;
    for (final c in numberHand) {
      c.scale *= scale;
    }
  }

  /// Animates the card going to new position in hand, BUT DOESN"T ADD IT TO THE HAND
  /// See addCardToHand to add if the card is not a duplicate
  /// Returns: true if adding card would be a duplicate (have to handle removal), false if adding card would not be a duplicate (safe to add to hand)
  Future<bool> animateCardArrival(NumberCard card) async {
    // Remove from game world so we can add the card to the hand
    Vector2 cardAbsolutePos = card.absolutePosition;
    if (card.parent != null) {
      card.removeFromParent();
    }

    // Add it to the deck and then update position to start off where it currently was
    add(card);
    card.position = cardAbsolutePos - absolutePosition;

    // Move to new location and set priority
    Vector2 newHandPos = _getNewCardPos();

    card.priority = currCardPriority++;
    card.flip(duration: 0.3);
    await card.moveTo(newHandPos, EffectController(duration: 0.5));

    // Set position after movement
    card.position = newHandPos;

    // Return if the card would be a duplicate
    return isDuplicate(card);
  }

  /// Will add the card to the hand, this doesn't handle UI (see animateCardArrival)
  void addCardtoHand(NumberCard card) {
    // Add it to the hand
    numberHand.add(card);
    numHandSet.add(card.value);

    card.setDraggable(true);
    card.onDragEndReturnTo(card.position, card.priority);
  }

  void removeNumberCard(NumberCard card, {bool removeFromUi = true}) {
    if (card.isMounted && removeFromUi) {
      card.removeFromParent();
    }

    card.setDraggable(false);
    card.setClickable(false);

    numberHand.remove(card);
    numHandSet.remove(card.value);

    currCardPriority--;
  }

  void removeAllCards({bool removeFromUi = true}) {
    for (final c in numberHand) {
      if (c.isMounted && removeFromUi) {
        c.removeFromParent();
      }
      c.setDraggable(false);
      c.setClickable(false);
    }

    currCardPriority = priority;
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
  // For fast removal order, this is the order of the deck in the hand
  final List<Card> cardHandOrder = [];

  // Get the total value card length
  int get valueCardLength => minusHandLength + addHand.length + multHand.length;

  DynamicCardHolder() : super(anchor: Anchor.bottomLeft) {
    priority = 10;
    currCardPriority += priority;
  }

  // Updates all card positions based on order (card assumed to be already added to arrays (lengths updated))
  // Order of rendering is Add/Minus/Mult/Event
  // Future<void> _updateCardPosOnAdd(Card card) async {
  //   int totalCardsAtPlacement = 0;
  //   Vector2 newCardPos = Vector2(position.x + Card.halfCardSize.x, 0);

  //   // Determine current placement total cards
  //   if (card is PlusCard) {
  //     totalCardsAtPlacement += addHand.length;
  //   } else if (card is MinusCard) {
  //     totalCardsAtPlacement += addHand.length + minusHandLength;
  //   } else if (card is MultCard) {
  //     totalCardsAtPlacement +=
  //         addHand.length + minusHandLength + multHand.length;
  //   } else if (card is EventActionCard) {
  //     totalCardsAtPlacement +=
  //         addHand.length + minusHandLength + multHand.length + eventHand.length;
  //   }
  //   newCardPos.x = newCardPos.x + (totalCardsAtPlacement * cardPosOffset.x);

  //   // Update current cards position and priority
  //   // NOTE: priority is the same as total cards at placement + priority of DCH
  //   card.position = newCardPos;
  //   currCardPriority = totalCardsAtPlacement + priority;
  //   card.priority = currCardPriority;
  //   card.setDraggable(true);
  //   card.onDragEndReturnTo(card.position, card.priority);

  //   // if plus --> update minus/mult/event
  //   // if minus --> update mult/event
  //   // if mult --> update event
  //   // Update the next cards positions
  //   bool updateNext = false;
  //   if (card is PlusCard) {
  //     for (final c in minusHandMap.entries) {
  //       final minusList = minusHandMap[c.key];
  //       if (minusList != null) {
  //         for (MinusCard mc in minusList) {
  //           mc.position = Vector2(
  //             position.x +
  //                 Card.halfCardSize.x +
  //                 (++currCardPriority * cardPosOffset.x),
  //             0,
  //           );
  //           mc.priority = currCardPriority;
  //           mc.onDragEndReturnTo(mc.position, mc.priority);
  //         }
  //       }
  //     }
  //     // Update mult cards next
  //     updateNext = true;
  //   }
  //   if (updateNext || card is MinusCard) {
  //     for (var mtc in multHand) {
  //       mtc.position = Vector2(
  //         position.x +
  //             Card.halfCardSize.x +
  //             (++currCardPriority * cardPosOffset.x),
  //         0,
  //       );
  //       mtc.priority = currCardPriority;
  //       mtc.onDragEndReturnTo(mtc.position, mtc.priority);
  //     }
  //     updateNext = true;
  //   }
  //   if (updateNext || card is MultCard) {
  //     for (var eac in eventHand) {
  //       eac.position = Vector2(
  //         position.x +
  //             Card.halfCardSize.x +
  //             (++currCardPriority * cardPosOffset.x),
  //         0,
  //       );
  //       eac.priority = currCardPriority;
  //       eac.onDragEndReturnTo(eac.position, eac.priority);
  //     }
  //   }
  // }

  // Priority is determined by the total hand length (before adding new card) and added with the card holders priority
  // NOTE: add card to cardHandOrder and other values after calling this to get the new cards priority
  int _getNextCardPriority() {
    return priority + cardHandOrder.length + 1;
  }

  int _getOrderBasedCardPriority(int index) {
    return priority + index + 1;
  }

  /// Finds the locations for a card given it's index position in cardHandOrder array
  Vector2 _getOrderBasedCardPosition(int index) {
    if (index < 0) return Vector2.all(0);
    Vector2 newCardPos = Vector2(position.x + Card.halfCardSize.x, 0);
    newCardPos.x = newCardPos.x + ((index + 1) * cardPosOffset.x);
    return newCardPos;
  }

  /// Gets the latest position based on the total number of all cards in dynamic card holder
  Vector2 _getNewCardPos() {
    return _getOrderBasedCardPosition(cardHandOrder.length);
  }

  /// This will update the cards in cardHandOrder starting at a given index to update it so that they are all next to each other
  Future<void> updateCardPositionOnRemoval({int startCardIdx = 0}) async {
    if (startCardIdx < 0) return;

    for (int i = startCardIdx; i < cardHandOrder.length; ++i) {
      final c = cardHandOrder[i];
      Vector2 newCardPos = _getOrderBasedCardPosition(i);
      c.priority = _getOrderBasedCardPriority(i);

      // Only update position if it needs to
      if (newCardPos.x != c.deckReturnTo?.x ||
          newCardPos.y != c.deckReturnTo?.y) {
        // Disable drag then set up new card position and re-enable drag to it
        c.setDraggable(false);
        await c.moveTo(newCardPos, EffectController(duration: 0.2));
        c.setDraggable(true);
        c.onDragEndReturnTo(newCardPos, c.priority);
      }
    }
  }
  // Call this after you have removed the card from the array
  // Order of rendering is Add/Minus/Mult/Event
  // void _updateDeckPositionsOnCardRemoval(CardType cardType) {
  //   int cardTypeIndex = 0;
  //   int cardPriority = 0;
  //   // Vector2 cardPos = Vector2(position.x + Card.halfCardSize.x, 0);

  //   if (cardType == CardType.valueActionMinusCard) {
  //     cardTypeIndex = 1;
  //     cardPriority = addHand.length;
  //     // cardPos.x = cardPos.x + (addHand.length * cardPosOffset.x);
  //   } else if (cardType == CardType.valueActionMultCard) {
  //     cardTypeIndex = 2;
  //     cardPriority = addHand.length + minusHandLength;
  //     // cardPos.x = cardPos.x + (cardPriority * cardPosOffset.x);
  //   } else if (cardType == CardType.eventActionCard) {
  //     cardTypeIndex = 3;
  //     cardPriority = addHand.length + minusHandLength + multHand.length;
  //     // cardPos.x = cardPos.x + (cardPriority * cardPosOffset.x);
  //   }

  //   // update add cards
  //   if (cardTypeIndex == 0) {
  //     for (final c in addHand) {
  //       c.position = Vector2(
  //         position.x + Card.halfCardSize.x + (++cardPriority * cardPosOffset.x),
  //         0,
  //       );
  //       c.priority = cardPriority;
  //       c.onDragEndReturnTo(c.position, c.priority);
  //     }
  //   }

  //   // update minus cards
  //   if (cardTypeIndex <= 1) {
  //     for (final c in minusHandMap.entries) {
  //       final minusList = minusHandMap[c.key];
  //       if (minusList == null) continue;

  //       // Update all minus cards
  //       for (MinusCard mc in minusList) {
  //         mc.position = Vector2(
  //           position.x +
  //               Card.halfCardSize.x +
  //               (++cardPriority * cardPosOffset.x),
  //           0,
  //         );
  //         mc.priority = cardPriority;
  //         mc.onDragEndReturnTo(mc.position, mc.priority);
  //       }
  //     }
  //   }

  //   // update mult cards
  //   if (cardTypeIndex <= 2) {
  //     for (final c in multHand) {
  //       c.position = Vector2(
  //         position.x + Card.halfCardSize.x + (++cardPriority * cardPosOffset.x),
  //         0,
  //       );
  //       c.priority = cardPriority;
  //       c.onDragEndReturnTo(c.position, c.priority);
  //     }
  //   }

  //   // update event cards
  //   if (cardTypeIndex <= 3) {
  //     for (final c in eventHand) {
  //       c.position = Vector2(
  //         position.x + Card.halfCardSize.x + (++cardPriority * cardPosOffset.x),
  //         0,
  //       );
  //       c.priority = cardPriority;
  //       c.onDragEndReturnTo(c.position, c.priority);
  //     }
  //   }

  //   // Update priority
  //   currCardPriority = cardPriority;
  // }

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

  Future<void> addCardtoHand(Card c) async {
    // Remove from game world so we can add the card to the hand
    Vector2 cardAbsolutePos = c.absolutePosition;
    if (c.parent != null) {
      c.removeFromParent();
    }

    // Add it to the deck and then update position to start off where it currently was
    add(c);
    c.position = cardAbsolutePos - absolutePosition;

    // Move to new location and set priority
    Vector2 newHandPos = _getNewCardPos();

    // Add to the end of the existing position
    c.priority = _getNextCardPriority();
    if (c.isFaceDown) {
      c.flip(duration: 0.3);
    }
    await c.moveTo(newHandPos, EffectController(duration: 0.5));
    c.setDraggable(true);
    c.onDragEndReturnTo(newHandPos, c.priority);

    // Add to backend structure
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

    // Add card to all cards
    cardHandOrder.add(c);
  }

  /// Change border color of cards in deck to show that they are selectable
  /// NOTE: this does not make them selectable, just changes the UI element
  /// Toggleing selectable false will update all settings back to regular card settings
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

  /// Removes a card by reference
  Future<void> removeCard(Card c) async {
    if (c is PlusCard) {
      print("REMOVING PLUS CARD");
      await removePlusCard(c);
    } else if (c is MultCard) {
      print("REMOVING MULT CARD");
      await removeMultCard(c);
    } else if (c is MinusCard) {
      print("REMOVING MINUS CARD");
      await removeSingleMinusCard(c.value);
    } else if (c is EventActionCard) {
      print("REMOVING EVENT ACTION CARD");
      await removeEventCard(c);
    }
  }

  Future<DoubleChanceCard?> removeDoubleChanceCardInHand({
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) async {
    DoubleChanceCard? doubleChanceCard;
    for (EventActionCard card in eventHand) {
      if (card is DoubleChanceCard) {
        doubleChanceCard = card;
        eventHand.remove(card);
        cardHandOrder.remove(card);
        //Remove it visually from game tree
        if (card.isMounted && removeFromUi) {
          card.removeFromParent();
        }
        break;
      }
    }

    if (updateDeckPosition) {
      // _updateDeckPositionsOnCardRemoval(CardType.eventActionCard);
      await updateCardPositionOnRemoval();
    }
    return doubleChanceCard;
  }

  /// Will remove a card type from order by if the card is of type T from cardHandOrder
  List<T> _removeFromCardHandOrderByType<T>({bool removeFromUi = true}) {
    // Save the type of card that were deleted in case user needs it
    List<T> typeCardDeletion = [];

    // Iterate and delete items from the event hand
    int i = 0, length = cardHandOrder.length;
    while (i < length) {
      final c = cardHandOrder[i];
      if (c is T) {
        // Remove from card hand order and then update length to end loop
        bool removed = cardHandOrder.remove(c);
        length = cardHandOrder.length;

        // Remove from ui if necessary
        if (removed && c.isMounted && removeFromUi) {
          c.removeFromParent();
        }

        typeCardDeletion.add(c as T);

        if (!removed) {
          // Safe increment if card was not removed for some reason
          i++;
        }
      } else {
        // Iterate only on non event, removal will update the length
        i++;
      }
    }

    return typeCardDeletion;
  }

  Future<void> removeEventCard(
    EventActionCard ec, {
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) async {
    bool removed = cardHandOrder.remove(ec);
    eventHand.remove(ec);

    if (removed && ec.isMounted && removeFromUi) {
      ec.removeFromParent();
    }

    if (removed && updateDeckPosition) {
      // _updateDeckPositionsOnCardRemoval(CardType.eventActionCard);
      await updateCardPositionOnRemoval();
    }
  }

  Future<void> removeAllEventHand({
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) async {
    _removeFromCardHandOrderByType<EventActionCard>(removeFromUi: removeFromUi);

    eventHand.clear();
    if (updateDeckPosition) {
      // _updateDeckPositionsOnCardRemoval(CardType.eventActionCard);
      await updateCardPositionOnRemoval();
    }
  }

  Future<void> removePlusCard(
    PlusCard c, {
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) async {
    bool removed = cardHandOrder.remove(c);
    addHand.remove(c);
    if (removed && removeFromUi && c.isMounted) {
      c.removeFromParent();
    }

    if (removed && updateDeckPosition) {
      // _updateDeckPositionsOnCardRemoval(CardType.valueActionPlusCard);
      await updateCardPositionOnRemoval();
    }
  }

  Future<List<PlusCard>> removeAllAddHand({
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) async {
    List<PlusCard> remd = _removeFromCardHandOrderByType<PlusCard>(
      removeFromUi: removeFromUi,
    );
    addHand.clear();

    if (updateDeckPosition) {
      // _updateDeckPositionsOnCardRemoval(CardType.valueActionPlusCard);\
      await updateCardPositionOnRemoval();
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
  Future<MinusCard?> removeSingleMinusCard(
    double minusValue, {
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) async {
    final minusList = minusHandMap[minusValue];
    if (minusList != null && minusList.isNotEmpty) {
      var mc = minusList.removeLast();
      minusHandLength--;
      cardHandOrder.remove(mc);
      if (mc.isMounted && removeFromUi) {
        mc.removeFromParent();
      }
      if (updateDeckPosition) {
        // _updateDeckPositionsOnCardRemoval(CardType.valueActionMinusCard);
        await updateCardPositionOnRemoval();
      }
      return mc;
    }
    return null;
  }

  Future<List<MinusCard>> removeAllMinusHand({
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) async {
    List<MinusCard> remd = [];
    for (final c in minusHandMap.entries) {
      final minusList = minusHandMap[c.key];
      if (minusList != null) {
        for (MinusCard mc in minusList) {
          if (mc.isMounted && removeFromUi) {
            mc.removeFromParent();
          }
          cardHandOrder.remove(mc);
          remd.add(mc);
        }
      }
    }

    minusHandMap.clear();
    minusHandLength = 0;

    if (updateDeckPosition) {
      // _updateDeckPositionsOnCardRemoval(CardType.eventActionCard);
      await updateCardPositionOnRemoval();
    }
    return remd;
  }

  Future<void> removeMultCard(
    MultCard c, {
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) async {
    cardHandOrder.remove(c);
    bool removed = multHand.remove(c);
    if (removed && c.isMounted && removeFromUi) {
      c.removeFromParent();
    }
    if (removed && updateDeckPosition) {
      // _updateDeckPositionsOnCardRemoval(CardType.valueActionMultCard);
      await updateCardPositionOnRemoval();
    }
  }

  Future<List<MultCard>> removeAllMultHand({
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) async {
    List<MultCard> remd = _removeFromCardHandOrderByType<MultCard>(
      removeFromUi: removeFromUi,
    );

    multHand.clear();
    if (updateDeckPosition) {
      // _updateDeckPositionsOnCardRemoval(CardType.valueActionMultCard);
      await updateCardPositionOnRemoval();
    }
    return remd;
  }

  Future<void> removeAllValueHands({
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) async {
    await removeAllAddHand(
      updateDeckPosition: updateDeckPosition,
      removeFromUi: removeFromUi,
    );
    await removeAllMinusHand(
      updateDeckPosition: updateDeckPosition,
      removeFromUi: removeFromUi,
    );
    await removeAllMultHand(
      updateDeckPosition: updateDeckPosition,
      removeFromUi: removeFromUi,
    );
  }

  // TODO: verify that cards don't have to removed from UI
  Future<void> removeAllCards({
    bool updateDeckPosition = true,
    bool removeFromUi = true,
  }) async {
    await removeAllValueHands(
      updateDeckPosition: updateDeckPosition,
      removeFromUi: removeFromUi,
    );
    await removeAllEventHand(
      updateDeckPosition: updateDeckPosition,
      removeFromUi: removeFromUi,
    );
  }
}
