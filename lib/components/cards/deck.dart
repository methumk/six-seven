import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/event_cards/choice_draw.dart';
import 'package:six_seven/components/cards/event_cards/cribber_card.dart';
import 'package:six_seven/components/cards/event_cards/double_chance_card.dart';
import 'package:six_seven/components/cards/event_cards/flip_three_card.dart';
import 'package:six_seven/components/cards/event_cards/forecaster_card.dart';
import 'package:six_seven/components/cards/event_cards/freeze_card.dart';
import 'package:six_seven/components/cards/event_cards/income_tax_card.dart';
import 'package:six_seven/components/cards/event_cards/lucky_die_card.dart';
import 'package:six_seven/components/cards/event_cards/magnifying_glass_card.dart';
import 'package:six_seven/components/cards/event_cards/reverse_turn.dart';
import 'package:six_seven/components/cards/event_cards/sales_tax_card.dart';
import 'package:six_seven/components/cards/event_cards/sunk_prophet_Card.dart';
import 'package:six_seven/components/cards/event_cards/thief_card.dart';
import 'package:six_seven/components/cards/value_action_cards/minus_card.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart';
import 'package:six_seven/components/cards/value_action_cards/place_card.dart';

class CardDeck extends PositionComponent with TapCallbacks {
  late List<Card> deckList;
  late Map<int, int> cardsLeft;
  late List<Card> discardPile;

  late final SpriteComponent deckComponent;
  late final SpriteComponent discardComponent;

  CardDeck() {
    deckList = [];
    discardPile = [];
    cardsLeft = {
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
      //-1 is reserved for any card that is not a number card
      -1: 0,
    };
    initNumberCards();
    initValueActionCards();
    initEventActionCards();
    deckList.shuffle();
  }

  void initNumberCards() {
    //Append a 0 number card
    deckList.add(NumberCard(value: 0));
    cardsLeft[0] = cardsLeft[0]! + 1;
    //Append rest of cards.
    //There should be n cards of value n.
    for (int i = 1; i <= 12; i++) {
      for (int j = 1; j <= i; j++) {
        deckList.add(NumberCard(value: i.toDouble()));
        cardsLeft[i] = cardsLeft[i]! + 1;
      }
      //Let's have two minus cards of the same value for now
      for (int j = 1; j <= 2; j++) {
        deckList.add(MinusCard(value: i.toDouble()));
        cardsLeft[-1] = cardsLeft[-1]! + 1;
      }
    }
  }

  void initValueActionCards() {
    //Add the +2's, +4's, ... +10 cards
    int cardCeiling = 10;
    for (int i = 2; i <= 10; i += 2) {
      //max(2, card ceiling -i) so that higher value cards have less chance of appearing

      for (int j = 1; j <= max(2, cardCeiling - i); j++) {
        deckList.add(PlusCard(value: i.toDouble()));
        cardsLeft[-1] = cardsLeft[-1]! + 1;
      }
    }
    //Add the mult cards (since this is digital, we can easily make x.5's, etc)
    //We first add the mult cards that actually hurt your score. These should be rarer
    //because of their negative effects.
    //It currently starts at 0, so there's a x0 card lmfao.
    for (double i = 0; i <= 1.0; i += .25) {
      deckList.add(MultCard(value: i));
      cardsLeft[-1] = cardsLeft[-1]! + 1;
    }
    //For the good mult cards, we add a lot of cards from x1.1-1.5, then have only one x2
    cardCeiling = 6;
    for (double i = 1.1; i <= 1.5; i += .1) {
      for (double j = 1; j <= cardCeiling - (i - 1) * 10; j++) {
        deckList.add(MultCard(value: i));
        cardsLeft[-1] = cardsLeft[-1]! + 1;
      }
    }
    //Add the single x2 card
    //I think this is too op from actual game experience, remove for now
    // deckList.add(MultCard(value: 2));
    // cardsLeft[-1] = cardsLeft[-1]! + 1;
  }

  void initEventActionCards() {
    for (int i = 0; i < 3; i++) {
      deckList.add(FreezeCard());
      deckList.add(FlipThreeCard());
      deckList.add(DoubleChanceCard());
      deckList.add(MagnifyingGlassCard());
      deckList.add(ThiefCard());
      deckList.add(CribberCard());
      deckList.add(ForecasterCard());
      deckList.add(IncomeTax());
      deckList.add(SalesTax());
      deckList.add(LuckySixSidedDieCard());
      deckList.add(SunkProphet());
      deckList.add(ChoiceDraw());
      deckList.add(ReverseTurn());
      cardsLeft[-1] = cardsLeft[-1]! + 13;
    }
  }

  //Refilling the deck
  void refill() {
    int numDiscardedCards = discardPile.length;
    for (int i = 0; i < numDiscardedCards; i++) {
      Card discardedCard = discardPile.removeLast();
      if (discardedCard is NumberCard) {
        double value = discardedCard.value;
        deckList.add(discardedCard);
        cardsLeft[value.toInt()] = cardsLeft[value.toInt()]! + 1;
      } else {
        deckList.add(discardedCard);
        cardsLeft[-1] = cardsLeft[-1]! + 1;
      }
    }
    //After all cards from discard pile is added, reshuffle deck
    deckList.shuffle();
  }

  //Method for drawing
  void draw() {
    //First, check if deck is empty. Then refill before drawing
    if (deckList == []) {
      refill();
    }

    //Draw a card
    Card newCard = deckList.removeLast();
    if (newCard is NumberCard) {
      double value = newCard.value;
      //Decrement cardsLeft
      cardsLeft[value.toInt()] = cardsLeft[value.toInt()]! - 1;
    } else {
      //Else it's a value or event action card, so decrement -1
      cardsLeft[-1] = cardsLeft[-1]! - 1;
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    print("Tap up");
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final faceDownCardImage = await Flame.images.load(
      "game_ui/card_face_down.jpg",
    );

    deckComponent = SpriteComponent(
      sprite: Sprite(faceDownCardImage, srcSize: Vector2(323, 466)),
      size: Card.cardSizeFirstPerson,
      position: Vector2(
        position.x - (Card.cardSizeFirstPerson.x * 1.15),
        position.y - Card.cardSizeFirstPerson.y,
      ),
    );
    discardComponent = SpriteComponent(
      sprite: Sprite(faceDownCardImage, srcSize: Vector2(323, 466)),
      size: Card.cardSizeFirstPerson,
      position: Vector2(
        position.x + (Card.cardSizeFirstPerson.x * .15),
        position.y - Card.cardSizeFirstPerson.y,
      ),
    );

    addAll([deckComponent, discardComponent]);
  }

  @override
  bool get debugMode => true;
}
