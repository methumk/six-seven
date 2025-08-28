import 'package:six_seven/components/card.dart';
import 'package:six_seven/components/player.dart';

class PlayerManager {
  CardDeck deck = CardDeck();
  List<Player> players = [];
  int aiPlayerCount;
  int totalPlayerCount;
  int currentPlayer = 0;

  PlayerManager({required this.totalPlayerCount, required this.aiPlayerCount}) {
    for (int i = 1; i <= totalPlayerCount; ++i) {
      if (i < aiPlayerCount) {
        // Fill human players first
        // players.add(HumanPlayer());
      } else {
        // Fill AI players last
        // players.add(AIPlayer());
      }
    }
  }

  void gameRotation() {}

  void showPlayerProbability() {}
}
