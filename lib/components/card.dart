import 'dart:math';

enum CardType {
  numberCard("Number card of value: "),
  valueActionCard("Value Action Card of value: "),
  eventActionCard("Event Action Card with effect: ");

  final String label;
  const CardType(this.label);
}

//Base card class
abstract class Card {
  late CardType cardType;

  Card({required this.cardType});

  //TO DO: Add players as param inputs for executeOnEvent
  //once player classes have been constructed
  void executeOnEvent();
  double executeOnStay(double currentValue);
  void description();
}

//Base Number Card Class
class NumberCard extends Card {
  late final double _value;
  NumberCard({required double value}) : super(cardType: CardType.numberCard) {
    _value = value;
  }

  double get value => _value;

  @override
  void executeOnEvent() {}

  @override
  void description() {
    print("${cardType.label} ${_value}");
  }

  @override
  double executeOnStay(double currentValue) {
    currentValue += _value;
    return currentValue;
  }
}

//Event Action Card Class
abstract class EventActionCard extends Card {
  EventActionCard() : super(cardType: CardType.eventActionCard);

  //executeOnEvent depends on the specific event action card
  //like if  it's freeze, flip three, etc. Thus it is left to
  //the child class itself

  @override
  double executeOnStay(double currentValue) {
    print("Check which event action cards have executions on player stay");
    return currentValue;
  }
}

//Value Action Abstract Card:
abstract class ValueActionCard extends Card {
  late final double _value;
  ValueActionCard({required double value})
    : super(cardType: CardType.valueActionCard) {
    _value = value;
  }

  double get value => _value;

  @override
  void executeOnEvent() {}
}

class PlusCard extends ValueActionCard {
  PlusCard({required super.value});

  @override
  double executeOnStay(double currentValue) {
    currentValue += _value;
    return currentValue;
  }

  @override
  void description() {
    print("${cardType.label} +$_value");
  }
}

class MultCard extends ValueActionCard {
  MultCard({required super.value});

  @override
  double executeOnStay(double currentValue) {
    currentValue *= _value;
    return currentValue;
  }

  @override
  void description() {
    print("${cardType.label} x$_value");
  }
}

class MinusCard extends ValueActionCard {
  MinusCard({required super.value});

  @override
  double executeOnStay(double currentValue) {
    currentValue -= _value;
    return currentValue;
  }

  @override
  void description() {
    print("${cardType.label} -$_value");
  }
}

class FreezeCard extends EventActionCard {
  FreezeCard();

  //No special execute on stay function
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  //Freezes other player
  @override
  void executeOnEvent() {
    //TO DO: Impleme
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} the player that gets chosen will be frozen, forcing them to stay for the round",
    );
  }
}

class FlipThreeCard extends EventActionCard {
  FlipThreeCard();

  //No special execute on stay
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  //Forces player to flip 3 cards
  @override
  void executeOnEvent() {
    //To Do: implement
    return;
  }

  @override
  void description() {
    print("${cardType.label} the player that gets chosen must flip 3 cards!");
  }
}

class DoubleChanceCard extends EventActionCard {
  DoubleChanceCard();

  //No special execute on stay
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  //Grants double chance
  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} the player that gets chosen is granted double chance!",
    );
  }
}

//Magnifying Glass: Can see the next card in the deck before making decision
class MagnifyingGlassCard extends EventActionCard {
  MagnifyingGlassCard();

  //No special execute on stay
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} the player that gets chosen is allowed to take a peek at the next card in the deck!",
    );
  }
}

//Thief: lets you choose a player and then steal all of their value action cards
class ThiefCard extends EventActionCard {
  ThiefCard();
  //No special execute on stay
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} you get to choose a player to steal all their value action cards!",
    );
  }
}

//Effect: You are to take a card from anywhere inside the deck. Not yet revealing the card,
//you can choose to give it to yourself or any player.
//Once such a player is chosen, they reveal it.
class CribberCard extends EventActionCard {
  CribberCard();

  //No special execute on stay
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} you get to crib a random card from the deck, then give it to any player!",
    );
  }
}

//Chosen player is told when the next 4 cards are, but not necessarily in the actual order that they will appear
class ForecasterCard extends EventActionCard {
  ForecasterCard();

  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} forecasts the next 4 cards, but not necessarily in the order that they will appear!",
    );
  }
}

//Regressive Income Tax Card
class SalesTax extends EventActionCard {
  SalesTax();
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} player gets to enforce a sales tax on their player of choice!",
    );
  }
}

//Progressive Income Tax Card
class IncomeTax extends EventActionCard {
  IncomeTax();
  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print("${cardType.label} enforces a progressive income tax on the player!");
  }
}

//Lucky Six Dice Card: Roll a seven sided die. If it is 1-5, gain 6 points.
//Else, lose 7 points. Can choose to roll up to 7 times.
class LuckySixSidedDieCard extends EventActionCard {
  LuckySixSidedDieCard();

  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} player of choice gets to roll a lucky seven sided die! A roll that is between 1 and 5 earns you 6 points, while a roll of 6 or 7 makes you lose 7 points!",
    );
  }
}

//Sunk Prophet: Chosen player gets effect: Roll a 7 sided die. If you get 1-5, you lose
//7 points. Else, a 6 or 7 earns you 13 points. Do this seven times.
class SunkProphet extends EventActionCard {
  SunkProphet();

  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} player of choice is forced to roll a 13-sided die! A roll that is not a 6 or 7 loses them 7 points, while a roll of 6 or 7 gains them 13 points! They must continue to roll until they roll a 6 or 7.",
    );
  }
}

//Choice draw: User draws two cards, chooses one card to keep, discards other card
class ChoiceDraw extends EventActionCard {
  ChoiceDraw();

  @override
  double executeOnStay(double currentValue) {
    print("This function does nothing");
    return currentValue;
  }

  @override
  void executeOnEvent() {
    //To do: implement
    return;
  }

  @override
  void description() {
    print(
      "${cardType.label} User draws two cards, and chooses one of the cards to keep while discarding the other!",
    );
  }
}

class CardDeck {
  late List<Card> deckList;
  late Map<int, int> cardsLeft;
  late List<Card> discardPile;
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

      cardsLeft[-1] = cardsLeft[-1]! + 12;
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
}
