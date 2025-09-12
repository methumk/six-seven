import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/deck.dart';
import 'package:six_seven/components/players/cpu_player.dart';
import 'package:six_seven/components/players/human_player.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/components/top_hud.dart';
import 'package:six_seven/data/enums/player_positions.dart';
import 'package:six_seven/data/enums/player_rotation.dart';
import 'package:six_seven/pages/game/game_screen.dart';
import 'package:six_seven/utils/leaderboard.dart';
import 'package:six_seven/utils/vector_helpers.dart';

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
  static final Vector2 thirdPersonScale = Vector2.all(.7);
  late final TopHud hud;
  int currentCard = 0;

  // Calculate the CENTER positions of where the players should go
  static final Vector2 topPlayerPosPercent = Vector2(.5, .25);
  static final Vector2 bottomPlayerPosPercent = Vector2(.5, .94);
  static final Vector2 leftPlayerPosPercent = Vector2(.06, .6);
  static final Vector2 rightPlayerPosPercent = Vector2(.94, .6);

  // Order of items is bottom: 0, left: 1, top: 2, right: 3 (clockwise)
  late final Vector2? topPlayerPos;
  late final Vector2? bottomPlayerPos;
  late final Vector2? leftPlayerPos;
  late final Vector2? rightPlayerPos;

  // In radians from left counter clock wise like unit circle (ellipses technically)
  static const double topPlayerAngle = math.pi * 0.5;
  static const double bottomPlayerAngle = math.pi * 1.5;
  static const double leftPlayerAngle = math.pi;
  static const double rightPlayerAngle = 0;

  // Animation rotation
  PlayerRotation rotationDirection = PlayerRotation.counterClockWise;
  bool animatePlayerRotation = false;
  // Radians/Second for one rotation; 90 degree turn in 1.3 seconds
  double speedPerRotation = (math.pi / 2) / 1.3;
  late final Vector2 rotationCenter; // center of rotation
  late final double rx; // horizontal radius
  late final double ty; // ellipse top radius from rotation center
  late final double by; // ellipse bottom radius from rotation center

  late final RectangleComponent rc;

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
      if (players[i]!.totalValue >= winningThreshold) {
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
    for (int i in deck.numberCardsLeft.keys) {
      print(
        "There are ${deck.numberCardsLeft[i]} number cards of value ${i} left.",
      );
    }
    for (int i in deck.plusMinusCardsLeft.keys) {
      print(
        "There are a total of ${deck.numberCardsLeft[i]} plus/minus value action cards of value ${i} left.",
      );
    }
    for (double j in deck.multCardsLeft.keys) {
      print(
        "There are a total of ${deck.multCardsLeft[j]} multiplication value action cards of value: X${j} left ",
      );
    }
    for (EventCardEnum eventCard in deck.eventCardsLeft.keys) {
      print(
        "There are ${deck.eventCardsLeft[eventCard]} event cards left of event action: ${eventCard.label} left",
      );
    }
    print("There are a total of ${numCardLeft} cards left in the deck");
  }

  //Calculate player's chance of busting, and expected value should they choose another hit
  void calculatePlayerProbabilityEV() {}

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Determine game resolution constants
    final double gameResX = game.gameResolution.x,
        gameResY = game.gameResolution.y;
    final Vector2 halfGameRes = game.gameResolution / 2;

    // Set 4 player position vectors
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

    // Set rotation values
    rotationCenter = Vector2(
      (leftPlayerPos!.x + rightPlayerPos!.x) / 2,
      leftPlayerPos!.y,
    );
    rx = (rightPlayerPos!.x - leftPlayerPos!.x) / 2;
    ty = topPlayerPos!.y - rotationCenter.y;
    by = rotationCenter.y - bottomPlayerPos!.y;

    print(
      "Center: ${rotationCenter} | Left: ${leftPlayerPos} Right: ${rightPlayerPos} rx: ${rx} | top: ${topPlayerPos} bottom: ${bottomPlayerPos}",
    );

    // Initializes player list and leaderboard
    _initPlayerList();
    game.world.addAll(players);

    // Set up Buttons
    final downButtonImg = await Flame.images.load("game_ui/button_down.png");
    final upButtonImg = await Flame.images.load("game_ui/button_up.png");
    final button = SpriteButtonComponent(
      button: Sprite(upButtonImg, srcSize: Vector2(60, 18)),
      buttonDown: Sprite(downButtonImg, srcSize: Vector2(60, 20)),
      position: Vector2(0, 900),
      size: Vector2(120, 36),
      onPressed: () {
        _startPlayerMove();
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

    // // For HUD look at maybe adding it to camera.viewport instead of just add
    game.camera.viewport.add(hud);

    // TESTING
    final tcc = CircleComponent(
      anchor: Anchor.center,
      position: topPlayerPos,
      paint: Paint()..color = Colors.red,
      radius: 5,
    );
    final bcc = CircleComponent(
      anchor: Anchor.center,
      position: bottomPlayerPos,
      paint: Paint()..color = Colors.red,
      radius: 5,
    );
    final lcc = CircleComponent(
      anchor: Anchor.center,
      position: leftPlayerPos,
      paint: Paint()..color = Colors.red,
      radius: 5,
    );
    final rcc = CircleComponent(
      anchor: Anchor.center,
      position: rightPlayerPos,
      paint: Paint()..color = Colors.red,
      radius: 5,
    );
    final ccc = CircleComponent(
      anchor: Anchor.center,
      position: rotationCenter,
      paint: Paint()..color = Colors.red,
      radius: 5,
    );
    rc = RectangleComponent(
      position: Vector2.all(0),
      size: Vector2(50, 80),
      paint: Paint()..color = Colors.white,
      anchor: Anchor.bottomCenter,
    );
    game.world.add(rc);
    game.world.addAll([tcc, bcc, lcc, rcc, ccc]);
  }

  // Maps the index to the given player position
  Vector2? _getPlayerPosbyIndex(int index) {
    if (index < 0 || index > 3) {
      return null;
    }

    if (index == 0) {
      return bottomPlayerPos;
    } else if (index == 1) {
      return leftPlayerPos;
    } else if (index == 2) {
      return topPlayerPos;
    } else if (index == 3) {
      return rightPlayerPos;
    }

    return null;
  }

  int? _getIndexbyPlayerPos(Vector2 v) {
    if (v == bottomPlayerPos) {
      return 0;
    } else if (v == leftPlayerPos) {
      return 1;
    } else if (v == topPlayerPos) {
      return 2;
    } else if (v == rightPlayerPos) {
      return 3;
    }
    return null;
  }

  double? _getAngleByVectorPos(Vector2 vectorPos) {
    if (vectorPos == topPlayerPos) {
      return topPlayerAngle;
    } else if (vectorPos == leftPlayerPos) {
      return leftPlayerAngle;
    } else if (vectorPos == bottomPlayerPos) {
      return bottomPlayerAngle;
    } else if (vectorPos == rightPlayerPos) {
      return rightPlayerAngle;
    }
    return null;
  }

  // Initialize players at position
  void _initPlayerList() {
    int humanCount = 0;

    for (int i = 0; i < totalPlayerCount; ++i) {
      // NOTE: change get set up position, to not use player count configuration
      int index = getSetUpPosition(totalPlayerCount, i);
      Vector2? pos = _getPlayerPosbyIndex(index);
      print("Setting Player $index");

      Player p;
      if (humanCount < (totalPlayerCount - game.setupSettings.aiPlayerCount)) {
        p = HumanPlayer(playerNum: i)..position = pos!;
        humanCount++;
      } else {
        p = CpuPlayer(playerNum: i, difficulty: Difficulty.easy)
          ..position = pos!;
      }

      p.currAngle = _getAngleByVectorPos(pos)!;
      players.add(p);
      endGameLeaderBoard.add(p);
      currentLeaderBoard.add(p);
    }
  }

  // The number of 90 degree rotations need to go from currPos to the next Pos based on rotation (taking 1 step rotation)
  int _getNextNumRotations(Vector2 currPos, PlayerRotation rotation) {
    switch (totalPlayerCount) {
      case 2:
        return 2;
      case 3:
        if (rotation == PlayerRotation.clockWise && currPos == leftPlayerPos) {
          return 2;
        } else if (rotation == PlayerRotation.counterClockWise &&
            currPos == rightPlayerPos) {
          return 2;
        }
        return 1;
      case 4:
        return 1;
    }
    return 0;
  }

  // Gets the next position from the current position based on the number on rotations to take and the rotation orientiation
  // Num rotations should be from _getNextNumRotations, the exact number of rotations to get from currPos to the next Position
  Vector2? _getNextRotationPos(
    Vector2 currPos,
    int numRotations,
    PlayerRotation rotation,
  ) {
    int currIndex = _getIndexbyPlayerPos(currPos)!;
    int nextIndex = 0;
    if (rotation == PlayerRotation.clockWise) {
      nextIndex = (currIndex + numRotations) % 4;
    } else {
      nextIndex = (currIndex - numRotations) % 4;
    }
    return _getPlayerPosbyIndex(nextIndex);
  }

  // Set up player rotation
  void _startPlayerMove() {
    if (animatePlayerRotation) {
      print("ANIMATION DISABLED UNTIL CURR FINISHED");
      return;
    }

    for (int i = 0; i < totalPlayerCount; ++i) {
      Player p = players[i];
      p.rotateNum = _getNextNumRotations(p.position, rotationDirection);
      p.isRotating = true;
      p.moveTo = _getNextRotationPos(
        p.position,
        p.rotateNum,
        rotationDirection,
      );
    }
    animatePlayerRotation = true;
  }

  // Handle player rotation on update
  void _rotatePlayersOnUpdate(double dt) {
    if (animatePlayerRotation) {
      if (topPlayerPos != null &&
          bottomPlayerPos != null &&
          rightPlayerPos != null &&
          leftPlayerPos != null) {
        // Use to determine if all rotations finished
        int playersFinished = 0;
        // Get current direction
        int direction = rotationDirection == PlayerRotation.clockWise ? -1 : 1;

        // Update position of players
        for (int i = 0; i < totalPlayerCount; ++i) {
          Player p = players[i];
          if (p.isRotating) {
            // If player has reached close enough to target position go to next player
            if (almostEqual(p.position, p.moveTo!, epsilon: 0.01)) {
              print("Player $i has finished rotating");
              p.position = p.moveTo!;
              p.isRotating = false;
              playersFinished++;
              continue;
            }

            // Determine speed angle to determine position
            double angle =
                p.currAngle + (direction * speedPerRotation * p.rotateNum * dt);
            if (angle > math.pi * 2) {
              angle -= math.pi * 2;
            }
            p.currAngle = angle;
            double sy = math.sin(angle);
            if (sy < 0) {
              sy *= by;
            } else {
              sy *= ty;
            }

            // Set current position
            p.position.setFrom(
              Vector2(
                rotationCenter.x + rx * math.cos(angle),
                rotationCenter.y + sy,
              ),
            );
          } else {
            playersFinished++;
          }
        }

        // Check if all rotations finished
        if (playersFinished == totalPlayerCount) {
          animatePlayerRotation = false;
        }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _rotatePlayersOnUpdate(dt);
  }
}
