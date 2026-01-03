import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Curves;
import 'package:flutter/painting.dart';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/card_component.dart';
import 'package:six_seven/components/cards/event_cards/choice_draw.dart';
import 'package:six_seven/components/cards/event_cards/double_chance_card.dart';
import 'package:six_seven/components/cards/event_cards/flip_three_card.dart';
import 'package:six_seven/components/cards/event_cards/forecaster_card.dart';
import 'package:six_seven/components/cards/event_cards/freeze_card.dart';
import 'package:six_seven/components/cards/event_cards/income_tax_card.dart';
import 'package:six_seven/components/cards/event_cards/lucky_die_card.dart';
import 'package:six_seven/components/cards/event_cards/top_peek_card.dart';
import 'package:six_seven/components/cards/event_cards/discarder_card.dart';
import 'package:six_seven/components/cards/event_cards/redeemer_card.dart';
import 'package:six_seven/components/cards/event_cards/reverse_turn_card.dart';
import 'package:six_seven/components/cards/event_cards/sunk_prophet_Card.dart';
import 'package:six_seven/components/cards/event_cards/thief_card.dart';
import 'package:six_seven/components/cards/value_action_cards/minus_card.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart';
import 'package:six_seven/components/cards/value_action_cards/plus_card.dart';
import 'package:six_seven/components/rounded_border_component.dart';
import 'package:six_seven/data/enums/event_cards.dart';
import 'package:six_seven/pages/game/game_screen.dart';

class CardDeck extends PositionComponent
    with HasGameReference<GameScreen>, TapCallbacks {
  static final Vector2 discardPosOffset = Vector2(Card.cardSize.x * 2.5, 0);
  static final Vector2 deckPosOffset = Vector2(Card.cardSize.x * -2.5, 0);
  static final Vector2 deckOutlineSize = Vector2(
    Card.cardSize.x * 1.33,
    Card.cardSize.y * 1.15,
  );
  // top card positioned from bottom center, so it will be shifted up by this amount
  static final Vector2 deckTopOffset = Vector2(
    0,
    (deckOutlineSize.y - Card.cardSize.y) / 2,
  );

  static Vector2 getDiscardCardPosition() {
    return discardPosOffset - deckTopOffset;
  }

  static Vector2 getDeckCardPosition() {
    return deckPosOffset - deckTopOffset;
  }

  // Deck pile visualization
  late final RoundedBorderComponent _deckOutline; // To show where the deck goes
  late final CardComponent _deckTopCard; // To show that the deck has 1+ cards
  late final TextComponent
  _deckTextLabel; // Shows deck with the count of the cards remaining
  late final TextComponent _shufflingLabel;

  // Discard pile visualization
  late final RoundedBorderComponent
  _discardOutline; // To show where the discard goes
  // points to card used to show last discarded card flipped up
  Card? _discardTopCard;
  late final TextComponent _discardTextLabel;

  late List<Card> deckList;
  late List<Card> discardPile;
  late Map<int, int> numberCardsLeft;
  late Map<int, int> plusMinusCardsLeft;
  late Map<double, int> multCardsLeft;
  late Map<EventCardEnum, int> eventCardsLeft;

  //Hash map of Numerical values assigned to each event card for EV calculation
  //case when you are only player left in round
  late Map<EventCardEnum, double> eventNumericalEVAlone;
  //case when other players still in round
  late Map<EventCardEnum, double> eventNumericalEVNotAlone;
  late final SpriteComponent deckComponent;
  late final SpriteComponent discardComponent;

  int get deckListLength => deckList.length;
  int get discardLength => discardPile.length;

  CardDeck({required super.position}) : super(anchor: Anchor.bottomCenter) {
    deckList = [];
    discardPile = [];
    numberCardsLeft = {
      0: 0,
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
      6: 0,
      7: 0,
      8: 0,
      9: 0,
      10: 0,
      11: 0,
      12: 0,
      13: 0,
    };

    plusMinusCardsLeft = {
      -13: 0,
      -12: 0,
      -11: 0,
      -10: 0,
      -9: 0,
      -8: 0,
      -7: 0,
      -6: 0,
      -5: 0,
      -4: 0,
      -3: 0,
      -2: 0,
      -1: 0,
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
      6: 0,
      7: 0,
      8: 0,
      9: 0,
      10: 0,
    };

    multCardsLeft = {
      0.0: 0,
      .25: 0,
      .5: 0,
      .75: 0,
      1.0: 0,
      1.05: 0,
      1.1: 0,
      1.15: 0,
      1.2: 0,
      1.25: 0,
      1.3: 0,
      // 1.4: 0,
      // 1.5: 0,
    };

    eventCardsLeft = {
      EventCardEnum.ChoiceDraw: 0,
      EventCardEnum.Cribber: 0,
      EventCardEnum.DoubleChance: 0,
      EventCardEnum.FlipThree: 0,
      EventCardEnum.Forecaster: 0,
      EventCardEnum.Freeze: 0,
      EventCardEnum.IncomeTax: 0,
      EventCardEnum.LuckyDie: 0,
      EventCardEnum.ReverseTurn: 0,
      EventCardEnum.SalesTax: 0,
      EventCardEnum.SunkProphet: 0,
      EventCardEnum.Thief: 0,
      EventCardEnum.Discarder: 0,
      EventCardEnum.Redeemer: 0,
      EventCardEnum.TopPeek: 0,
    };

    eventNumericalEVAlone = {
      //TO DO: implement
    };

    // initNumberCards();
    // initValueActionCards();
    //TO DO: Uncomment once event cards are implemented
    initEventActionCards();
    deckList.shuffle();
  }

  void initNumberCards() {
    //Append a 0 number card
    deckList.add(NumberCard(value: 0));
    numberCardsLeft[0] = numberCardsLeft[0]! + 1;
    //Append rest of cards.
    //There should be 2n cards of value n.
    for (int i = 1; i <= 13; i++) {
      for (int j = 1; j <= 2 * i; j++) {
        deckList.add(NumberCard(value: i.toDouble()));
        numberCardsLeft[i] = numberCardsLeft[i]! + 1;
      }
    }
  }

  void initValueActionCards() {
    //Add the plus cards
    int cardCeiling = 7;
    for (int i = 1; i <= 10; i++) {
      //max(2, card ceiling -i) so that higher value cards have less chance of appearing

      for (int j = 1; j <= max(2, cardCeiling - i); j++) {
        deckList.add(PlusCard(value: i.toDouble()));
        plusMinusCardsLeft[i] = plusMinusCardsLeft[i]! + 1;
      }
    }
    //Let's have two minus cards of the same value for now
    for (int i = 1; i <= 13; i++) {
      for (int j = 1; j <= 2; j++) {
        deckList.add(MinusCard(value: i.toDouble()));
        plusMinusCardsLeft[-1 * i] = plusMinusCardsLeft[-1 * i]! + 1;
      }
    }
    //Add the mult cards (since this is digital, we can easily make x.5's, etc)
    //We first add the mult cards that actually hurt your score. These should be rarer
    //because of their negative effects.
    //It currently starts at 0, so there's a x0 card lmfao.

    //Because of precision error, use int i be multiplier value times 100,
    //and then the mult value would be divided by 100. This is because iteerating as a double
    //will cause precision errors :(
    for (int i = 0; i <= 100; i += 25) {
      double multiplierValue = i / 100;
      int? mcl = multCardsLeft[multiplierValue];
      if (mcl != null) {
        deckList.add(MultCard(value: multiplierValue));
        multCardsLeft[multiplierValue] = multCardsLeft[multiplierValue]! + 1;
      } else {
        print(
          "Null value encountered for multiplier value of ${multiplierValue}",
        );
      }
    }
    //For the good mult cards, we add a lot of cards from x1.1-1.5, then have only one x2
    cardCeiling = 70;
    for (int i = 105; i <= 130; i += 5) {
      double multiplierValue = i / 100;
      int? mcl = multCardsLeft[multiplierValue];

      //For each mult card, the number of those cards depend on the formula
      // max(1,cardCeiling - (i - 1)*2 * 10) . For example, for X1.1,
      //we have max(1,cardCeiling (1.1-1)i* 1- ) . If cardCeiling = 8, this is
      //max(1,8 - (.1) * 2 * 10) = 6
      //Hence when the loop increaments by .1, the number of cards for that value decrements by 2 cards
      if (mcl != null) {
        for (
          double j = 1;
          j <= (max(10, cardCeiling - (i - 100) * 2)) / 10;
          j++
        ) {
          deckList.add(MultCard(value: multiplierValue));
          multCardsLeft[multiplierValue] = multCardsLeft[multiplierValue]! + 1;
        }
      } else {
        print(
          "Null value encountered for multiplier value: ${multiplierValue}",
        );
      }
    }
    //Add the single x2 card
    //I think this is too op from actual game experience, remove for now
    // deckList.add(MultCard(value: 2));
    // cardsLeft[-1] = cardsLeft[-1]! + 1;
  }

  void initEventActionCards() {
    for (int i = 1; i <= 3; i++) {
      // deckList.add(FreezeCard());
      // deckList.add(FlipThreeCard());
      // deckList.add(DoubleChanceCard());
      deckList.add(TopPeekCard());
      // deckList.add(ThiefCard());
      // // deckList.add(CribberCard());
      // deckList.add(ForecasterCard());
      // deckList.add(IncomeTax());
      // // deckList.add(SalesTax());
      // deckList.add(LuckyDieCard());
      // deckList.add(SunkProphet());
      // deckList.add(ChoiceDraw());
      // deckList.add(ReverseTurnCard());
      // deckList.add(DiscarderCard());
      // deckList.add(RedeemerCard());
      // //Add to eventCardsLeft
      // eventCardsLeft[EventCardEnum.Freeze] =
      //     eventCardsLeft[EventCardEnum.Freeze]! + 1;
      // eventCardsLeft[EventCardEnum.FlipThree] =
      //     eventCardsLeft[EventCardEnum.FlipThree]! + 1;
      // eventCardsLeft[EventCardEnum.DoubleChance] =
      //     eventCardsLeft[EventCardEnum.DoubleChance]! + 1;
      // eventCardsLeft[EventCardEnum.Thief] =
      //     eventCardsLeft[EventCardEnum.Thief]! + 1;
      eventCardsLeft[EventCardEnum.TopPeek] =
          eventCardsLeft[EventCardEnum.TopPeek]! + 1;
      // // eventCardsLeft[EventCardEnum.Cribber] =
      // //     eventCardsLeft[EventCardEnum.Cribber]! + 1;
      // eventCardsLeft[EventCardEnum.Forecaster] =
      //     eventCardsLeft[EventCardEnum.Forecaster]! + 1;
      // eventCardsLeft[EventCardEnum.IncomeTax] =
      //     eventCardsLeft[EventCardEnum.IncomeTax]! + 1;
      // eventCardsLeft[EventCardEnum.SalesTax] =
      //     eventCardsLeft[EventCardEnum.SalesTax]! + 1;
      // eventCardsLeft[EventCardEnum.LuckyDie]! + 1;
      // eventCardsLeft[EventCardEnum.SunkProphet] =
      //     eventCardsLeft[EventCardEnum.SunkProphet]! + 1;
      // eventCardsLeft[EventCardEnum.ChoiceDraw] =
      //     eventCardsLeft[EventCardEnum.ChoiceDraw]! + 1;
      // eventCardsLeft[EventCardEnum.ReverseTurn] =
      //     eventCardsLeft[EventCardEnum.ReverseTurn]! + 1;
      // eventCardsLeft[EventCardEnum.Discarder] =
      //     eventCardsLeft[EventCardEnum.Discarder]! + 1;
      // eventCardsLeft[EventCardEnum.Redeemer] =
      //     eventCardsLeft[EventCardEnum.Redeemer]! + 1;
    }
  }

  //Refilling the deck
  Future<void> refill() async {
    int numDiscardedCards = discardPile.length;
    for (int i = 0; i < numDiscardedCards; i++) {
      // Remove from discard and then reset card settings
      Card discardedCard = discardPile.removeLast();
      print("Refilling discard card priority: ${discardedCard.priority}");
      discardedCard.resetCardSettings();

      // Add to deck pile
      deckList.add(discardedCard);

      // Update special event card holders
      if (discardedCard is NumberCard) {
        double value = discardedCard.value;
        numberCardsLeft[value.toInt()] = numberCardsLeft[value.toInt()]! + 1;
      } else if (discardedCard is PlusCard) {
        deckList.add(discardedCard);
        double value = discardedCard.value;
        plusMinusCardsLeft[value.toInt()] =
            plusMinusCardsLeft[value.toInt()]! + 1;
      } else if (discardedCard is MinusCard) {
        double value = discardedCard.value;
        plusMinusCardsLeft[-1 * value.toInt()] =
            plusMinusCardsLeft[-1 * value.toInt()]! + 1;
      } else {
        //Currently there is no data structure seeing the number of each event action cards]
        //left in deck, but there was,
        //make changes here
      }
    }

    //After all cards from discard pile is added, reshuffle deck
    deckList.shuffle();

    // Show top card for deck/remove top discard card
    _setDeckCardVisibility(true);
    _removeTopDiscardedCard();

    // Update deck and discard labels
    _updateDeckTextLabel();
    _updateDiscardTextLabel();

    // Show shuffling text
    _shufflingLabel.text = getShufflingTextLabel(true);
    await Future.delayed(Duration(milliseconds: 700));
    _shufflingLabel.text = getShufflingTextLabel(false);
  }

  //Method for drawing
  Future<Card> draw({bool hideTopDeckOnEmpty = true}) async {
    //First, check if deck is empty. Then refill before drawing
    if (deckList.isEmpty) {
      print("DECK IS EMPTY - refilling!");
      await refill();
    }

    Card newCard = deckList.removeLast();

    // TODO: Determine if setDeckCardVisibility should be public and also used when card draw animation is running and not in draw itself
    // Update text label and hide top deck card if no cards left after this card is drawn
    _updateDeckTextLabel();
    if (deckList.isEmpty && hideTopDeckOnEmpty) {
      _setDeckCardVisibility(false);
    }

    if (newCard is NumberCard) {
      double value = newCard.value;
      //Decrement cardsLeft
      numberCardsLeft[value.toInt()] = numberCardsLeft[value.toInt()]! - 1;
    } else if (newCard is PlusCard) {
      double value = newCard.value;
      plusMinusCardsLeft[value.toInt()] =
          plusMinusCardsLeft[value.toInt()]! - 1;
    } else if (newCard is MinusCard) {
      double value = newCard.value;
      plusMinusCardsLeft[-1 * value.toInt()] =
          plusMinusCardsLeft[-1 * value.toInt()]! - 1;
    } else if (newCard is MultCard) {
      multCardsLeft[newCard.value] = multCardsLeft[newCard.value]! - 1;
    } else {
      eventCardsLeft[newCard.eventEnum] =
          eventCardsLeft[newCard.eventEnum]! - 1;
    }

    return newCard;
  }

  // NOTE this doesn't remove the card from the deck, it just holds a reference to the last card element
  // This means that deckTextLabel updating will do nothing because the deck didn't change - maybe call draw
  Card peek() {
    //First, check if deck is empty. Then refill before peeking
    // TODO: refill might have to be awaited
    if (deckList.isEmpty) {
      refill();
    }

    return deckList[deckList.length - 1];
  }

  List<Card> forecast() {
    //This is only if deckList is entirely empty
    //If length >0 and <3, just forecast rest of cards in deck
    if (deckList.isEmpty) {
      refill();
    }
    int numPeek = min(deckList.length, 4);
    List<Card> forecastCards = [];
    for (int i = 1; i <= numPeek; i++) {
      forecastCards.add(peek());
    }
    return forecastCards;
  }

  // Stores a card at front of the deck (aka, last item)
  void putCardBack(Card c, {int index = -1}) {
    if (index >= deckList.length || index == -1) {
      deckList.add(c);
    } else {
      deckList.insert(index, c);
    }

    // Update text after putting card back
    _updateDeckTextLabel();
    _updateDiscardTextLabel();
    // Make sure to update deck visiblity if deck not empty
    if (deckList.isNotEmpty) {
      _setDeckCardVisibility(true);
    }

    if (c is NumberCard) {
      double value = c.value;
      //Decrement cardsLeft
      numberCardsLeft[value.toInt()] = numberCardsLeft[value.toInt()]! + 1;
    } else if (c is PlusCard) {
      double value = c.value;
      plusMinusCardsLeft[value.toInt()] =
          plusMinusCardsLeft[value.toInt()]! + 1;
    } else if (c is MinusCard) {
      double value = c.value;
      plusMinusCardsLeft[-1 * value.toInt()] =
          plusMinusCardsLeft[-1 * value.toInt()]! + 1;
    } else if (c is MultCard) {
      multCardsLeft[c.value] = multCardsLeft[c.value]! + 1;
    } else {
      eventCardsLeft[c.eventEnum] = eventCardsLeft[c.eventEnum]! + 1;
    }
  }

  void addToDiscard(List<Card> newTrash, {int indexOfFaceUpDiscard = 0}) {
    discardPile = discardPile + newTrash;

    // Update discard UI
    if (indexOfFaceUpDiscard >= newTrash.length || indexOfFaceUpDiscard < 0) {
      indexOfFaceUpDiscard = 0;
    }
    _setNewDiscardedCard(newTrash[indexOfFaceUpDiscard]);

    // Update discard label
    _updateDiscardTextLabel();
  }

  // Animates an already drawn card (at game's rotation center), back to the deck
  // And handles backend card structure for put back by calling putCardBack
  // NOTE: this assumes a card has been taken out from deck and has been added to the game tree
  Future<void> putBackToDeckAnimation(Card c, {int index = -1}) async {
    // Undo drag and click
    c.setDraggable(false);
    c.setClickable(false);

    // Make sure it's face down before going back
    if (!c.isFaceDown) {
      await c.flip(duration: 0.3);
    }

    // Scale and then move to deck position
    c.scaleTo(Vector2.all(1.0), EffectController(duration: 0.3));
    await c.moveTo(getDeckCardPosition(), EffectController(duration: 0.4));

    // Make sure top deck card is visible (0 check cuz we are putting card in)
    if (deckListLength >= 0) {
      _setDeckCardVisibility(true);
    }

    // Remove existing card from gameworld
    c.resetCardSettings();
    c.removeFromParent();

    // This will put the card back in the strucutre,
    putCardBack(c, index: index);
  }

  // Animates card going from it's current position to the discard pile
  // NOTE: this assumes a card has been taken out from deck and has been added to the game tree
  Future<void> sendToDiscardPileAnimation(
    Card c, {
    double flipTime = 0.0,
  }) async {
    // Ensure card is face up
    if (c.isFaceDown) {
      if (flipTime <= 0.0) {
        c.flipInstant();
      } else {
        await c.flip(duration: flipTime);
      }
    }

    // Make sure scale is corrected
    await c.scaleTo(Vector2.all(1), EffectController(duration: 0.2));

    // Move the card to discard pile
    await c.moveTo(getDiscardCardPosition(), EffectController(duration: 0.2));

    // hand over card management to deck discard pile
    addToDiscard([c]);
  }

  void printDeck() {
    print("Deck list (${deckList.length}): $deckList");
  }

  void printDiscard() {
    print("Discard list (${discardPile.length}): $discardPile");
  }

  // Animates a list of card from start to finish and sets them as discarded
  Future<void> sendAllToDiscardPileAnimation(
    List<Card> cards, {
    double flipTime = 0.0,
  }) async {
    for (final c in cards) {
      await sendToDiscardPileAnimation(c, flipTime: flipTime);
    }
  }

  void _setDeckCardVisibility(bool show) {
    print("Setting deck card visibility: $show");
    _deckTopCard.setVisibility(show);
  }

  void _setNewDiscardedCard(Card card) {
    // Remove existing card from tree
    if (_discardTopCard != null) {
      _discardTopCard!.removeFromParent();
    }

    // Save current discarded card
    _discardTopCard = card;
    _discardTopCard!.setGlowing(false);
    _discardTopCard!.setClickable(false);
    _discardTopCard!.setDraggable(false);
  }

  Card? _removeTopDiscardedCard() {
    late Card? c;
    if (_discardTopCard != null) {
      c = _discardTopCard;
      _discardTopCard!.removeFromParent();
      _discardTopCard = null;
    }
    return c;
  }

  String getDeckTextLabel() {
    return "${deckList.length} Cards";
  }

  String getDiscardTextLabel() {
    return "${discardPile.length} Discarded";
  }

  String getShufflingTextLabel(bool show) {
    return show ? "Shuffling..." : "";
  }

  void _updateDeckTextLabel() {
    if (_deckTextLabel.isMounted) {
      _deckTextLabel.text = getDeckTextLabel();
    }
  }

  void _updateDiscardTextLabel() {
    if (_discardTextLabel.isMounted) {
      _discardTextLabel.text = getDiscardTextLabel();
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Deck visualization
    // The deck open outline
    _deckOutline =
        RoundedBorderComponent(borderRadius: 0, size: deckOutlineSize)
          ..priority = -1000
          ..anchor = anchor
          ..position = deckPosOffset;
    // Deck top card to show that cards are avilable to be drawn
    _deckTopCard =
        CardComponent(
            totalCardSize: Card.cardSize,
            isClickable: false,
            isDraggable: false,
            isGlowing: false,
            animateGlow: false,
            position: deckPosOffset - deckTopOffset,
          )
          ..priority = -1000
          ..anchor = anchor;
    // Show total cards in drawable deck
    _deckTextLabel = TextComponent(
      text: getDeckTextLabel(),
      size: Vector2(Card.cardSize.x * 4 / 6, Card.cardSize.y * 1 / 8),
      textRenderer: TextPaint(style: TextStyle(fontSize: 15)),
      anchor: Anchor.topCenter,
      priority: -1000,
      position: deckPosOffset,
    );

    // Shuffling label for the deck
    _shufflingLabel = TextComponent(
      text: getShufflingTextLabel(false),
      size: Vector2(Card.cardSize.x * 4 / 6, Card.cardSize.y * 1 / 8),
      textRenderer: TextPaint(style: TextStyle(fontSize: 15)),
      anchor: Anchor.topLeft,
      priority: -1000,
      // start shuffling text right below deck card text
      position: Vector2(
        deckPosOffset.x - (_deckTextLabel.size.x / 2),
        deckPosOffset.y + _deckTextLabel.size.y,
      ),
    );

    // Discard visualization
    _discardOutline =
        RoundedBorderComponent(borderRadius: 0, size: deckOutlineSize)
          ..priority = -1000
          ..anchor = anchor
          ..position = discardPosOffset;
    // Show total cards in drawable deck
    _discardTextLabel = TextComponent(
      text: getDiscardTextLabel(),
      size: Vector2(Card.cardSize.x * 4 / 6, Card.cardSize.y * 1 / 8),
      textRenderer: TextPaint(style: TextStyle(fontSize: 15)),
      anchor: Anchor.topCenter,
      priority: -1000,
      position: discardPosOffset,
    );

    addAll([
      _deckOutline,
      _deckTopCard,
      _deckTextLabel,
      _shufflingLabel,
      _discardOutline,
      _discardTextLabel,
    ]);
  }
}
