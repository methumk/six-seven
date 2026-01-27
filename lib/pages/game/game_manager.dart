import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/cards/card.dart' as cd;
import 'package:six_seven/components/cards/deck.dart';
import 'package:six_seven/components/cards/event_cards/choice_draw.dart';
import 'package:six_seven/components/cards/event_cards/discarder_card.dart';
import 'package:six_seven/components/cards/event_cards/double_chance_card.dart';
import 'package:six_seven/components/cards/event_cards/flip_three_card.dart';
import 'package:six_seven/components/cards/event_cards/forecaster_card.dart';
import 'package:six_seven/components/cards/event_cards/freeze_card.dart';
import 'package:six_seven/components/cards/event_cards/income_tax_card.dart';
import 'package:six_seven/components/cards/event_cards/lucky_die_card.dart';
import 'package:six_seven/components/cards/event_cards/redeemer_card.dart';
import 'package:six_seven/components/cards/event_cards/reverse_turn_card.dart';
import 'package:six_seven/components/cards/event_cards/sunk_prophet_card.dart';
import 'package:six_seven/components/cards/event_cards/income_tax_card.dart';
import 'package:six_seven/components/cards/event_cards/thief_card.dart';
import 'package:six_seven/components/cards/event_cards/top_peek_card.dart';
import 'package:six_seven/components/cards/value_action_cards/minus_card.dart';
import 'package:six_seven/components/cards/value_action_cards/mult_card.dart';
import 'package:six_seven/components/cards/value_action_cards/plus_card.dart';
import 'package:six_seven/components/hud.dart';
import 'package:six_seven/components/players/cpu_player.dart';
import 'package:six_seven/components/players/human_player.dart';
import 'package:six_seven/components/players/overlays.dart/text_animations.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/components/pot/pot.dart';
import 'package:six_seven/components/spinning_arrow_ring.dart';
import 'package:six_seven/data/constants/game_setup_settings_constants.dart';
import 'package:six_seven/data/enums/event_cards.dart';
import 'package:six_seven/data/enums/player_slots.dart';
import 'package:six_seven/data/enums/player_rotation.dart';
import 'package:six_seven/pages/game/game_screen.dart';
import 'package:six_seven/utils/leaderboard.dart';
import 'package:six_seven/utils/player_stack.dart';

// class PathDebugComponent extends PositionComponent {
//   final Path path;
//   final Paint paintStyle;

//   PathDebugComponent({
//     required this.path,
//     Color color = Colors.blue,
//     double strokeWidth = 5.0,
//   }) : paintStyle =
//            Paint()
//              ..color = color
//              ..style = PaintingStyle.stroke
//              ..strokeWidth = strokeWidth;

//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     canvas.drawPath(path, paintStyle);
//   }
// }

// When we want a different action that just rotating after dealing with an event card
enum EventDifferentAction { none, topPeek, forecast }

class GameManager extends Component with HasGameReference<GameScreen> {
  // Game Logic
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
  //Bool to check if game ends, if so break the game rotation loop
  bool gameEnd = false;

  //Const for double chance Raw value used for EV
  final double doubleChanceGoodRawValue = 15;
  //Bad EV for these cases is when other players are active, because then you are forced to
  //give this card to someone else
  final double doubleChanceBadRawValue = -8;
  //Const for redeemer EV value
  final double redeemerGoodRawValue = 7;
  //Bad EV for these cases is when other players are active, because then you are forced to
  //give this card to someone else
  final double redeemerBadRawValue = -4;

  bool buttonPressed = false;
  late final Leaderboard<Player> totalLeaderBoard;
  late final Leaderboard<Player> currentLeaderBoard;
  late final Leaderboard<Player> totalCurrentLeaderBoard;
  // Game UI
  static final Vector2 thirdPersonScale = Vector2.all(.7);
  static final Vector2 gameCenter = Vector2.all(0);
  late final Hud hud;
  // late final TopHud hud;
  // late final BottomHud bHud;
  int currentCard = 0;

  //Used for challenge difficulty ai players;
  final random = Random();
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
  // Next player rotation indication
  late final SpinningArrowRing rotationIndicator;

  bool animatePlayerRotation = false;
  // We don't push AI's to bottom screen, so this keeps track of offset to rotate user to the bottom after AI players
  int rotationPlayerOffset = 0;
  // Radians/Second for one rotation; 90 degree turn in 1.3 seconds
  double speedPerRotation = (math.pi / 2) / 1.3;
  late final Vector2 rotationCenter; // center of rotation
  late final double rx; // horizontal radius
  late final double ty; // ellipse top radius from rotation center
  late final double by; // ellipse bottom radius from rotation center

  // Forced To Play Stack
  final PlayerStack forcedToPlay = PlayerStack();
  int? returnToPlayerIndex;

  // Event action handlers
  cd.EventActionCard? runningEvent;

  // Pot
  late final Pot pot;
  // anchored at center bottom with reference to the game.world
  static final Vector2 worldPotPos = gameCenter;

  // Deck
  late final CardDeck deck;
  // anchor at center bottom with refernece to the game.world
  static final Vector2 worldDeckPos = gameCenter;

  // current Round, ones based
  int currentRound = 1;
  double roundFontSize = 60;
  Color roundTextColor = Colors.green;
  List<Shadow> roundTextShadowColor = [
    const Shadow(offset: Offset(-2, 2), blurRadius: 3, color: Colors.white),
  ];

  // TextAnimations
  late TextAnimations roundOverTextAnimation;

  Player? get getCurrentPlayer =>
      players.isNotEmpty &&
              players.length > currentPlayerIndex &&
              players[currentPlayerIndex] != null
          ? players[currentPlayerIndex]
          : null;

  GameManager({
    required this.totalPlayerCount,
    required this.aiPlayerCount,
    required this.winningThreshold,
  }) {
    totalLeaderBoard = Leaderboard<Player>(
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

    totalCurrentLeaderBoard = Leaderboard<Player>(
      compare: (a, b) {
        final cmp = (b.totalValue + b.currentValue).compareTo(
          a.currentValue + a.totalValue,
        );
        return cmp != 0 ? cmp : a.playerNum.compareTo(b.playerNum);
      },
    );
    turnStarterPlayerIndex = 0;

    print("winning threshold: ${winningThreshold}");
  }

  void flipRotationDirection() {
    if (rotationDirection == PlayerRotation.clockWise) {
      rotationDirection = PlayerRotation.counterClockWise;
    } else {
      rotationDirection = PlayerRotation.clockWise;
    }
    print("\nChanged rotation direction to $rotationDirection \n");
  }

  int getNextPlayer(int player) {
    if (rotationDirection == PlayerRotation.counterClockWise) {
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

  Future<void> handleNewRound() async {
    // Show round over animation
    await roundOverTextAnimation.setScalingAnimation(
      "Round $currentRound Over",
      TextPaint(
        style: TextStyle(
          color: roundTextColor,
          shadows: roundTextShadowColor,
          fontWeight: FontWeight.w900,
          fontSize: roundFontSize,
        ),
      ),
      textAppearForSec: 2,
      holdTextForMs: 1700,
      shrinkAndRemoveAtEndSec: .7,
    );

    // Ensure pot has finished
    await Future.delayed(Duration(microseconds: 1000));

    Player lp = players[currentPlayerIndex];
    Map<Player, double> potDistrib = {};

    // Calculate pot distribution before resetting and showing leaderboard
    if (lp.status == PlayerStatus.bust) {
      double distributedPot = pot.totalScore / (totalPlayerCount - 1);
      for (int i = 0; i < totalPlayerCount; ++i) {
        if (i != currentPlayerIndex) {
          potDistrib[players[i]] = distributedPot;
        }
      }
    } else {
      potDistrib[lp] = pot.totalScore;
    }

    // update current and end game leaderboards
    currentLeaderBoard.updateEntireLeaderboard();
    totalLeaderBoard.updateEntireLeaderboard();
    for (Player currentPlayer in players) {
      print("winning threshold: ${winningThreshold}");
      print("currentPlayer.totalValue: ${currentPlayer.totalValue}");
      if (currentPlayer.totalValue >= winningThreshold) {
        await handleEndGame();
      }
    }
    // clear variable fields
    pot.reset();
    donePlayers.clear();
    rotationPlayerOffset = 0;
    turnStarterPlayerIndex = (turnStarterPlayerIndex + 1) % totalPlayerCount;
    currentPlayerIndex = turnStarterPlayerIndex;

    // await game.showRoundPointsDialog(players);
    await game.showLeaderboard(
      totalPlayerCount,
      totalLeaderBoard.topN(totalPlayerCount),
      currentLeaderBoard.topN(totalPlayerCount),
      potDistrib,
    );

    for (int i = 0; i < totalPlayerCount; i++) {
      // The leaderboard widget already accounts the total value with pot, so update current value to 0
      // reset round will then do currentValue + totalValue, which will be double counting if we don't set current value to 0
      players[i].currentValue = 0;

      await players[i].resetRound();

      //since you increment player, you want the next player to be one BEFORE their previos start. Subtract by turnstarter
      PlayerSlot currSlot = _getSetUpPosIndex(
        (i - turnStarterPlayerIndex) % totalPlayerCount,
      );
      Vector2 pos = _getVectorPosByPlayerSlot(currSlot);
      players[i].position = pos;
      players[i].currSlot = currSlot;
      players[i].moveToSlot = currSlot;
    }

    // Update the current position after current value reset
    currentLeaderBoard.updateEntireLeaderboard();
    totalLeaderBoard.updateEntireLeaderboard();
    totalCurrentLeaderBoard.updateEntireLeaderboard();
    // Update round counter
    currentRound++;

    animatePlayerRotation = false;
    buttonPressed = false;
    if (players[currentPlayerIndex].isCpu()) {
      hud.disableHitAndStayBtns();
      print("Current player${currentPlayerIndex + 1} is CPU");
      await aiTurn(players[currentPlayerIndex] as CpuPlayer);
      // print("next bottom index: ${nextPlayerBottomIndex}");
    } else {
      hud.enableHitAndStayBtns();
    }
  }

  Future<void> aiTurn(CpuPlayer currentCPUPlayer) async {
    // print("Setting difficulty: ${game.setupSettings.aiDifficulty}");
    // print("Difficulty of current AI: ${currentCPUPlayer.difficulty}");
    await Future.delayed(const Duration(milliseconds: 500));

    //If cpu has enough points to win, they will stay to win
    print("Current player's total value: ${currentCPUPlayer.totalValue}");
    print("Current Player's current value: ${currentCPUPlayer.currentValue}");
    print(
      "currentPlayer.totalValue + currentPLayer.currentValue: ${currentCPUPlayer.totalValue + currentCPUPlayer.currentValue}",
    );
    if (currentCPUPlayer.totalValue + currentCPUPlayer.currentValue >=
        winningThreshold) {
      await handleEndGame();
    }

    if (currentCPUPlayer.difficulty == Difficulty.easy) {
      //Easy difficulty: has a risk tolerance of 45%, so
      //if probability of failing is less than 45%, hit
      await riskTolerance(currentCPUPlayer, .45);
    } else if (currentCPUPlayer.difficulty == Difficulty.medium) {
      //Medium difficulty: has a risk tolerance of 30%, so
      //if probability of failing is less than 30%, hit
      await riskTolerance(currentCPUPlayer, .3);
    } else if (currentCPUPlayer.difficulty == Difficulty.hard) {
      //Hard difficulty: Starts comparing by EV instead of probability risk
      //if E[hit] >= n, hit , else stay
      await EVBasedComparison(currentCPUPlayer);
    }
    //Else, is expert difficulty
    else {
      // print("Watch out we got Phil Hellmuth over here");
      //Random number from 1 to 7. If 6 or 7, AI gets
      //to peak at the next card in the deck
      int rng = random.nextInt(7) + 1;
      if (rng == 6 || rng == 7) {
        print("Expert AI gets a peek!");
        await expertPeek(currentCPUPlayer);
      } else {
        await EVBasedComparison(currentCPUPlayer);
      }
    }
    //If deck is empty, refill it
    if (deck.deckList.isEmpty) {
      deck.refill();
    }
  }
  //Method for expert CPU peeking

  Future<void> expertPeek(CpuPlayer currentCPUPlayer) async {
    print("CPU is peeking now!");
    cd.Card peekCard = deck.peek();
    if (peekCard is cd.NumberCard) {
      print("Peeked card was a number card!");
      //if peeked number card is a duplicate and will bust, stay,
      //else hit
      // await Future.delayed(const Duration(milliseconds: 1500));

      if (currentCPUPlayer.isPeekedNumberCardDuplicate(peekCard) &&
          !currentCPUPlayer.doubleChance) {
        print("Peeked card was a duplicate number card. Stay!");
        await _aiStays();
      } else {
        print("Peeked card was not a duplicate number card. Hit!");
        await _aiHits();
      }
    }
    //Plus cards are always good, hit them.
    else if (peekCard is PlusCard) {
      print("Peeked card was a plus card. Hit!");
      await _aiHits();
    } else if (peekCard is MinusCard) {
      //For minus card, AI Player will choose to hit anyways if E[Hit] >= n
      //because they can still continue getting points with more hits.
      //Else, they stay because E[Hit] < n, and hence it is not worth the risk
      //to hit more.
      print(
        "Peeked card was a number card. Comparing Expected Value to decide",
      );
      await EVBasedComparison(currentCPUPlayer);
    } else if (peekCard is MultCard) {
      // await Future.delayed(const Duration(milliseconds: 1500));
      if (currentCPUPlayer.isPeekedMultCardBad(peekCard)) {
        print("Peeked card was a  Multiplier card with value <1. Stay!");
        await _aiStays();
      } else {
        print("Peeked card was a multiplier card with value >=1. Hit!");
        await _aiHits();
      }
    } else {
      // await Future.delayed(const Duration(milliseconds: 1500));
      //TO DO: Handle event action cards case
      await _aiHits();
    }
    return;
  }

  //Easy and medium difficulty players play based on risk tolerance.
  //If risk of failing is too high, stay
  Future<void> riskTolerance(
    Player currentCPUPlayer,
    double failureTolerance,
  ) async {
    double failureProb = calculateFailureProbability(currentCPUPlayer);
    // await Future.delayed(const Duration(milliseconds: 1500));
    if (currentCPUPlayer.doubleChance) {
      await _aiHits();
    } else if (failureProb < failureTolerance) {
      await _aiHits();
    } else {
      await _aiStays();
    }
  }

  // void gameRotation() {
  //   while (!gameEnd) {
  //     donePlayers = Set();
  //     handleNewRound();
  //     while (donePlayers.length < totalPlayerCount) {
  //       //TO DO: Handle this, will be different from python because has non-human players as well
  //       print("Player ${currentPlayerIndex}'s turn!");
  //       Player currentPlayer = players[currentPlayerIndex];
  //       if (currentPlayer.isDone) {
  //         print(
  //           "Player ${currentPlayerIndex} is already done! Going to next player!",
  //         );
  //       } else if (currentPlayer is CpuPlayer) {
  //         if (currentPlayer.difficulty == Difficulty.easy) {}
  //       } else {}

  //       currentPlayerIndex = getNextPlayer(currentPlayerIndex);
  //     }
  //   }
  // }

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

  //Calculate player's chance of busting
  double calculateFailureProbability(Player currentPlayer) {
    //If deck is empty, refill it
    if (deck.deckList.isEmpty) {
      deck.refill();
    }
    int outcomeCardinality =
        0; //the total number of cards in deck that can bust you

    for (double number in currentPlayer.numHandSet) {
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

  //Hard and Expert AI players compare E[X+n] to n
  Future<void> EVBasedComparison(Player currentPlayer) async {
    //if current player has double chance card, might as well hit
    //(May adjust to account for sales tax/income tax cards, minus cards, etc)
    if (currentPlayer.doubleChance) {
      print("Player has double chance. Hit");
      await _aiHits();
      return;
    }
    double ev = calculateEVCumulative(currentPlayer);
    double failureProb = calculateFailureProbability(currentPlayer);
    double successProb = 1 - failureProb;

    //ev is the expected value of the hit itself given it was a success.
    //So we multiply it by success probability. Then we add the event you fail
    //and get a duplicate: if you don't have a redeemer card, your points for the round become $0$,
    //so that value is $0$. If you DO have a redeemer card, you get to redeem 67% of your points, so
    //so your points become .67 * current value.
    //by failureProb.
    late double valueHit;
    if (currentPlayer.hasRedeemer) {
      valueHit =
          ev * successProb + .67 * currentPlayer.currentValue * failureProb;
    } else {
      valueHit = ev * successProb + 0 * failureProb;
    }
    print("Expected value of hit E[hit] = E[current value + X]: ${valueHit}");
    print("Current Value: ${currentPlayer.currentValue}");

    // await Future.delayed(const Duration(milliseconds: 1500));

    if (valueHit >= currentPlayer.currentValue) {
      print("Expected value is higher than current points. ");
      await _aiHits();
    } else {
      print("Current points exceed expected value. Stay!");
      await _aiStays();
    }
    return;
  }

  //Calculate actual expected value of next hit, including current points
  double calculateEVCumulative(Player currentPlayer) {
    double evCumulative =
        currentPlayer.currentValue +
        calculateEVMultCards() * calculateEVNumberCards(currentPlayer) +
        calculateEVPlusMinusValueCards() +
        calculateEVEventCards(currentPlayer);
    if (currentPlayer.numberHand.length == 5) {
      print(
        "CPU has 5 number cards! EV of getting 6 number card bonus: ${probOfNonduplicateNumberCard(currentPlayer) * 6.7} ",
      );
      evCumulative += probOfNonduplicateNumberCard(currentPlayer) * 6.7;
    } else if (currentPlayer.numberHand.length >= 6) {
      print(
        "CPU has >= 6 number cards! EV of getting 7+ number card bonus: ${probOfNonduplicateNumberCard(currentPlayer) * 21.67} ",
      );
      evCumulative += probOfNonduplicateNumberCard(currentPlayer) * 21.67;
    }
    return evCumulative;
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
      //If number card is a number that the player already has, skip it
      if (currentPlayer.numHandSet.contains(number)) {
        continue;
      }
      int amountOfSpecificNumberCardInDeck = deck.numberCardsLeft[number]!;

      evNumberCard +=
          number * (amountOfSpecificNumberCardInDeck / numCardsLeft);
      // totalNumberCards += amountOfSpecificNumberCardInDeck;
    }
    //The event that the card drawn was not a number card has a numeric value
    //of "0" so is commented here for semantic reasons
    //evNumberCard += 0 * (numCardsLeft - totalNumberCards) / numCardsLeft;
    return evNumberCard;
  }

  //Calculates the probability of getting a non-duplicate number card.
  //This method is primarily used for when player has 5+ number cards.
  //Specifically: If a player has 6 number cards, they will get a bonus +6.7
  //points on stay, and if a player has 7+ number cards, bonus is +21.67.
  //So when a CPU starts having 5 number cards, this method is called.
  double probOfNonduplicateNumberCard(Player currentPlayer) {
    //Current amount of cards left in deck
    int numCardsLeft = deck.deckList.length;
    int numNonduplicateCards = 0;

    for (int number in deck.numberCardsLeft.keys) {
      //If number card is a number that the player already has, skip it
      if (currentPlayer.numHandSet.contains(number)) {
        continue;
      }
      numNonduplicateCards += deck.numberCardsLeft[number]!;
    }
    return numNonduplicateCards / numCardsLeft;
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
      int amountofPlusMinusValueInDeck =
          deck.plusMinusCardsLeft[plusMinusValue]!;
      evPlusMinusValueCard +=
          plusMinusValue * (amountofPlusMinusValueInDeck / numCardsLeft);
      // totalNumberCards += amountOfSpecificNumberCardInDeck;
    }

    //The event that the card drawn was not a number card has a numeric value
    //of "0" so is commented here for semantic reasons
    //evNumberCard += 0 * (numCardsLeft - totalNumberCards) / numCardsLeft;
    return evPlusMinusValueCard;
  }

  double calculateEVEventCards(Player currentPlayer) {
    //TO DO: implement for each case
    if (isLastRemaining(currentPlayer)) {
      return calculateEventEVAlone(currentPlayer);
    } else {
      return calculateEventEVNotAlone(currentPlayer);
    }
  }

  //Method for checking if current player is the only player active in the round
  bool isLastRemaining(Player currentPlayer) {
    for (Player player in players) {
      if (player != currentPlayer && !player.isDone) {
        return false;
      }
    }
    return true;
  }

  //Method for calculating event EV when player is not alone
  double calculateEventEVNotAlone(Player currentPlayer) {
    //Current amount of cards left in deck
    int numCardsLeft = deck.deckList.length;

    double evEventCard = 0;
    print("${currentPlayer} is the only active player. Calculating alone EV");
    for (EventCardEnum eventCardEnum in deck.eventNumericalEVNotAlone.keys) {
      print(
        "Card: ${eventCardEnum.label}, value: ${deck.eventNumericalEVNotAlone[eventCardEnum]}",
      );
      print("Number of them left: ${deck.eventCardsLeft[eventCardEnum]}");
      evEventCard +=
          deck.eventNumericalEVNotAlone[eventCardEnum]! *
          deck.eventCardsLeft[eventCardEnum]! /
          numCardsLeft;
    }
    //Handle hand operator cards on case by case value
    evEventCard += calculateEVDoubleChance(currentPlayer, isAlone: false);
    evEventCard += calculateEVRedeemer(currentPlayer, isAlone: false);
    evEventCard += calculateEVDiscarder(currentPlayer);
    evEventCard += calculateEVIncomeTax(currentPlayer, isAlone: false);
    evEventCard += calculateEVThief(currentPlayer, isAlone: false);

    print("Final EV Event Alone: ${evEventCard}");
    return evEventCard;
  }

  //Method for calculating event EV when player is alone
  double calculateEventEVAlone(Player currentPlayer) {
    //Current amount of cards left in deck
    int numCardsLeft = deck.deckList.length;

    double evEventCard = 0;
    print("${currentPlayer} is the only active player. Calculating alone EV");
    for (EventCardEnum eventCardEnum in deck.eventNumericalEVAlone.keys) {
      print(
        "Card: ${eventCardEnum.label}, value: ${deck.eventNumericalEVAlone[eventCardEnum]}",
      );
      print("Number of them left: ${deck.eventCardsLeft[eventCardEnum]}");
      evEventCard +=
          deck.eventNumericalEVAlone[eventCardEnum]! *
          deck.eventCardsLeft[eventCardEnum]! /
          numCardsLeft;
    }
    //Handle hand operator cards on case by case value
    evEventCard += calculateEVDoubleChance(currentPlayer, isAlone: true);
    evEventCard += calculateEVRedeemer(currentPlayer, isAlone: true);
    evEventCard += calculateEVDiscarder(currentPlayer);
    evEventCard += calculateEVIncomeTax(currentPlayer, isAlone: true);
    evEventCard += calculateEVThief(currentPlayer, isAlone: true);
    print("Final EV Event Alone: ${evEventCard}");
    return evEventCard;
  }

  //Method for calculating ev of thief
  double calculateEVThief(Player currentPlayer, {required bool isAlone}) {
    if (isAlone) {
      print("Since player is alone, thief card is useless. EV is 0");
      return 0;
    }
    int numCardsLeft = deck.deckListLength;
    double numberCardsValue = 0;
    //Multiplier starts as x1 by default
    double currentMultValue = 1;
    double currentPlusValue = 0;
    double currentMinusValue = 0;
    (
      numberCardsValue,
      currentMultValue,
      currentPlusValue,
      currentMinusValue,
    ) = calculateCardUserValues(
      numberCardsValue,
      currentMultValue,
      currentPlusValue,
      currentMinusValue,
      currentPlayer,
    );
    double currentHypotheticalValue =
        currentMultValue * numberCardsValue + currentPlusValue;
    print("Current hypothetical value before steal: $currentHypotheticalValue");
    double bestRivalHypotheticalValue = -100000;
    for (Player player in game.gameManager.players) {
      if (!player.isDone &&
          player != currentPlayer &&
          player.dch.valueCardLength > 0) {
        double rivalHypotheticalValue = calculateRivalHypotheticalValue(
          numberCardsValue,
          currentMultValue,
          currentPlusValue,
          currentMinusValue,
          player,
        );
        print(
          "Rival player: ${player.playerName}, rival player's value: ${rivalHypotheticalValue}",
        );
        if (rivalHypotheticalValue >= bestRivalHypotheticalValue) {
          bestRivalHypotheticalValue = rivalHypotheticalValue;
        }
      }
    }
    //If noone can be stolen from, raw value is 0
    if (bestRivalHypotheticalValue == -100000) {
      print("No other player can be stolen. Thief raw value is 0");
      return 0;
    }
    // Else, there was an existing candidate to steal from, and their best hypothetical value was stored.
    //The raw thief value is just the difference between bestRivalHypotheticalValue and currentHypotheticalValue
    print(
      "Thief raw value: ${bestRivalHypotheticalValue - currentHypotheticalValue}",
    );
    double thiefEv =
        (bestRivalHypotheticalValue - currentHypotheticalValue) *
        deck.eventCardsLeft[EventCardEnum.Thief]! /
        numCardsLeft;
    print("Thief EV: ${thiefEv}");
    return thiefEv;
  }

  //Method for calculating ev of income tax card when alone
  double calculateEVIncomeTax(Player currentPlayer, {required bool isAlone}) {
    //if this is round 1, income tax has no effect
    if (currentRound <= 1) {
      return 0;
    }
    double incomeEV = 0;
    int numCardsLeft = deck.deckListLength;
    if (!currentPlayer.hasIncomeTax) {
      double taxRate = playerIncomeTaxRateAfterFirstRound(
        currentPlayer: currentPlayer,
        playerRankings: game.gameManager.totalCurrentLeaderBoard.topN(
          totalPlayerCount,
        ),
      );

      incomeEV +=
          (currentPlayer.currentValue + currentPlayer.totalValue) *
          (taxRate - 1) *
          deck.eventCardsLeft[EventCardEnum.IncomeTax]! /
          numCardsLeft;

      print(
        "Player currently doesn't have income tax! Income tax raw value: ${incomeEV / (deck.eventCardsLeft[EventCardEnum.IncomeTax]! / numCardsLeft)}. Income EV: $incomeEV",
      );
    }
    //If player already has an income tax card, if there is another player to give the income tax card to,
    //that is generally beneficial unless the player is last place.
    //Else, since there is no one else to give the
    //duplicate income tax card to, the new income tax card drawn is worthless
    else if (!isAlone) {
      //highest taxrate is currently 20% refund = 1.2, should never exceed 2
      double rivalTaxRate = 67;
      double bestRivalCurrentValue = 0;
      double bestRivalTotalValue = 0;
      for (Player otherActivePlayer in players) {
        if (!otherActivePlayer.isDone && otherActivePlayer != currentPlayer) {
          double tentativeTaxRate = playerIncomeTaxRateAfterFirstRound(
            currentPlayer: currentPlayer,
            playerRankings: game.gameManager.totalCurrentLeaderBoard.topN(
              totalPlayerCount,
            ),
          );
          if (tentativeTaxRate < rivalTaxRate) {
            rivalTaxRate = tentativeTaxRate;
            bestRivalCurrentValue = otherActivePlayer.currentValue;
            bestRivalTotalValue = otherActivePlayer.totalValue;
          }
        }
      }
      incomeEV +=
          (bestRivalTotalValue + bestRivalCurrentValue) *
          (rivalTaxRate - 1) *
          deck.eventCardsLeft[EventCardEnum.IncomeTax]! /
          numCardsLeft;

      print(
        "Player already has income tax! Rival Income tax raw value: ${incomeEV / (deck.eventCardsLeft[EventCardEnum.IncomeTax]! / numCardsLeft)}. Income EV: $incomeEV",
      );
    } else {
      print(
        "Player already has an income tax card. Hence the new income tax card would have been worthless!",
      );
    }
    return incomeEV;
  }

  //Method for calculating ev of double chance
  double calculateEVDoubleChance(
    Player currentPlayer, {
    required bool isAlone,
  }) {
    //Double Chance: If currentplayer does not have double chance, getting a
    // double chance would be super useful. Else, it is worthless
    //to get a duplicate double chance
    double evDoubleChance = 0;
    int numCardsLeft = deck.deckListLength;
    if (!currentPlayer.doubleChance) {
      print(
        "Player currently doesn't have double chance. Double Chance Raw value: $doubleChanceGoodRawValue",
      );
      print(
        "Number of Double chance cards: ${deck.eventCardsLeft[EventCardEnum.DoubleChance]}",
      );
      evDoubleChance +=
          doubleChanceGoodRawValue *
          deck.eventCardsLeft[EventCardEnum.DoubleChance]! /
          numCardsLeft;
    } // If player already has double chance, if they are not alone, they must give it to another palyer.
    //That is not good, negative value.
    else if (!isAlone) {
      print(
        "Player already have double chance, and is not alone, so they would have to give away a duplicate double chance! Double Chance Raw value: $doubleChanceBadRawValue",
      );
      print(
        "Number of Double chance cards: ${deck.eventCardsLeft[EventCardEnum.DoubleChance]}",
      );
      evDoubleChance +=
          doubleChanceBadRawValue *
          deck.eventCardsLeft[EventCardEnum.DoubleChance]! /
          numCardsLeft;
    } //Else, player has duplicate but is alone, this is neither good nor bad, still 0
    return evDoubleChance;
  }

  //Method for calculating EV of redeemer
  double calculateEVRedeemer(Player currentPlayer, {required bool isAlone}) {
    int numCardsLeft = deck.deckListLength;
    double evRedeemer = 0;
    //Redeemer: If current player does not have redeemer, getting  a
    //redeemer would be somwhat useful. Else, it is worthless
    //to get a duplicate redeemer
    if (!currentPlayer.hasRedeemer) {
      evRedeemer +=
          redeemerGoodRawValue *
          deck.eventCardsLeft[EventCardEnum.Redeemer]! /
          numCardsLeft;
      print(
        "Player currently doesn't have redeemer. Redeemer Raw: $redeemerGoodRawValue",
      );
      print(
        "Number of Redeemer cards: ${deck.eventCardsLeft[EventCardEnum.Redeemer]}",
      );
    } // If player already has redeemer, if they are not alone, they must give it to another palyer.
    //That is not good, negative value.
    else if (!isAlone) {
      evRedeemer +=
          redeemerBadRawValue *
          deck.eventCardsLeft[EventCardEnum.Redeemer]! /
          numCardsLeft;
      print(
        "Player already has redeemer, and is not alone so they would have to give away the duplicate redeemer!. Redeemer Raw: $redeemerBadRawValue",
      );
      print(
        "Number of Redeemer cards: ${deck.eventCardsLeft[EventCardEnum.Redeemer]}",
      );
    } //Else, player has duplicate but is alone, this is neither good nor bad, still 0
    return evRedeemer;
  }

  //Method for calculating EV of discarder
  double calculateEVDiscarder(Player currentPlayer) {
    //Discarder: First check for cards that are beneficial to discard.
    //If none exist, check for cards that hurt the least to discard.
    //If none exist, discarderEV is 0.

    //Good discarder ev
    double goodDiscarderEV = calculateEVGoodDiscarder(currentPlayer);
    if (goodDiscarderEV != 0) {
      return goodDiscarderEV;
    } else {
      //Bad discarder ev
      return calculateEVBadDiscarder(currentPlayer);
    }
  }

  //Method for calculating good discarderEV
  double calculateEVGoodDiscarder(Player currentPlayer) {
    //Good case
    //Best case scenario: player has an income tax card after round 1. This is the best card to discard
    //because it also affects total value.
    //Then, if current player has a minus card or a multiplier card with multiplier <1,
    //this is good; for Multiplier cards (this takes priority), take EV as (1-lowest Mult) * sum of number cards.
    //For minus value cards, take the lowest minus value card, take absolute value,
    //and let that be the EV value of discarder.
    double goodDiscarderEV = 0;
    int numCardsLeft = deck.deckListLength;
    print(
      "Discard ev calculation! Number of discarders in deck: ${deck.eventCardsLeft[EventCardEnum.Discarder]}",
    );
    if (currentPlayer.hasIncomeTax && currentRound > 1) {
      double taxRate = playerIncomeTaxRateAfterFirstRound(
        currentPlayer: currentPlayer,
        playerRankings: game.gameManager.totalCurrentLeaderBoard.topN(
          totalPlayerCount,
        ),
      );
      if (taxRate < 1) {
        goodDiscarderEV =
            (currentPlayer.currentValue + currentPlayer.totalValue) /
            taxRate *
            deck.eventCardsLeft[EventCardEnum.Discarder]! /
            numCardsLeft;
      }
      print(
        "Player has income tax! Tax rate calculated as: ${taxRate}, so discarder Raw value candidate due to removing income taxis",
      );
      print(
        "(current value + total value) / tax rate * #discarders/#cards in deck = (${currentPlayer.currentValue} + ${currentPlayer.totalValue}) / ${taxRate} = ${(currentPlayer.currentValue + currentPlayer.totalValue) / taxRate}  ",
      );
    }

    double lowestMultiplier = 1;
    for (cd.ValueActionCard multCard in currentPlayer.dch.multHand) {
      if (multCard.value < lowestMultiplier) {
        lowestMultiplier = multCard.value;
      }
    }
    if (lowestMultiplier < 1) {
      print(
        "Player has a bad multiplier of $lowestMultiplier! Therefore discarder Raw value candidate due to removing bad multiplier is:",
      );
      print(
        "(1 - lowest multiplier) * (sum of number cards)  = ${(1 - lowestMultiplier) * currentPlayer.sumNumberCards()}",
      );
      goodDiscarderEV = max(
        goodDiscarderEV,
        (1 - lowestMultiplier) *
            currentPlayer.sumNumberCards() *
            deck.eventCardsLeft[EventCardEnum.Discarder]! /
            numCardsLeft,
      );
    }
    //Now check minus cards and see if player can get a higher EV
    double lowestMinus = 1;
    //The keys are absolute values of the minus values of the minus cards,
    //The value is the list of minus cards corresponding to the key
    for (final MapEntry(:key, :value)
        in currentPlayer.dch.minusHandMap.entries) {
      if (-key < 0 && value.isNotEmpty && -key < lowestMinus) {
        lowestMinus = -key;
      }
    }
    if (lowestMinus < 0) {
      print(
        "Player has a minus card of ${-lowestMinus}! Treated as a potential discarder raw value candidate due to removing the minus card",
      );
      goodDiscarderEV = max(
        goodDiscarderEV,
        //-lowestMinus because removing the minus card gives the positive value
        -lowestMinus *
            deck.eventCardsLeft[EventCardEnum.Discarder]! /
            numCardsLeft,
      );
    }
    print(
      "Ultimate goodDiscarder raw value (Choose max among the candidates): ${goodDiscarderEV / (deck.eventCardsLeft[EventCardEnum.Discarder]! / numCardsLeft)}, goodDiscarderEV: ${goodDiscarderEV}",
    );
    return goodDiscarderEV;
  }

  //Method for calculating bad discarderEV
  double calculateEVBadDiscarder(Player currentPlayer) {
    int numCardsLeft = deck.deckListLength;
    double badDiscarderEV = 0;
    //First, check double chance/redeemer. Those are worst case scenario to be forced to discard
    if (currentPlayer.doubleChance) {
      print(
        "Player might have to discard double chance! Discarder Raw value candidate due to removing double chance: ${doubleChanceBadRawValue}",
      );
      badDiscarderEV =
          doubleChanceBadRawValue *
          deck.eventCardsLeft[EventCardEnum.Discarder]! /
          numCardsLeft;
    }
    if (currentPlayer.hasRedeemer) {
      print(
        "Player might have to discard redeemer! Discarder Raw value candidate due to removing redeemer: ${redeemerBadRawValue}",
      );
      //If player has double chance, redeemer is better to discard. If player doesn't have double chance, redeemer is the first candidate.
      //In any case, assign badDiscarderEV for redeemer case as the candidate.
      badDiscarderEV =
          redeemerBadRawValue *
          deck.eventCardsLeft[EventCardEnum.Discarder]! /
          numCardsLeft;
    }
    //Just make default lowestGoodMult a large multiplier; it will never exceed 2 (which
    //we don't even implement because x2 is already op)
    double lowestGoodMult = 6.7;
    for (cd.ValueActionCard multCard in currentPlayer.multHand) {
      if (multCard.value >= 1 && multCard.value < lowestGoodMult) {
        lowestGoodMult = multCard.value;
      }
    }
    if (lowestGoodMult < 6.7) {
      print(
        "Player might have to discard a good multiplier! Discarder Raw value candidate due to removing good multiplier: ${-currentPlayer.sumNumberCards() / lowestGoodMult}",
      );
      if (badDiscarderEV == 0) {
        badDiscarderEV =
            -currentPlayer.sumNumberCards() /
            lowestGoodMult *
            deck.eventCardsLeft[EventCardEnum.Discarder]! /
            numCardsLeft;
      } else {
        badDiscarderEV = max(
          badDiscarderEV,
          -currentPlayer.sumNumberCards() /
              lowestGoodMult *
              deck.eventCardsLeft[EventCardEnum.Discarder]! /
              numCardsLeft,
        );
      }
    }
    //Now check plus cards to see if we can have a smaller loss
    double lowestPlus = 67;
    for (cd.ValueActionCard plusCard in currentPlayer.addHand) {
      if (plusCard.value < lowestPlus) {
        lowestPlus = plusCard.value;
      }
    }
    if (lowestPlus < 67) {
      print(
        "Player might have to remove a plus card of value ${lowestPlus}! Discarder Raw value candidate due to removing a plus card: ${-lowestPlus} ",
      );
    }
    if (lowestPlus < 67) {
      if (badDiscarderEV == 0) {
        badDiscarderEV =
            -lowestPlus *
            deck.eventCardsLeft[EventCardEnum.Discarder]! /
            numCardsLeft;
      } else {
        badDiscarderEV = max(
          badDiscarderEV,
          -lowestPlus *
              deck.eventCardsLeft[EventCardEnum.Discarder]! /
              numCardsLeft,
        );
      }
    }
    //So discarderEV either has the negative ev of mult or plus, whichever is less bad. If it is
    //still 0, that means player does not have any card to discard. That is okay, just return it
    print(
      "Final badDiscarder raw value: ${badDiscarderEV / (deck.eventCardsLeft[EventCardEnum.Discarder]! / numCardsLeft)}. badDiscarderEV: ${badDiscarderEV}",
    );
    return badDiscarderEV;
  }

  //Method for calculating failure probability of the last numCard cards in the deck.
  double calculateFailureProbLastNumCards({required int numCards}) {
    int start = deck.deckListLength - 1 - numCards;
    if (start <= 0) {
      deck.refill();
    }
    int end = deck.deckListLength - 1;
    List<cd.Card> cardsOfInterest = deck.deckList.sublist(start, end);

    int outcomeCardinality = 0;
    for (cd.Card card in cardsOfInterest) {
      if (card is cd.NumberCard) {
        if (getCurrentPlayer!.numHandSet.contains(card.value)) {
          outcomeCardinality += 1;
        }
      }
    }
    return outcomeCardinality / numCards;
  }

  // This manages drawing a card form deck and then putting it into player
  Future<EventDifferentAction> _handleDrawCardFromDeck(int playerIndex) async {
    Player currentPlayer = players[playerIndex];

    // Show current player decided to hit
    await currentPlayer.playerActionText.setAsHitting();

    // Draw card and add it to deck game world start position
    final card = await deck.draw();
    card.isVisible = false;
    game.world.add(card);
    card.startAtDeckSetting();
    print("Got card: $card ${card.cardType}");

    if (card is! cd.EventActionCard) {
      // Instant events or all other cards except event action
      await currentPlayer.onHit(card);
    } else {
      // Show event card animations
      runningEvent = card;
      runningEvent?.cardUser = currentPlayer;

      // Set completer for event to be toggled by user or manually removed for AI
      runningEvent!.drawAnimation.init();

      // Wait for deck draw animation to finish
      await runningEvent!.drawEventCardAnimation(
        isInfinite: !currentPlayer.isCpu(),
      );
      await runningEvent!.drawAnimation.wait();

      // Send event card to discard if not handEventAction
      if (runningEvent is cd.EventActionCard &&
          runningEvent is! cd.HandEventActionCard) {
        await deck.sendToDiscardPileAnimation(runningEvent as cd.Card);
        await Future.delayed(Duration(milliseconds: 300));
      }

      // Sets up event completer, so we can wait on user input if necessary
      runningEvent!.eventCompleted.init();
      // Execute action
      await runningEvent!.executeOnEvent();
      // Wait for event/user interaction to complete
      await runningEvent!.eventCompleted.wait();
    }

    // Default return type
    EventDifferentAction returnType = EventDifferentAction.none;

    //Update current + total leaderboard; we need the most recent
    //board each turn for the most accurate tax rate calculation
    totalCurrentLeaderBoard.updateEntireLeaderboard();

    if (currentPlayer.isDone) {
      //If player's score reached threshold, end the game
      print("Current player's total value: ${currentPlayer.totalValue}");
      print("Current Player's current value: ${currentPlayer.currentValue}");
      print(
        "currentPlayer.totalValue + currentPLayer.currentValue: ${currentPlayer.totalValue + currentPlayer.currentValue}",
      );
      if (currentPlayer.totalValue + currentPlayer.currentValue >=
          winningThreshold) {
        await handleEndGame();
      }
      donePlayers.add(currentPlayer);
    } else {
      // Only if player is not double allow them to do additional hit stay
      if (card is TopPeekCard) {
        print("Top Peek drawn - showing top card and allow second choice");
        returnType = EventDifferentAction.topPeek;
      } else if (card is ChoiceDraw && card.drawEventCardAgain) {
        print("Choice Draw - needs to draw event card again");
        card.drawEventCardAgain = false;
        return await _handleDrawCardFromDeck(currentPlayerIndex);
      } else if (card is ForecasterCard) {
        print(
          "Forecaster card drawn: showing top numCard (right now is 4) cards and allow second choice",
        );
        returnType = EventDifferentAction.forecast;
      } else if (card is FlipThreeCard) {
        print(
          "Flip Three Card Drawn - $currentPlayer making ${runningEvent?.affectedPlayer} Flip3!",
        );
        if (runningEvent != null && runningEvent!.affectedPlayer != null) {
          // Force current player index to look at player forced to flip
          var forcedFlipper = runningEvent!.affectedPlayer!;
          currentPlayerIndex = forcedFlipper.playerNum - 1;

          // Disable hit/stay
          hud.disableHitAndStayBtns();

          // Determine count badge, if the person flipping is also the enforcer, then they will be flipping more than 3 times
          forcedToPlay.addPlayer(current: forcedFlipper, forcePlayTimes: 3);
          // NOTE: if this becomes 0, this is an error, we always add 3 initially, so it should never be 0
          int flipTimes = forcedToPlay.getTopPlayerCount() ?? 0;
          hud.setHitCountBadge(flipTimes, accumulateHitCount: false);

          // Loop for the given user only
          while (forcedToPlay.isPlayerAtTop(forcedFlipper)) {
            print("Stack: $forcedToPlay");
            // let player hit
            // Note after this returns, even if there is a recursive F3 call, F3 will handle restoring current player after exit
            await _handleDrawCardFromDeck(forcedFlipper.playerNum - 1);

            // Check if current player has busted to early exit
            if (forcedFlipper.isDone) {
              print("$forcedFlipper busted during FLIP3");
              hud.hideHitCountBadge();
              // Remove player if they busted
              forcedToPlay.removeTopPlayer();
              break;
            }

            // Set or remove badge after player decremented
            // Player might get removed in that case
            forcedToPlay.decrementTopPlayer();
            var forcedPlayerCount = forcedToPlay.getTopPlayerCount() ?? 0;
            print(
              "Decremented Count: $forcedPlayerCount | Stack after: $forcedToPlay",
            );

            if (forcedPlayerCount == 0) {
              hud.hideHitCountBadge();
              // Current player has finished so exit out
              break;
            } else {
              hud.setHitCountBadge(
                forcedPlayerCount,
                accumulateHitCount: false,
              );
            }
          }

          // Restore original player
          print("RESTORING PLAYER TO $currentPlayer from <-- $forcedFlipper");
          currentPlayerIndex = currentPlayer.playerNum - 1;

          // Remove badge
          hud.hideHitCountBadge();

          ////The following two lines are commented out; player shouldn't have to have another turn after using flip three
          // Return flipThree, so we can return and the current user gets another chance to hit or stay
          // returnType = EventDifferentAction.flipThree;
        } else {
          print("ERROR - Flip 3 doesn't have a valid affected player set!");
        }
      }
    }

    return returnType;
  }

  Future<void> handleEndGame() async {
    print("End game ocurred!");
    // update current and end game leaderboards
    currentLeaderBoard.updateEntireLeaderboard();
    totalLeaderBoard.updateEntireLeaderboard();

    // clear variable fields
    pot.reset();
    donePlayers.clear();
    rotationPlayerOffset = 0;
    currentPlayerIndex = 0;

    Map<Player, double> potDistrib = {};
    for (int i = 0; i < totalPlayerCount; i++) {
      potDistrib[players[i]] = 0.0;
    }
    await game.endGameDialog(
      totalPlayerCount,
      totalLeaderBoard.topN(totalPlayerCount),
      currentLeaderBoard.topN(totalPlayerCount),
      potDistrib,
    );

    return;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // Add deck/discard pile
    deck = CardDeck(position: worldDeckPos);
    game.world.add(deck);

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

    // print(
    //   "Center: ${rotationCenter} | Left: ${leftPlayerPos} Right: ${rightPlayerPos} rx: ${rx} | top: ${topPlayerPos} bottom: ${bottomPlayerPos}",
    // );

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

    // // Set Up Game pot
    pot = Pot(startScore: 0, position: worldPotPos, size: Vector2(10, 10));
    game.world.add(pot);

    // Rotation indicator
    rotationIndicator = SpinningArrowRing(
      rotationSpeed: 0.3,
      rotationDirection: rotationDirection,
      position: Vector2(worldPotPos.x, worldPotPos.y - pot.size.y * 2),
      size: Vector2.all(120),
    );
    game.world.add(rotationIndicator);

    // PathDebugComponent
    // var lp = determineBezierRotationPoints(
    //   PlayerSlot.top,
    //   PlayerSlot.bottom,
    //   completeLoop: true,
    // );
    // List<PathDebugComponent> pdb = [];
    // for (final p in lp) {
    //   pdb.add(PathDebugComponent(path: p));
    // }
    // game.world.addAll(pdb);

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

    // Round over text animation
    roundOverTextAnimation = TextAnimations(position: Vector2.all(0));
    game.world.add(roundOverTextAnimation);

    // We had the leaderboard initially, but we decided to hold off on it
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await handleNewRound();
    // });
  }

  // Initialize players at position
  void _initPlayerList() {
    int humanCount = 0;
    int totalHumans = totalPlayerCount - game.setupSettings.aiPlayerCount;
    for (int i = 0; i < totalPlayerCount; ++i) {
      // NOTE: change get set up position, to not use player count configuration
      PlayerSlot currSlot = _getSetUpPosIndex(i);
      Vector2 pos = _getVectorPosByPlayerSlot(currSlot);
      print("Setting Player$i $currSlot");

      Player p;
      if (humanCount < totalHumans) {
        p = HumanPlayer(playerNum: i + 1, currSlot: currSlot)..position = pos;
        humanCount++;
      } else {
        p = CpuPlayer(
          playerNum: i + 1,
          difficulty: fromLevel(game.setupSettings.aiDifficulty),
          currSlot: currSlot,
        )..position = pos;
      }

      players.add(p);
      totalLeaderBoard.add(p);
      currentLeaderBoard.add(p);
      totalCurrentLeaderBoard.add(p);
    }
  }

  // Set up on stay pressed handler
  Future<void> _aiStays() async {
    print("_aiStays");
    if (getCurrentPlayer != null && !getCurrentPlayer!.isCpu()) {
      print("HUMAN CANNOT STAY FOR CPU");
      return;
    }
    if (animatePlayerRotation || buttonPressed) {
      print(
        "ANIMATION DISABLED UNTIL CURR FINISHED $animatePlayerRotation || BUTTON ALREADY PRESSED $buttonPressed",
      );
      return;
    }

    buttonPressed = true;
    hud.disableHitAndStayBtns();

    Player currentPlayer = players[currentPlayerIndex];
    await currentPlayer.handleStay();

    //If player's score reached threshold, end the game
    print("Current player's total value: ${currentPlayer.totalValue}");
    print("Current Player's current value: ${currentPlayer.currentValue}");
    print(
      "currentPlayer.totalValue + currentPLayer.currentValue: ${currentPlayer.totalValue + currentPlayer.currentValue}",
    );
    if (currentPlayer.totalValue + currentPlayer.currentValue >=
        winningThreshold) {
      handleEndGame();
    }
    totalCurrentLeaderBoard.updateEntireLeaderboard();

    donePlayers.add(currentPlayer);
    await Future.delayed(const Duration(milliseconds: 500));

    if (donePlayers.length == totalPlayerCount) {
      await handleNewRound();
      return;
    }

    // Rotate the players and disable hit/stay when running
    _rotatePlayers();
  }

  // Set up on hit pressed handler
  // Handles rotation, and other functionality
  Future<void> _aiHits() async {
    print("_aiHits");
    if (getCurrentPlayer != null && !getCurrentPlayer!.isCpu()) {
      print("HUMAN CANNOT HIT FOR CPU");
      return;
    }
    if (animatePlayerRotation || buttonPressed) {
      print(
        "ANIMATION DISABLED UNTIL CURR FINISHED $animatePlayerRotation || BUTTON ALREADY PRESSED $buttonPressed",
      );
      return;
    }
    buttonPressed = true;
    hud.disableHitAndStayBtns();

    // Draw cards from deck and handle event
    var eventDifferentAction = await _handleDrawCardFromDeck(
      currentPlayerIndex,
    );

    // If player busted after an event, go to next player
    if (getCurrentPlayer!.isDone == false) {
      if (eventDifferentAction == EventDifferentAction.topPeek) {
        //If you are human player, need buttons reenabled to do another action. Else, should not
        //have them enabled during a CPU's second turn
        print("!!!!Enabled second action for TopPeek");
        buttonPressed = false;
        await expertPeek(getCurrentPlayer as CpuPlayer);
        //Since this is their second action, you want to do early return here to avoid rotation being messed up because their first action
        //function call is still active
        return;
      } else if (eventDifferentAction == EventDifferentAction.forecast) {
        //Strategy: if failure prob is 50% or higher, stay, else hit.
        //Reason why I do this is because: For EV, if we just base our EV on four cards and they were all just minus
        //cards of value 1, the AI would just stay. But this isn't really a big loss when they could potentially hit
        //a bigger number card afterwards
        print("!!!!Enabled second action for Forecaster");
        buttonPressed = false;
        //If player has double chance, no point in not hitting
        if (getCurrentPlayer!.doubleChance) {
          print("Player has double chance. Hit!");
          await _aiHits();
          //Since this is their second action, you want to do early return here to avoid rotation being messed up because their first action
          //function call is still active
          return;
        } else if (calculateFailureProbLastNumCards(numCards: 4) >= .5) {
          print("Forecaster failure prob >= .5. Stay!");
          await _aiStays();
        } else {
          print("Forecaster failure prob < .5. Hit!");
          await _aiHits();
          //Since this is their second action, you want to do early return here to avoid rotation being messed up because their first action
          //function call is still active
          return;
        }
      }
    }
    //Reset eventDifferentAction to none
    eventDifferentAction = EventDifferentAction.none;

    await Future.delayed(const Duration(milliseconds: 500));

    if (donePlayers.length == totalPlayerCount) {
      await handleNewRound();
      return;
    }

    // Rotate the players and disable hit/stay when running
    _rotatePlayers();
  }

  // Set up on stay pressed handler
  Future<void> _onStayPressed() async {
    print("_onStayPressed");
    if (getCurrentPlayer != null && getCurrentPlayer!.isCpu()) {
      print("USER CANNOT STAY FOR CPU");
      return;
    }
    if (animatePlayerRotation || buttonPressed) {
      print(
        "ANIMATION DISABLED UNTIL CURR FINISHED $animatePlayerRotation || BUTTON ALREADY PRESSED $buttonPressed",
      );
      return;
    }

    buttonPressed = true;
    hud.disableHitAndStayBtns();

    Player currentPlayer = players[currentPlayerIndex];
    await currentPlayer.handleStay();
    //If player's score reached threshold, end the game
    print("Current player's total value: ${currentPlayer.totalValue}");
    print("Current Player's current value: ${currentPlayer.currentValue}");
    print(
      "currentPlayer.totalValue + currentPLayer.currentValue: ${currentPlayer.totalValue + currentPlayer.currentValue}",
    );
    if (currentPlayer.totalValue + currentPlayer.currentValue >=
        winningThreshold) {
      handleEndGame();
    }
    //Update current + total leaderboard
    totalCurrentLeaderBoard.updateEntireLeaderboard();
    donePlayers.add(currentPlayer);
    await Future.delayed(const Duration(milliseconds: 500));

    if (donePlayers.length == totalPlayerCount) {
      await handleNewRound();
      return;
    }

    // Rotate the players and disable hit/stay when running
    _rotatePlayers();
  }

  // Set up on hit pressed handler
  // Handles rotation, and other functionality
  Future<void> _onHitPressed() async {
    print("_onHitPressed");
    if (getCurrentPlayer != null && getCurrentPlayer!.isCpu()) {
      print("USER CANNOT HIT FOR CPU");
      return;
    }
    if (animatePlayerRotation || buttonPressed) {
      print(
        "ANIMATION DISABLED UNTIL CURR FINISHED $animatePlayerRotation || BUTTON ALREADY PRESSED $buttonPressed",
      );
      return;
    }

    buttonPressed = true;
    hud.disableHitAndStayBtns();

    calculateEVCumulative(getCurrentPlayer!);
    // Draw cards from deck and handle event
    var eventDifferentAction = await _handleDrawCardFromDeck(
      currentPlayerIndex,
    );
    // Running event finished so clear it
    runningEvent = null;

    if ((eventDifferentAction == EventDifferentAction.topPeek ||
            eventDifferentAction == EventDifferentAction.forecast) &&
        !getCurrentPlayer!.isDone) {
      //If you are human player, need buttons reenabled to do another action. Else, should not
      //have them enabled during a CPU's second turn
      if (getCurrentPlayer == null) {
        print("BIG ERROR - CURRENT PLAYER WAS NULL ON ROTATION");
        return;
      } else {
        print("!!!!Enabled second action");
        buttonPressed = false;
        if (!getCurrentPlayer!.isCpu()) {
          hud.enableHitAndStayBtns();
        }

        // if current player isn't done yet, exit out, so they can hit/stay again without rotating to next player
        if (getCurrentPlayer!.isDone == false) {
          return;
        }
      }
    }

    await Future.delayed(const Duration(seconds: 1));

    if (donePlayers.length == totalPlayerCount) {
      await handleNewRound();
      return;
    }
    // calculateEVCumulative(getCurrentPlayer!);
    // Rotate the players and disable hit/stay when running
    _rotatePlayers();
  }

  Future<void> _rotatePlayers() async {
    //Get the next player to be rotated to
    currentPlayerIndex = _getNextBottomPlayerIndex(
      currentPlayerIndex,
      totalPlayerCount,
      rotation: rotationDirection,
    );

    // print("Current player in rotatePlayers: ${currentPlayerIndex}");
    // print("What is rotation offset: ${rotationPlayerOffset}");
    //Continue to skip done players, or automatically handle action for cpu players without rotating
    //keep doing until it's a human player's turn who is still in the round
    while (players[currentPlayerIndex].isDone) {
      currentPlayerIndex = _getNextBottomPlayerIndex(
        currentPlayerIndex,
        totalPlayerCount,
        rotation: rotationDirection,
      );
      rotationPlayerOffset++;
    }

    for (int i = 0; i < totalPlayerCount; ++i) {
      Player p = players[i];
      int steps = _getNextRotationSteps(
        p.currSlot,
        extraRotation: rotationPlayerOffset,
      );
      p.moveToSlot = PlayerSlot.getNextPlayerSlot(
        p.currSlot,
        rotationDirection == PlayerRotation.clockWise,
        steps,
      );

      print(
        "p $i From ${p.position} | ${p.currSlot} to ${p.moveToSlot} takes ${steps} steps",
      );

      var bzPath = determineBezierRotationPoints(p.currSlot, p.moveToSlot);
      p.startRotation(bzPath);
    }

    // If human player we don't have offset so reset
    rotationPlayerOffset = 0;
    // Set stay and hit to disabled while it's rotating, once finished rotating hit and stay will be reenabled
    animatePlayerRotation = true;
    hud.disableHitAndStayBtns();
  }

  //Method for making player buttons clickable
  // Button click verf is a bool function if you need to pass custom logic before enabling a players button
  void makePlayersClickable(bool Function(Player?)? buttonClickVerf) {
    for (Player player in players) {
      //If buttonClickVerf is null, just need to check if player is not done.
      //Else, need to check if player is not done, AND buttonCLickVerf(Player) is true
      if (player.isDone == false &&
          (buttonClickVerf == null || buttonClickVerf(player) == true)) {
        player.button.buttonClickStatus = true;
      }
    }
    return;
  }

  //Method for making player buttons not clickable
  void makePlayersUnclickable() {
    for (Player player in players) {
      player.button.buttonClickStatus = false;
    }
    return;
  }

  // Returns bezier paths from one point to another based on rotation direction
  // One path is a 90 degree rotation
  // If completeLoop is true, it will just take start and do a full rotation to reach start again
  List<Path> determineBezierRotationPoints(
    PlayerSlot start,
    PlayerSlot end, {
    bool completeLoop = false,
  }) {
    List<Path> paths = [];

    // Start, end, control points of bezier
    Vector2 sp, ep, cp = Vector2.all(0);
    // Control curvature for ellipse
    double controlCurveX = 0.85, controlCurveY = 1;
    PlayerSlot curr = start, next = start;

    while (curr != end || completeLoop) {
      // Get next player slot
      next = PlayerSlot.getNextPlayerSlot(
        curr,
        rotationDirection == PlayerRotation.clockWise,
        1,
      );

      // Get vectors based on slots
      sp = _getVectorPosByPlayerSlot(curr);
      ep = _getVectorPosByPlayerSlot(next);

      switch (curr) {
        case PlayerSlot.top:
          cp = Vector2(ep.x * controlCurveX, sp.y * controlCurveY);
        case PlayerSlot.right:
          cp = Vector2(sp.x * controlCurveX, ep.y * controlCurveY);
        case PlayerSlot.bottom:
          cp = Vector2(ep.x * controlCurveX, sp.y * controlCurveY);
        case PlayerSlot.left:
          cp = Vector2(sp.x * controlCurveX, ep.y * controlCurveY);
      }

      // Add ellipse path to list;
      final path =
          Path()..quadraticBezierTo(
            cp.x - sp.x,
            cp.y - sp.y,
            ep.x - sp.x,
            ep.y - sp.y,
          );
      paths.add(path);

      // Update curr position to next slot
      curr = next;

      // If complete loop finished exit while loop
      if (completeLoop && curr == start) {
        break;
      }
    }

    return paths;
  }

  // NOTE: This should only be used for initializing players array
  // playerIndex represents where the player is in the player array
  // Returns based on playercount and where the index is, gives the index that maps to bottom:0, left: 1, top: 2, right: 3
  PlayerSlot _getSetUpPosIndex(int playerIndex) {
    PlayerCountSlotConfig pcc = PlayerCountSlotConfig.fromPlayerCount(
      totalPlayerCount,
    );
    // print("Config: $pcc");

    // print("label: ${pcc.label[playerIndex % totalPlayerCount]}");
    return pcc.label[playerIndex % totalPlayerCount];
  }

  // Maps the index to the given player position
  Vector2 _getVectorPosByPlayerSlot(PlayerSlot pos) {
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
  PlayerSlot? _getPlayerSlotByVectorPos(Vector2 v) {
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
    // print(
    //   "From index: ${currArrayIndex} to index value: ${toIndex} from indexRot of ${toIndexRot}",
    // );
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

  // Number of (90 degree) steps to the next position
  int _getNextRotationSteps(PlayerSlot currSlot, {int extraRotation = 0}) {
    int normalizedExtraRotation = extraRotation % totalPlayerCount;
    int toPosIndex = _getNextPosIndex(
      currSlot,
      rotDirection: rotationDirection,
      extraRotationStep: normalizedExtraRotation,
    );
    // print(
    //   "Rotating player clockwise? ${rotationDirection} from ${currSlot.index} to $toPosIndex",
    // );
    int rotMagnitude = rotationDirection == PlayerRotation.clockWise ? 1 : -1;
    return ((toPosIndex - currSlot.index) * rotMagnitude) %
        GameSetupSettingsConstants.totalPlayerCountMax;
  }

  Future<void> _onRotationFinished() async {
    // For debugging, just make new line to separate turns
    print("Rotation Finished\n");
    print("num cards left in deck: ${deck.deckList.length}");

    //With how income tax works,
    //if a player has an income tax card, they need to know the most recent total and current values
    //to determine tax rate.
    //TO DO: There might be a more efficient way to handle this.
    for (Player player in players) {
      if (player.hasIncomeTax && !player.isDone) {
        player.updateCurrentValue();
        totalCurrentLeaderBoard.updateEntireLeaderboard();
      }
    }

    animatePlayerRotation = false;
    buttonPressed = false;
    if (players[currentPlayerIndex].isCpu()) {
      hud.disableHitAndStayBtns();
      print("Current player${currentPlayerIndex + 1} is CPU");
      await aiTurn(players[currentPlayerIndex] as CpuPlayer);
      // print("next bottom index: ${nextPlayerBottomIndex}");
    } else {
      hud.enableHitAndStayBtns();
    }
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

        // Update position of players
        for (int i = 0; i < totalPlayerCount; ++i) {
          Player p = players[i];

          if (!p.isRotating) {
            p.currSlot = p.moveToSlot;
            p.position.setFrom(_getVectorPosByPlayerSlot(p.currSlot));
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
