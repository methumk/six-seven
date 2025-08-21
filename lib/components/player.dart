import 'package:six_seven/components/card.dart';

abstract class Player{
  double totalValue = 0;
  double currentValue = 0;
  bool isDone = false;
  Set<dynamic> seen = Set();
  List<NumberCard> numHand = [];
  List<PlusCard> addHand = [];
  List<MultCard> multHand = [];
  List<MinusCard> minusHand = [];
  bool doubleChance = false;
  late int playerNum;
  Player({required this.playerNum});

  //method for seeing own hand of cards
  void showHand(){
    print("You have: ");
    for(NumberCard numCard in numHand){
      numCard.description();
    }
    for(PlusCard addCard in addHand){
      addCard.description();
    }
    for(MultCard multCard in multHand){
      multCard.description();
    }
    print("Player has a double chance card? ${doubleChance}");
    print("Tentative points from this round: $currentValue");
    print("Total points excluding this round: ${totalValue}");
  }
  
}

