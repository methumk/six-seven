import 'package:six_seven/components/card.dart';

abstract class Player {
  double totalValue = 0;
  double currentValue = 0;
  bool isDone = false;
  Set<NumberCard> numHand = Set();
  List<PlusCard> addHand = [];
  List<MultCard> multHand = [];
  //Minus hands are special in that positive duplicates can be canceled
  //by a minus card of same value.
  //To have fast checks, we instead need a hashmap
  Map<MinusCard, int> minusHand = {};
  bool doubleChance = false;
  late int playerNum;
  Player({required this.playerNum});

  //method for seeing own hand of cards
  void showHand() {
    print("You have: ");
    for (NumberCard numCard in numHand) {
      numCard.description();
    }
    for (PlusCard addCard in addHand) {
      addCard.description();
    }
    for (MultCard multCard in multHand) {
      multCard.description();
    }
    print("Player has a double chance card? ${doubleChance}");
    print("Tentative points from this round: $currentValue");
    print("Total points excluding this round: ${totalValue}");
  }

  //Method for when player busts
  void bust() {
    print("Bust!");
    isDone = true;
  }

  //Grant player a double chance status
  void grantDoubleChance() {
    doubleChance = true;
  }

  //Method for handling when player stays
  void handleStay() {
    currentValue = 0;
    for (NumberCard numCard in numHand) {
      currentValue += numCard.value;
    }
    //You must do mult cards before add card
    for (MultCard multCard in multHand) {
      currentValue = multCard.executeOnStay(currentValue);
    }
    for (PlusCard addCard in addHand) {
      currentValue = addCard.executeOnStay(currentValue);
    }
    //If player flipped 6 cards, get bonus 6.7 points (multiplier not included)
    if (numHand.length == 6) {
      currentValue += 6.7;
    }
    //Else if player  flipped >= 7 cards, get bonus 6*7 = 42 points (multiplier not included)
    if (numHand.length >= 7) {
      currentValue += 42;
    }

    totalValue += currentValue;
    isDone = true;
  }


  //Method for resetting certain attributes
  void reset(){
    numHand.clear();
    addHand.clear();
    multHand.clear();
    minusHand.clear();
    isDone = false;
    currentValue = 0;
    doubleChance = false;
  }

  //Method for hitting
  void onHit(Card newCard){
    if(newCard is NumberCard){
      currentValue += newCard.value;
      
    }
  }
}

//Human PLayer class
class Human extends Player{

  Human({required super.playerNum});

}


class Cpu extends Player{
  Cpu({required super.playerNum});
}