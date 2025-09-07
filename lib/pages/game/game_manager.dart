import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/deck.dart';
import 'package:six_seven/components/players/cpu_player.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/components/top_hud.dart';
import 'package:six_seven/pages/game/game_screen.dart';
import 'package:six_seven/utils/leaderboard.dart';

class GameManager extends Component with HasGameReference<GameScreen> {
  // Game Logic
  CardDeck deck = CardDeck();
  List<Player> players = [];
  int aiPlayerCount;
  int totalPlayerCount;
  double winningThreshold;
  //Int for which player starts the next turn. Usually increments by 1 each round, but the reverse special effect causes it to
  // decrement by 1 each round
  late int turnStarterPlayerIndex;
  //Int for which player's turn it is. Usually increments by 1 after a turn, but reverse special effect causes it to
  // decrement by 1 each round
  late int currentPlayerIndex;
  //set of players that are done for the round
  Set<Player> donePlayers = Set();
  // Game Logic
  //When there's no reverse, players increment in CCW manner.
  //So if player 0 (call them main player) is in the bottom, then player 1 is right, player 2 is up, player 3 is left, etc
  bool tableSpinCCW = true;
  //Bool to check if game ends, if so break the game rotation loop
  bool gameEnd = false;

  late final Leaderboard<Player> endGameLeaderBoard;
  late final Leaderboard<Player> currentLeaderBoard;

  // Game UI
  final List<NumberCard> testNumbers = [];
  late final TopHud hud;
  int currentCard = 0;

  // Calculate the CENTER positions of where the players should go
  static final Vector2 topPlayerPosPercent = Vector2(.5, .25);
  static final Vector2 bottomPlayerPosPercent = Vector2(.5, .94);
  static final Vector2 leftPlayerPosPercent = Vector2(.06, .6);
  static final Vector2 rightPlayerPosPercent = Vector2(.94, .6);
  late final Vector2 topPlayerPos;
  late final Vector2 bottomPlayerPos;
  late final Vector2 leftPlayerPos;
  late final Vector2 rightPlayerPos;

  GameManager({
    required this.totalPlayerCount,
    required this.aiPlayerCount,
    required this.winningThreshold,
  }) {
    endGameLeaderBoard = Leaderboard<Player>(
      compare: (a, b) {
        // order by score descending, break ties by id
        final cmp = b.totalValue.compareTo(a.totalValue);
        return cmp != 0 ? cmp : a.playerNum.compareTo(b.playerNum);
      },
    );

    currentLeaderBoard = Leaderboard<Player>(
      compare: (a, b) {
        // order by score descending, break ties by id
        final cmp = b.currentValue.compareTo(a.currentValue);
        return cmp != 0 ? cmp : a.playerNum.compareTo(b.playerNum);
      },
    );

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

    //Start the turn starter and player turn index to be -1 because the first call of getNextPlayer increments them to player 0.
    turnStarterPlayerIndex = -1;
    currentPlayerIndex = -1;
  }

  int getNextPlayer(int player) {
    if (tableSpinCCW) {
      player = (player + 1) % totalPlayerCount;
    } else {
      if (player == 0) {
        player = totalPlayerCount - 1;
      } else {
        player--;
      }
    }
    return player;
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

  void gameRotation() {
    while (!gameEnd) {
      turnStarterPlayerIndex = getNextPlayer(turnStarterPlayerIndex);
      currentPlayerIndex = turnStarterPlayerIndex;
      donePlayers = Set();
      while (donePlayers.length < totalPlayerCount) {
        //TO DO: Handle this, will be different from python because has non-human players as well
        print("Player ${currentPlayerIndex}'s turn!");
        Player currentPlayer = players[currentPlayerIndex];
        if (currentPlayer.isDone) {
          print(
            "Player ${currentPlayerIndex} is already done! Going to next player!",
          );
        } else if (currentPlayer is CpuPlayer) {
          if (currentPlayer.difficulty == Difficulty.easy) {}
        } else {}

        currentPlayerIndex = getNextPlayer(currentPlayerIndex);
      }
    }
  }

  //Show deck distribution
  void showDeckDistribution() {
    int numCardLeft = deck.deckList.length;
    for (int i = 0; i <= 12; i++) {
      print(
        "There are ${deck.cardsLeft[i]} number cards of value ${i} left out of a total of ${numCardLeft} cards.",
      );
    }
    print(
      "There are a total of ${deck.cardsLeft[-1]} action cards left out of a total of ${numCardLeft} cards",
    );
  }

  //Calculate player's chance of busting, and expected value should they choose another hit
  void calculatePlayerProbabilityEV() {}

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Set 4 game player positions
    double gameResX = game.gameResolution.x, gameResY = game.gameResolution.y;
    Vector2 halfGameRes = game.gameResolution / 2;
    topPlayerPos =
        Vector2(
          topPlayerPosPercent.x * gameResX,
          topPlayerPosPercent.y * gameResY,
        ) -
        halfGameRes;
    bottomPlayerPos =
        Vector2(
          bottomPlayerPosPercent.x * gameResX,
          bottomPlayerPosPercent.y * gameResY,
        ) -
        halfGameRes;
    leftPlayerPos =
        Vector2(
          leftPlayerPosPercent.x * gameResX,
          leftPlayerPosPercent.y * gameResY,
        ) -
        halfGameRes;
    rightPlayerPos =
        Vector2(
          rightPlayerPosPercent.x * gameResX,
          rightPlayerPosPercent.y * gameResY,
        ) -
        halfGameRes;

    // NOTE: these don't resize when game screen size changes
    final count = game.setupSettings.totalPlayerCount;
    for (int i = 0; i < count; ++i) {
      if (i == 0) {
        testNumbers.add(NumberCard(value: 5)..position = bottomPlayerPos);
      } else if (i == 1) {
        testNumbers.add(NumberCard(value: 10.2)..position = leftPlayerPos);
      } else if (i == 2) {
        testNumbers.add(NumberCard(value: 0)..position = topPlayerPos);
      } else if (i == 3) {
        testNumbers.add(NumberCard(value: 12)..position = rightPlayerPos);
      }
    }

    final downButtonImg = await Flame.images.load("game_ui/button_down.png");
    final upButtonImg = await Flame.images.load("game_ui/button_up.png");

    game.world.addAll(testNumbers);
    // game.world.add(deck);

    final button = SpriteButtonComponent(
      button: Sprite(upButtonImg, srcSize: Vector2(60, 18)),
      buttonDown: Sprite(downButtonImg, srcSize: Vector2(60, 20)),
      position: Vector2(0, 900),
      size: Vector2(120, 36),
      onPressed: () {
        // testNumbers[currentCard].onButtonTestUnClick();
        // currentCard = ++currentCard % testNumbers.length;
        // print("Button pressed! $currentCard");
        // testNumbers[currentCard].onButtonTestClick();
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
