import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart';
import 'package:six_seven/components/card.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/components/ui/card_ui.dart';
import 'package:six_seven/components/ui/top_hud.dart';
import 'package:six_seven/pages/game/game_screen.dart';

class GameManager extends Component with HasGameReference<GameScreen> {
  // Game Logic
  CardDeck deck = CardDeck();
  List<Player> players = [];
  int aiPlayerCount;
  int totalPlayerCount;
  int currentPlayer = 0;
  double winningThreshold;

  // Game Logic
  bool tableSpinCCW = true;
  late final SplayTreeSet<Player> endGameLeaderBoard;
  late final SplayTreeSet<Player> currentLeaderBoard;

  // Game UI
  final List<NumberCardUI> testNumbers = [];
  late final TopHud hud;
  int currentCard = 0;

  GameManager({
    required this.totalPlayerCount,
    required this.aiPlayerCount,
    required this.winningThreshold,
  }) {
    endGameLeaderBoard = SplayTreeSet<Player>((a, b) {
      // order by score descending, break ties by id
      final cmp = b.totalValue.compareTo(a.totalValue);
      return cmp != 0 ? cmp : a.playerNum.compareTo(b.playerNum);
    });

    currentLeaderBoard = SplayTreeSet<Player>((a, b) {
      // order by score descending, break ties by id
      final cmp = b.currentValue.compareTo(a.currentValue);
      return cmp != 0 ? cmp : a.playerNum.compareTo(b.playerNum);
    });

    for (int i = 1; i <= totalPlayerCount; ++i) {
      if (i < aiPlayerCount) {
        // Fill human players first
        // players.add(HumanPlayer());
      } else {
        // Fill AI players last
        // players.add(AIPlayer());
      }

      // Add the users to the board
      // endGameLeaderBoard.add();
      // currentLeaderBoard.add();
    }
  }

  int getNextPlayer() {
    int nextPlayer = currentPlayer;
    if (tableSpinCCW) {
      nextPlayer = (nextPlayer + 1) % totalPlayerCount;
    } else {
      if (nextPlayer == 0) {
        nextPlayer = totalPlayerCount - 1;
      } else {
        nextPlayer--;
      }
    }

    return nextPlayer;
  }

  bool isGameOver() {
    bool gameOver = false;
    for (int i = 0; i < totalPlayerCount; ++i) {
      if (players[i].totalValue >= winningThreshold) {
        gameOver = true;
        break;
      }
    }

    return gameOver;
  }

  void calculateLeaderBoard() {}

  void gameRotation() {}

  void showPlayerProbability() {}

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // NOTE: these don't resize when game screen size changes
    final count = game.setupSettings.totalPlayerCount;
    for (int i = 0; i < count; ++i) {
      if (i == 0)
        testNumbers.add(NumberCardUI(pos: Vector2(200, 0)));
      else if (i == 1)
        testNumbers.add(NumberCardUI(pos: Vector2(0, 200)));
      else if (i == 2)
        testNumbers.add(NumberCardUI(pos: Vector2(-200, 0)));
      else if (i == 3)
        testNumbers.add(NumberCardUI(pos: Vector2(0, -200)));
    }

    final downButtonImg = await Flame.images.load("game_ui/button_down.png");
    final upButtonImg = await Flame.images.load("game_ui/button_up.png");

    game.world.addAll(testNumbers);

    final button = SpriteButtonComponent(
      button: Sprite(upButtonImg, srcSize: Vector2(60, 18)),
      buttonDown: Sprite(downButtonImg, srcSize: Vector2(60, 20)),
      position: Vector2(0, 900),
      size: Vector2(120, 36),
      onPressed: () {
        testNumbers[currentCard].onButtonTestUnClick();
        currentCard = ++currentCard % testNumbers.length;
        print("Button pressed! $currentCard");
        testNumbers[currentCard].onButtonTestClick();
      },
    );

    hud = TopHud(
      hudAnchor: Anchor.bottomCenter,
      hudMargin: EdgeInsets.only(bottom: 5, left: 7, top: 5, right: 7),
      hudItems: [
        button,
        TextComponent(text: 'Score: 0', position: Vector2(0, 0)),
      ],
    );

    // For HUD look at maybe adding it to camera.viewport instead of just add
    game.camera.viewport.add(hud);
  }
}
