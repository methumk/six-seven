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
  ValueActionCard(double value) : super(cardType: CardType.valueActionCard) {
    _value = value;
  }

  double get value => _value;

  @override
  void executeOnEvent() {}
}

class PlusCard extends ValueActionCard {
  PlusCard(super.value);

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
  MultCard(super.value);

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
  MinusCard(super.value);

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



// class FlipThreeCard(EventActionCard):
//     def __init__(self):
//         self.instantActivation = True

//     def execute(self, playerTurnManager):
//         playerTurnManager.getPlayerFlipThreeChoice()

//     def description(self):
//         print("Flip Three Special Card!")


// class DoubleChanceCard(EventActionCard):
//     def __init__(self):
//         self.instantActivation = True

//     def execute(self, playerTurnManager):
//         currentPlayer = playerTurnManager.player
//         if (not currentPlayer.doubleChance):
//             currentPlayer.grantDoubleChance()
//             return
//         # Check to see if every player has a double chance card.
//         # If every player has a double chance card, discard this card
//         allDoubleChance = self.gameManager.checkAllDoubleChance()
//         if (not allDoubleChance):
//             print(
//                 "Every player has a double chance card. Hence this card will be discarded!")
//             return

//         # If not, choose a player to give a double chance card
//         playerTurnManager.getDoubleChoice()

//     def description(self):
//         print("Double Chance Card!")


// class CardDeck:
//     def __init__(self):
//         # Actual deck of cards. Data structure is a lit to preserve order of
//         # which cards are drawn, after shuffling
//         self.deckList = []
//         self.cardsLeft = {
//             0: 0,
//             1: 0,
//             2: 0,
//             3: 0,
//             4: 0,
//             5: 0,
//             6: 0,
//             7: 0,
//             8: 0,
//             9: 0,
//             10: 0,
//             11: 0,
//             12: 0,
//             'special': 0,
//         }
//         self.refill()

//     def refill(self):
//         # append 0 number card
//         self.deckList.append(NumberCard(0))
//         self.cardsLeft[0] += 1
//         # Append rest of cards.
//         # There should be n cards of value n.
//         for i in range(1, 13):
//             for j in range(i):
//                 self.deckList.append(NumberCard(i))
//                 self.cardsLeft[i] += 1
//         # Add the +2's, +4's, ... +10 cards
//         for i in range(2, 12, 2):
//             self.deckList.append(PlusCard(i))
//             self.cardsLeft['special'] += 1
//         # Official game only has a times 2 card, I just made that class for
//         # scalability
//         self.deckList.append(MultCard(2))
//         self.cardsLeft['special'] += 1
//         # Add three of each card: Freeze, flip three, double chance
//         for i in range(3):
//             self.deckList.append(FreezeCard())
//             self.deckList.append(FlipThreeCard())
//             self.deckList.append(DoubleChanceCard())
//             self.cardsLeft['special'] += 3
//         # shuffle deck
//         random.shuffle(self.deckList)

//     def draw(self):
//         if (self.deckList != []):
//             newCard = self.deckList.pop()
//             if (isinstance(newCard, NumberCard)):
//                 self.cardsLeft[newCard.value] -= 1
//             else:
//                 self.cardsLeft['special'] -= 1
//             newCard.description()
//             return newCard
//         else:
//             print("Deck ran out of cards. Refilling deck!")
//             self.refill()
//             newCard = self.deckList.pop()
//             newCard.description()
//             return newCard
