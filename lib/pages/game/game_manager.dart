import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/cards/card.dart' as cd;
import 'package:six_seven/components/cards/card.dart';
import 'package:six_seven/components/cards/deck.dart';
import 'package:six_seven/components/cards/event_cards/choice_draw.dart';
import 'package:six_seven/components/cards/event_cards/cribber_card.dart';
import 'package:six_seven/components/cards/event_cards/double_chance_card.dart';
import 'package:six_seven/components/cards/event_cards/flip_three_card.dart';
import 'package:six_seven/components/cards/event_cards/forecaster_card.dart';
import 'package:six_seven/components/cards/event_cards/freeze_card.dart';
import 'package:six_seven/components/cards/event_cards/income_tax_card.dart';
import 'package:six_seven/components/cards/event_cards/lucky_die_card.dart';
import 'package:six_seven/components/cards/event_cards/top_peek_card.dart';
import 'package:six_seven/components/cards/event_cards/polarizer_card.dart';
import 'package:six_seven/components/cards/event_cards/redeemer_card.dart';
import 'package:six_seven/components/cards/event_cards/reverse_turn_card.dart';
import 'package:six_seven/components/cards/event_cards/sales_tax_card.dart';
import 'package:six_seven/components/cards/event_cards/sunk_prophet_card.dart';
import 'package:six_seven/components/cards/event_cards/thief_card.dart';
import 'package:six_seven/components/hud.dart';
import 'package:six_seven/components/players/cpu_player.dart';
import 'package:six_seven/components/players/human_player.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/data/constants/game_setup_settings_constants.dart';
import 'package:six_seven/data/enums/player_slots.dart';
import 'package:six_seven/data/enums/player_rotation.dart';
import 'package:six_seven/pages/game/game_screen.dart';
import 'package:six_seven/utils/leaderboard.dart';
import 'package:six_seven/utils/vector_helpers.dart';

class GameManager extends Component with HasGameReference<GameScreen> {
  // Game Logic
  CardDeck deck = CardDeck();
  // Index doesn't match position, but 0-Total count goes in clock wise direction, 0 at center initially then everything goes clock wise as index increases
  List<Player> players = [];
  int aiPlayerCount;
  int totalPlayerCount;
  double winningThreshold;
  //Int for which player starts the next turn. Usually increments by 1 each round, but the reverse special effect causes it to
  // decrement by 1 each round
  late int turnStarterPlayerIndex;
  // The current index in players Array that is at bottom (their turn to play)
  int currentPlayerIndex = 0;
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
  late final Hud hud;
  // late final TopHud hud;
  // late final BottomHud bHud;
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
  // We don't push AI's to bottom screen, so this keeps track of offset to rotate user to the bottom after AI players
  int rotationPlayerOffset = 0;
  // Radians/Second for one rotation; 90 degree turn in 1.3 seconds
  double speedPerRotation = (math.pi / 2) / 1.3;
  late final Vector2 rotationCenter; // center of rotation
  late final double rx; // horizontal radius
  late final double ty; // ellipse top radius from rotation center
  late final double by; // ellipse bottom radius from rotation center

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

  void roundStart() {
    turnStarterPlayerIndex = getNextPlayer(turnStarterPlayerIndex);
    currentPlayerIndex = turnStarterPlayerIndex;
    for (int i = 0; i < totalPlayerCount; i++) {
      //At round start, players are forced to hit, so _onHitPressed() might be automatically called
      // _onHitPressed();
      Player currentPlayer = players[currentPlayerIndex];
      cd.Card hitCard = deck.draw();
      currentPlayerIndex = getNextPlayer(currentPlayerIndex);
      currentPlayer.onHit(hitCard);
    }
    return;
  }

  void gameRotation() {
    while (!gameEnd) {
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

  //Calculate player's chance of busting
  double calculateFailureProbability(int playerNum) {
    Player currentPlayer = players[playerNum];
    int outcomeCardinality =
        0; //the total number of cards in deck that can bust you

    for (double number in currentPlayer.numHand) {
      int currentNumberCardinality = deck.numberCardsLeft[number]!;

      print(
        "You have a number card of: ${number.toInt()}, and there are ${currentNumberCardinality} cards of the same value.",
      );
      outcomeCardinality = outcomeCardinality + currentNumberCardinality;
    }

    int numCardsLeft = deck.deckList.length;
    print("Total number of cards left in the deck: ${numCardsLeft}");
    double failureProb = outcomeCardinality / numCardsLeft;
    print("Your probability of failing is: ${failureProb}");
    return failureProb;
  }

  //Expected value of multiplier for mult cards
  double calculateEVMultCards() {
    //Current amount of cards left in deck
    int numCardsLeft = deck.deckList.length;
    //Total amount of mult cards left in deck
    int totalMultCards = 0;
    //Expected value of multiplation cards effects in next hit
    double evMultCard = 0;
    for (double multiplier in deck.multCardsLeft.keys) {
      int amountOfMultiplierInDeck = deck.multCardsLeft[multiplier]!;
      evMultCard += multiplier * (amountOfMultiplierInDeck / numCardsLeft);
      totalMultCards += amountOfMultiplierInDeck;
    }

    //Include event that the card drawn was not a mult value card
    evMultCard += 1 * (numCardsLeft - totalMultCards) / numCardsLeft;
    return evMultCard;
  }

  //Expected value of number card
  double calculateEVNumberCards(Player currentPlayer) {
    //Current amount of cards left in deck
    int numCardsLeft = deck.deckList.length;

    ///Total amount of number cards left in deck
    ///(not needed for number cards)
    // int totalNumberCards = 0;

    ///Expected Value of number cards on next hit
    double evNumberCard = 0;

    for (int number in deck.numberCardsLeft.keys) {
      int amountOfSpecificNumberCardInDeck = deck.numberCardsLeft[number]!;
      //If number card is a number that the player already has, skip it
      if (currentPlayer.numHand.contains(number)) {
        continue;
      }
      evNumberCard +=
          number * (amountOfSpecificNumberCardInDeck / numCardsLeft);
      // totalNumberCards += amountOfSpecificNumberCardInDeck;
    }
    //The event that the card drawn was not a number card has a numeric value
    //of "0" so is commented here for semantic reasons
    //evNumberCard += 0 * (numCardsLeft - totalNumberCards) / numCardsLeft;
    return evNumberCard;
  }

  //Expected Value for value action cards
  double calculateEVPlusMinusValueCards() {
    //Current amount of cards left in deck
    int numCardsLeft = deck.deckList.length;

    ///Total amount of number cards left in deck
    ///(not needed for number cards)
    // int totalValueCards = 0;
    double evPlusMinusValueCard = 0;

    for (int plusMinusValue in deck.plusMinusCardsLeft.keys) {
      int amountofPlusMinusValueInDeck = deck.numberCardsLeft[plusMinusValue]!;
      evPlusMinusValueCard +=
          plusMinusValue * (amountofPlusMinusValueInDeck / numCardsLeft);
      // totalNumberCards += amountOfSpecificNumberCardInDeck;
    }

    //The event that the card drawn was not a number card has a numeric value
    //of "0" so is commented here for semantic reasons
    //evNumberCard += 0 * (numCardsLeft - totalNumberCards) / numCardsLeft;
    return evPlusMinusValueCard;
  }

  double calculateEVEventCards() {
    //Current amount of cards left in deck
    int numCardsLeft = deck.deckList.length;

    double evEventCard = 0;

    //TO DO: implement for each case
    return evEventCard;
  }

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

    // Set up Hud
    hud = Hud(
      hitPressed: _onHitPressed,
      stayPressed: _onStayPressed,
      backPressed: game.showExitDialog,
      enableProbability: game.setupSettings.showDeckDistribution,
    );
    game.camera.viewport.add(hud);

    // final MinusCard mc1 = MinusCard(value: 8);
    // final MinusCard mc2 = MinusCard(value: 1.25);
    // final MinusCard mc3 = MinusCard(value: 12);
    // final MinusCard mc4 = MinusCard(value: 1.3);
    // final PlusCard pc1 = PlusCard(value: 8);
    // final PlusCard pc2 = PlusCard(value: 1.25);
    // final PlusCard pc3 = PlusCard(value: 12);
    // final PlusCard pc4 = PlusCard(value: 1.3);
    // final MultCard m1 = MultCard(value: 8);
    // final MultCard m2 = MultCard(value: 1.25);
    // final MultCard m3 = MultCard(value: 12);
    // final MultCard m4 = MultCard(value: 1.3);
    // final MultCard mtc = MultCard(value: 1.15);
    // final PlusCard pc = PlusCard(value: 11);

    final ChoiceDraw cd = ChoiceDraw();
    final CribberCard cc = CribberCard();
    final DoubleChanceCard dcd = DoubleChanceCard();
    final FlipThreeCard ftc = FlipThreeCard();
    final ForecasterCard fc = ForecasterCard();
    final FreezeCard fzc = FreezeCard();
    final IncomeTax it = IncomeTax();
    final LuckySixSidedDieCard ld = LuckySixSidedDieCard();
    final TopPeekCard mgc = TopPeekCard();
    final PolarizerCard p = PolarizerCard();
    final RedeemerCard r = RedeemerCard();
    final ReverseTurnCard rt = ReverseTurnCard();
    final SalesTax st = SalesTax();
    final SunkProphet sp = SunkProphet();
    final ThiefCard tc = ThiefCard();
    game.world.addAll([
      cd,
      cc,
      dcd,
      ftc,
      fc,
      fzc,
      it,
      ld,
      mgc,
      p,
      r,
      rt,
      st,
      sp,
      tc,
      // mc1,
      // mc2,
      // mc3,
      // mc4,
      // pc1,
      // pc2,
      // pc3,
      // pc4,
      // m1,
      // m2,
      // m3,
      // m4,
      // mtc,
      // pc,
    ]);

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
    game.world.addAll([tcc, bcc, lcc, rcc, ccc]);
    print(
      "GAME RUNNING clockWise? : ${rotationDirection == PlayerRotation.clockWise}",
    );
  }

  // Set up on stay pressed handler
  Future<void> _onStayPressed() async {
    print("Stay Pressed");
  }

  // Set up on hit pressed handler
  // Handles rotation, and other functionality
  Future<void> _onHitPressed() async {
    if (animatePlayerRotation) {
      print("ANIMATION DISABLED UNTIL CURR FINISHED");
      return;
    }

    // Rotate the players and disable hit/stay when running
    _rotatePlayers();
  }

  void _rotatePlayers() {
    // Determine next bottom index from the players array
    int nextPlayerBottomIndex = _getNextBottomPlayerIndex(
      currentPlayerIndex,
      totalPlayerCount,
      rotation: rotationDirection,
    );

    // Do not rotate if next player is CPU
    if (players[nextPlayerBottomIndex] is CpuPlayer) {
      print(
        "Next player $nextPlayerBottomIndex from player $currentPlayerIndex is CPU",
      );
      rotationPlayerOffset++;
      currentPlayerIndex = nextPlayerBottomIndex;
    } else {
      currentPlayerIndex = nextPlayerBottomIndex;
      print("UPDATING with extra rotation value $rotationPlayerOffset");

      for (int i = 0; i < totalPlayerCount; ++i) {
        Player p = players[i];
        p.rotateNum = _getNextNumRotations(
          p.position,
          rotationDirection,
          extraRotation: rotationPlayerOffset,
        );
        p.moveTo = _getNextRotationPos(
          p.position,
          p.rotateNum,
          rotationDirection,
        );
        print(
          "p $i From ${p.position} to ${p.moveTo} takes ${p.rotateNum} steps",
        );
        p.isRotating = true;
      }

      // If human player we don't have offset so reset
      rotationPlayerOffset = 0;
      // Set stay and hit to disabled while it's rotating, once finished rotating hit and stay will be reenabled
      animatePlayerRotation = true;
      hud.disableHitAndStayBtns();
    }
  }

  // NOTE: This should only be used for initializing players array
  // playerIndex represents where the player is in the player array
  // Returns based on playercount and where the index is, gives the index that maps to bottom:0, left: 1, top: 2, right: 3
  PlayerSlot _getSetUpPosIndex(int playerIndex) {
    PlayerCountSlotConfig pcc = PlayerCountSlotConfig.fromPlayerCount(
      totalPlayerCount,
    );

    return pcc.label[playerIndex % totalPlayerCount];
  }

  // Maps the index to the given player position
  Vector2 _getPlayerPosbyPosIndex(PlayerSlot pos) {
    switch (pos) {
      case PlayerSlot.bottom:
        return bottomPlayerPos!;
      case PlayerSlot.left:
        return leftPlayerPos!;
      case PlayerSlot.top:
        return topPlayerPos!;
      case PlayerSlot.right:
        return rightPlayerPos!;
    }
  }

  // Maps vector position to player position
  PlayerSlot? _getPosIndexbyPosVector(Vector2 v) {
    if (v == bottomPlayerPos) {
      return PlayerSlot.bottom;
    } else if (v == leftPlayerPos) {
      return PlayerSlot.left;
    } else if (v == topPlayerPos) {
      return PlayerSlot.top;
    } else if (v == rightPlayerPos) {
      return PlayerSlot.right;
    }
    return null;
  }

  // Returns the next player pos index from the current player pos index
  // currPosIndex is the current players position index
  // ExtraRotationStep is how many extra steps we want to take
  // e.g. clock-wise with 3 players; pos 1 to next position 3 takes 2 rotations, but if you add one extra step it goes from pos 1 to 4 so 3 rotations
  int _getNextPosIndex(
    PlayerSlot currSlot, {
    PlayerRotation rotDirection = PlayerRotation.clockWise,
    int extraRotationStep = 0,
  }) {
    PlayerCountSlotConfig pcc = PlayerCountSlotConfig.fromPlayerCount(
      totalPlayerCount,
    );
    int rotSteps = 1 + extraRotationStep;
    int currArrayIndex = 0;
    for (int i = 0; i < pcc.label.length; ++i) {
      if (pcc.label[i] == currSlot) {
        currArrayIndex = i;
        break;
      }
    }
    int toIndexRot =
        rotDirection == PlayerRotation.clockWise
            ? currArrayIndex + rotSteps
            : currArrayIndex - rotSteps;
    int toIndex = pcc.label[toIndexRot % totalPlayerCount].index;
    print(
      "From index: ${currArrayIndex} to index value: ${toIndex} from indexRot of ${toIndexRot}",
    );
    return toIndex;
  }

  // Returns the index in the player array, of the next player to become the bottom player (active player)
  int _getNextBottomPlayerIndex(
    int currPlayerIndex,
    int playerCount, {
    PlayerRotation rotation = PlayerRotation.clockWise,
  }) {
    int nextBottomPlayerIndex = 0;
    if (rotation == PlayerRotation.clockWise) {
      nextBottomPlayerIndex = (currPlayerIndex - 1) % playerCount;
    } else {
      nextBottomPlayerIndex = (currPlayerIndex + 1) % playerCount;
    }
    return nextBottomPlayerIndex;
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
    int totalHumans = totalPlayerCount - game.setupSettings.aiPlayerCount;
    for (int i = 0; i < totalPlayerCount; ++i) {
      // NOTE: change get set up position, to not use player count configuration
      PlayerSlot currSlot = _getSetUpPosIndex(i);
      Vector2 pos = _getPlayerPosbyPosIndex(currSlot);
      print("Setting Player $currSlot");

      Player p;
      if (humanCount < totalHumans) {
        p = HumanPlayer(playerNum: i)..position = pos!;
        humanCount++;
      } else {
        p = CpuPlayer(playerNum: i, difficulty: Difficulty.easy)
          ..position = pos;
      }

      p.currAngle = _getAngleByVectorPos(pos)!;
      players.add(p);
      endGameLeaderBoard.add(p);
      currentLeaderBoard.add(p);
    }
  }

  // The number of 90 degree rotations need to go from currPos to the next Pos based on rotation (taking 1 step rotation)
  // Extra rotation is how many more steps we have to do (essentially, more than 1 step rotation) to get to next pos
  int _getNextNumRotations(
    Vector2 currPos,
    PlayerRotation rotation, {
    int extraRotation = 0,
  }) {
    int normalizedExtraRotation = extraRotation % totalPlayerCount;
    PlayerSlot fromSlot = _getPosIndexbyPosVector(currPos)!;
    int rotationDirection = rotation == PlayerRotation.clockWise ? 1 : -1;
    int toPosIndex = _getNextPosIndex(
      fromSlot,
      rotDirection: rotation,
      extraRotationStep: normalizedExtraRotation,
    );
    print(
      "Rotating player clockwise? ${rotationDirection == 1} from ${fromSlot.index} to $toPosIndex",
    );
    return ((toPosIndex - fromSlot.index) * rotationDirection) %
        GameSetupSettingsConstants.totalPlayerCountMax;
  }

  // Gets the next position from the current position based on the number on rotations to take and the rotation orientiation
  // Num rotations should be from _getNextNumRotations, the exact number of rotations to get from currPos to the next Position
  Vector2? _getNextRotationPos(
    Vector2 currPos,
    int numRotations,
    PlayerRotation rotation,
  ) {
    PlayerSlot fromSlot = _getPosIndexbyPosVector(currPos)!;
    int nextIndex = 0;
    if (rotation == PlayerRotation.clockWise) {
      nextIndex = (fromSlot.index + numRotations) % 4;
    } else {
      nextIndex = (fromSlot.index - numRotations) % 4;
    }
    PlayerSlot nextSlot = PlayerSlot.fromPlayerIndex(nextIndex);
    return _getPlayerPosbyPosIndex(nextSlot);
  }

  void _onRotationFinished() {
    animatePlayerRotation = false;
    hud.enableHitAndStayBtns();
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
          _onRotationFinished();
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
