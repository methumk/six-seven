import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/cards/card_component.dart';
import 'package:six_seven/components/cards/deck.dart';
import 'package:flutter/material.dart' as mat;
import 'package:six_seven/components/cards/value_action_text.dart';
import 'package:six_seven/components/circular_image_component.dart';
import 'package:six_seven/components/players/player.dart';
import 'package:six_seven/components/rounded_border_component.dart';
import 'package:six_seven/components/wrapping_text_box.dart';
import 'package:six_seven/data/enums/event_cards.dart';
import 'package:six_seven/pages/game/game_manager.dart';
import 'package:six_seven/pages/game/game_screen.dart';
import 'package:six_seven/utils/data_helpers.dart';
import 'package:six_seven/utils/event_completer.dart';

enum CardType {
  numberCard("Number card of value: "),
  valueActionCard("Value Action Card of value: "),
  eventActionCard("Event Action Card with effect: "),
  valueActionMinusCard("Minus Card: "),
  valueActionPlusCard("Plus card: "),
  valueActionMultCard("Mult Card: ");

  final String label;
  const CardType(this.label);
}

abstract class Card extends CardComponent
    with HasGameReference<GameScreen>, TapCallbacks {
  late CardType cardType;
  static final Vector2 cardSize = Vector2(80, 140);
  static final Vector2 halfCardSize = cardSize / 2;
  late final Color defaultBorderColor;

  // For every card give it this value, but only events have it set
  EventCardEnum eventEnum = EventCardEnum.None;

  // Attributes related to cards being touched moved inside deck
  MoveToEffect? dragEndMoveTo;
  int savePriority = 0;
  Vector2? deckReturnTo;

  late final Vector2 _bodyDescripPos;
  late final Vector2 _bodyDescripSize;
  late final Vector2 _bodyDescripPadding;

  SequenceEffect? _onDrawEffect;
  bool get isDrawEffectRunning =>
      _onDrawEffect != null && _onDrawEffect!.isMounted;

  EventCompleter eventCompleted = EventCompleter();
  EventCompleter inputSelect = EventCompleter();
  EventCompleter drawAnimation = EventCompleter();

  // Completer to determine which card was picked
  void Function(Card)? onTapUpSelector;
  void Function(Card)? onTapDownSelector;

  static const double cardBorderWidth = 2.5;
  static const double cardBorderRadius = 5.0;
  static const int cardGlowLayers = 3;
  static const Color cardGlowColor = Colors.yellow;
  static const Color cardBorderColor = Colors.white;
  static const Color cardFrontColor = Color.fromARGB(255, 170, 149, 97);
  static const Color cardBackColor = Color.fromARGB(255, 34, 91, 176);

  Card({
    required this.cardType,
    Vector2? totalCardSize,
    super.position,
    super.borderWidth = cardBorderWidth,
    super.borderRadius = cardBorderRadius,
    super.borderColor = cardBorderColor,
    super.frontFillColor = cardFrontColor,
    super.backFillColor = cardBackColor,
    super.glowColor = cardGlowColor,
    super.glowLayers = cardGlowLayers,
    super.isClickable = false,
    super.isDraggable = false,
    super.isGlowing = false,
    super.animateGlow = true,
  }) : super(totalCardSize: totalCardSize ?? cardSize) {
    anchor = Anchor.bottomCenter;
    defaultBorderColor = Colors.white;
  }

  //TO DO: Add players as param inputs for executeOnEvent
  //once player classes have been constructed
  Future<void> executeOnEvent();

  double executeOnStay(double currentValue);

  // General description of the card for debugging purposes
  void description();

  void toggleAllUserCardMovement(bool toggle) {
    setClickable(toggle);
    setDraggable(toggle);
  }

  void resetBorderColor() {
    setBorderColor(cardBorderColor);
  }

  void setBorderColor(Color c) {
    frontFace.borderColor = c;
    backFace.borderColor = c;
  }

  void onDragEndReturnTo(Vector2 returnPos, int priority) {
    if (deckReturnTo == null) {
      deckReturnTo = returnPos.clone();
    } else {
      deckReturnTo!.setFrom(returnPos);
    }
    savePriority = priority;
  }

  void resetSize() {
    size = Card.cardSize;
    scale = Vector2.all(1.0);
    priority = 1;
  }

  void resetCardSettings() {
    resetBorderColor();
    setGlowing(false);
    resetSize();
    toggleAllUserCardMovement(false);
  }

  Future<void> dragEndReturnEffect() async {
    if (deckReturnTo == null) return;
    await moveTo(
      deckReturnTo!,
      EffectController(duration: 0.3, curve: Curves.easeInOut),
    );
  }

  // Initial settings when getting drawn from the deck
  void startAtDeckSetting() {
    // Hide initially to set up card as flipped down and at card position
    isVisible = false;

    // reset card settings
    resetCardSettings();

    // Make sure card is faced down at position
    if (!isFaceDown) {
      flipInstant();
    }

    // Set at deck position
    position = CardDeck.getDeckCardPosition();
    isVisible = true;
  }

  Future<void> drawNonEventCardAnimation(Vector2 cardEndLocation) async {
    // Start at deck pile
    startAtDeckSetting();

    // Start moving and then flip
    double moveToCenterDuration = 0.4;
    moveTo(
      game.gameManager.rotationCenter,
      EffectController(duration: moveToCenterDuration),
    );
    flip(duration: moveToCenterDuration);

    // Wait to let player see for a bit
    await Future.delayed(
      Duration(milliseconds: (2000 + moveToCenterDuration * 1000).toInt()),
    );

    // Go to end location (should be new location of card)
    await moveTo(cardEndLocation, EffectController(duration: 0.3));

    // Mark draw animation as resolved to unblock
    drawAnimation.resolve();
  }

  // Starts the draw animation from deck to center until user clicks
  // TODO: update this function so it works with handEventAction cards (taking sendTo vector position, and going there otherwise going to discard)
  Future<void> drawEventCardAnimation({required bool isInfinite}) async {
    // Start at the deck
    startAtDeckSetting();

    // Events need to be clickable for humans to close it
    setClickable(true);

    // Human will go infinitely until player clicks, ai auto clicks after period
    final scaleController =
        isInfinite
            ? EffectController(
              duration: 0.7,
              reverseDuration: 0.5,
              curve: Curves.easeInOut,
              infinite: true,
            )
            : EffectController(
              duration: 0.7,
              reverseDuration: 0.5,
              curve: Curves.easeInOut,
              repeatCount: 3,
            );

    // Move the card to center screen then pulsate until clicked or remove for AI automatically
    _onDrawEffect = SequenceEffect(
      [
        MoveEffect.to(
          game.gameManager.rotationCenter,
          EffectController(duration: .4),
        ),
        ScaleEffect.by(Vector2.all(1.5), EffectController(duration: .5)),
        ScaleEffect.by(Vector2.all(1.1), scaleController),
      ],
      onComplete: () async {
        // NOTE: This onComplete only runs on if scaleController not infinite
        // Otherwise waiting onTapUp to resolve the function - this onComplete won't be called

        // Set border back to black
        setBorderColor(Card.cardBorderColor);

        // set back to unclickable
        setClickable(false);
        drawAnimation.resolve();
      },
    );

    // Flip the card up as it's coming from deck
    await flip(duration: 0.3);

    // Run the draw effect
    add(_onDrawEffect!);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!isDraggable) return;
    dragEndReturnEffect();
  }
}

//Base Number Card Class
class NumberCard extends Card {
  late final double _value;
  late final TextComponent _tlText, _trText, _blText, _brText, _cText;
  bool componentInitialized = false;
  Vector2? dragOffset;

  NumberCard({required double value})
    : super(cardType: CardType.numberCard, totalCardSize: Card.cardSize) {
    _value = value;
  }

  double get value => _value;
  set value(double value) => _value = value;

  // void _removeText() {
  //   if (componentInitialized) {
  //     removeAll([_tlText, _trText, _blText, _brText, _cText]);
  //     componentInitialized = false;
  //   }
  // }

  @override
  Future<void> buildFront(RoundedBorderComponent container) async {
    TextPaint small = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
    TextPaint big = TextPaint(
      style: TextStyle(
        color: Colors.black,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );

    bool isInt = _value % 1 == 0;
    String textvalue;
    if (isInt) {
      textvalue = _value.toInt().toString();
    } else {
      textvalue = _value.toString();
    }

    _tlText = TextComponent(
      text: textvalue,
      position: Vector2(Card.cardSize.x * .15, Card.cardSize.y * .1),
      size: Vector2(Card.cardSize.x * .2, Card.cardSize.x * .2),
      anchor: Anchor.center,
      angle: angle,
      textRenderer: small,
    );
    _trText = TextComponent(
      text: textvalue,
      position: Vector2(Card.cardSize.x * .85, Card.cardSize.y * .1),
      size: Vector2(Card.cardSize.x * .2, Card.cardSize.x * .2),
      anchor: Anchor.center,
      angle: angle,
      textRenderer: small,
    );
    _blText = TextComponent(
      text: textvalue,
      position: Vector2(Card.cardSize.x * .15, Card.cardSize.y * .9),
      size: Vector2(Card.cardSize.x * .2, Card.cardSize.x * .2),
      anchor: Anchor.center,
      angle: math.pi,
      textRenderer: small,
    );
    _brText = TextComponent(
      text: textvalue,
      position: Vector2(Card.cardSize.x * .85, Card.cardSize.y * .9),
      size: Vector2(Card.cardSize.x * .2, Card.cardSize.x * .2),
      anchor: Anchor.center,
      angle: math.pi,
      textRenderer: small,
    );
    _cText = TextComponent(
      text: textvalue,
      position: Vector2(Card.cardSize.x * .5, Card.cardSize.y * .5),
      size: Vector2(Card.cardSize.x * .4, Card.cardSize.y * .4),
      anchor: Anchor.center,
      angle: 0,
      textRenderer: big,
    );

    container.addAll([_tlText, _trText, _blText, _brText, _cText]);
  }

  @override
  Future<void> executeOnEvent() async {}

  @override
  void description() {
    print("${cardType.label} ${_value}");
  }

  @override
  double executeOnStay(double currentValue) {
    currentValue += _value;
    return currentValue;
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    // paint = Paint()..color = Colors.white;
    // fillColor = Colors.white;
    // _loadCardComponent(faceUp: true, firstPersonView: true);
  }

  // @override
  // void onDragStart(DragStartEvent event) {
  //   super.onDragStart(event);
  //   if (!dragEnabled) return;
  //   // paint.color = Colors.red;
  //   fillColor = Colors.red;
  // }

  // @override
  // void onDragUpdate(DragUpdateEvent event) {
  //   super.onDragUpdate(event);
  //   if (!dragEnabled) return;
  //   position += event.localDelta;
  // }

  // @override
  // void onDragEnd(DragEndEvent event) {
  //   super.onDragEnd(event);
  //   if (!isDraggable) return;
  //   // fillColor = Colors.white;
  //   dragEndReturnEffect();
  // }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!isClickable || onTapDownSelector == null) return;
    onTapDownSelector!(this);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (!isClickable || onTapUpSelector == null) return;
    onTapUpSelector!(this);
  }

  @override
  String toString() {
    return "Number Card $_value";
  }
}

//Event Action Card Class
abstract class EventActionCard extends Card {
  //Card User is the player who has the card
  Player? cardUser;
  //Affected player (if applicable) is the player that is affected by the card.
  //Example: Player 1 gets the flip 3 card, so they are the card user.
  //They choose Player 2 to be forced to flip 3 cards. Hence player 2 is the affected player.
  Player? affectedPlayer;

  late final TextComponent _descripTitle;
  late final WrappingTextBox _descrip;
  late final CircularImageComponent _eventIcon;
  late final RoundedBorderComponent _bodyDescriptionBorder;

  late final String imagePath;
  late final String descripText;
  late final String descripTitleText;

  EventActionCard({
    required this.imagePath,
    required this.descripText,
    required this.descripTitleText,
  }) : super(cardType: CardType.eventActionCard, totalCardSize: Card.cardSize) {
    _bodyDescripPos = Vector2(Card.cardSize.x * .1, Card.cardSize.y * .37);
    _bodyDescripSize = Vector2(Card.cardSize.x * .8, Card.cardSize.y * .60);
    // x is top and bottom padding y is left, right
    _bodyDescripPadding = Vector2(7, 5);
  }

  @override
  Future<void> buildFront(RoundedBorderComponent container) async {
    _descripTitle = TextComponent(
      text: descripTitleText,
      position: Vector2(
        Card.halfCardSize.x,
        _bodyDescripPos.y + _bodyDescripPadding.x,
      ),
      size: Vector2(_bodyDescripSize.x, _bodyDescripSize.y * .2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.black,
          fontSize: 7.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    _descrip = WrappingTextBox(
      text: descripText,
      textStyle: const TextStyle(fontSize: 7, color: Colors.black),
      boxSize: Vector2(
        _bodyDescripSize.x - _bodyDescripPadding.y * 2,
        Card.cardSize.y * .45 - _descripTitle.size.y,
      ),
      position: Vector2(
        Card.halfCardSize.x,
        _descripTitle.position.y + _descripTitle.size.y + .5,
      ),
      anchor: Anchor.topCenter,
    );

    _eventIcon = CircularImageComponent(
      imagePath: imagePath,
      radius: Card.cardSize.x * .25,
      borderColor: Colors.black,
      borderWidth: 2.0,
    )..position = Vector2(Card.halfCardSize.x, Card.cardSize.y * .17);

    _bodyDescriptionBorder = RoundedBorderComponent(
      position: _bodyDescripPos,
      size: _bodyDescripSize,
      borderWidth: 1.5,
      borderColor: Colors.black,
      borderRadius: 5.0,
    );

    container.addAll([
      _descripTitle,
      _descrip,
      _eventIcon,
      _bodyDescriptionBorder,
    ]);
  }

  FutureOr<void> onLoad() async {
    super.onLoad();
    // size = Card.cardSize;
    // fillColor = Colors.white;
    // _bodyDescriptionBorder = RoundedBorderComponent(
    //   position: _bodyDescripPos,
    //   size: _bodyDescripSize,
    //   borderWidth: 1.5,
    //   borderColor: Colors.black,
    //   borderRadius: 5.0,
    // );
    // add(_bodyDescriptionBorder);
  }

  @override
  double executeOnStay(double currentValue) {
    print("Check which event action cards have executions on player stay");
    return currentValue;
  }

  // @override
  // void onDragEnd(DragEndEvent event) {
  //   super.onDragEnd(event);
  //   if (!isDraggable) return;
  //   // fillColor = Colors.white;
  //   dragEndReturnEffect();
  // }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    print(
      "ON TAP DOWN can click: $isClickable | card user: $cardUser | ontapUp: $onTapDownSelector",
    );
    if (!isClickable) return;
    if (_onDrawEffect != null && cardUser != null) {
      // Show a highlight on tap down
      // setBorderColor(Colors.blue);
      setGlowing(true);
    }
    if (onTapDownSelector != null) {
      onTapDownSelector!(this);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    print(
      "ON TAP UP can click: $isClickable | card user: $cardUser | ontapUp: $onTapUpSelector",
    );
    if (!isClickable) return;
    // If draw effect running, and user clicked on it remove the effect and mark user as clicked by resolving
    if (_onDrawEffect != null && cardUser != null && !cardUser!.isCpu()) {
      print("COMPLETEING DRAW EFFECT");
      setGlowing(false);
      setClickable(false);

      // Remove components and draw effect
      _onDrawEffect!.removeFromParent();
      _onDrawEffect = null;

      // Mark draw animation as resolved to unblock
      drawAnimation.resolve();
    }
    if (onTapUpSelector != null) {
      onTapUpSelector!(this);
    }
  }

  //Method for initiating player selection process
  // Once player has been selected, the running event's affectedPlayer will have the reference to the selected player
  Future<void> choosePlayer({bool Function(Player?)? buttonClickVerf}) async {
    print("Choose a player to be affected by eventAction card:");
    // Wait for user to select input
    // We expect input to be set when this is resolved
    game.gameManager.makePlayersClickable(buttonClickVerf);
    game.gameManager.runningEvent!.inputSelect.init();
    await game.gameManager.runningEvent!.inputSelect.wait();
    print("The player has been chosen!");
  }

  void resolveEventCompleter() {
    if (game.gameManager.runningEvent != null) {
      game.gameManager.runningEvent!.eventCompleted.resolve();
    }
  }

  //Method for finishing event completer
  void finishEventCompleter() {
    //Resolve event completer
    resolveEventCompleter();

    //Make buttons unclickale
    game.gameManager.makePlayersUnclickable();
  }

  @override
  Future<void> executeOnEvent() async {}

  // @override
  // bool get debugMode => true;
}

// Extension of event - same thing, but gets added to hand instantly unlike regular event cards
abstract class HandEventActionCard extends EventActionCard {
  HandEventActionCard({
    required super.imagePath,
    required super.descripText,
    required super.descripTitleText,
  });
}

abstract class TaxHandEventActionCard extends HandEventActionCard {
  TaxHandEventActionCard({
    required super.imagePath,
    required super.descripText,
    required super.descripTitleText,
  });
  double playerTaxRate({required Player currentPlayer});
}

//Value Action Abstract Card:
abstract class ValueActionCard extends Card {
  late final double _value;

  late final ValueActionTitleText
  _titleText; // The +, -, x for the type of value action
  late final TextComponent _descripTitle;
  late final WrappingTextBox _descrip;
  late final RoundedBorderComponent _bodyDescriptionBorder;

  late final String actionText;
  late final String descripText;
  late final String descripTitleText;

  ValueActionCard({
    required double value,
    required super.cardType,
    required this.actionText,
    required this.descripText,
    required this.descripTitleText,
  }) : super(totalCardSize: Card.cardSize) {
    _value = value;
    _bodyDescripPos = Vector2(Card.cardSize.x * .1, Card.cardSize.y * .5);
    _bodyDescripSize = Vector2(Card.cardSize.x * .8, Card.cardSize.y * .47);
    // x is top and bottom padding y is left, right
    _bodyDescripPadding = Vector2(7, 5);
  }

  double get value => _value;

  @override
  Future<void> buildFront(RoundedBorderComponent container) async {
    _descripTitle = TextComponent(
      text: descripTitleText,
      position: Vector2(
        Card.halfCardSize.x,
        _bodyDescripPos.y + _bodyDescripPadding.x,
      ),
      size: Vector2(_bodyDescripSize.x, _bodyDescripSize.y * .2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.black,
          fontSize: 7.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    _descrip = WrappingTextBox(
      text: descripText,
      textStyle: const TextStyle(fontSize: 7, color: Colors.black),
      boxSize: Vector2(
        _bodyDescripSize.x - _bodyDescripPadding.y * 2,
        Card.cardSize.y * .45 - _descripTitle.size.y,
      ),
      position: Vector2(
        Card.halfCardSize.x,
        _descripTitle.position.y + _descripTitle.size.y + .5,
      ),
      anchor: Anchor.topCenter,
    );

    _bodyDescriptionBorder = RoundedBorderComponent(
      position: _bodyDescripPos,
      size: _bodyDescripSize,
      borderWidth: 1.5,
      borderColor: Colors.black,
      borderRadius: 5.0,
    );

    String valueString = doubleToStringNoTrailingZeros(_value, 5);
    _titleText = ValueActionTitleText(
      valueTypeText: actionText,
      numberTitleText: valueString,
    );
    container.add(_titleText);

    // TODO: Check that you can set center before adding it to container?
    final center = _titleText.getCenterSize();
    _titleText.position =
        Vector2(Card.halfCardSize.x, Card.cardSize.y * .3) - center;

    container.addAll([_descripTitle, _descrip, _bodyDescriptionBorder]);
  }

  void initDescriptionText({
    String descriptionTitle = "",
    String description = "",
  }) {
    _descripTitle = TextComponent(
      text: descriptionTitle,
      position: Vector2(
        Card.halfCardSize.x,
        _bodyDescripPos.y + _bodyDescripPadding.x,
      ),
      size: Vector2(_bodyDescripSize.x, _bodyDescripSize.y * .2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.black,
          fontSize: 7.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    _descrip = WrappingTextBox(
      text: description,
      textStyle: const TextStyle(fontSize: 7, color: Colors.black),
      boxSize: Vector2(
        _bodyDescripSize.x - _bodyDescripPadding.y * 2,
        Card.cardSize.y * .45 - _descripTitle.size.y,
      ),
      position: Vector2(
        Card.halfCardSize.x,
        _descripTitle.position.y + _descripTitle.size.y + .5,
      ),
      anchor: Anchor.topCenter,
    );

    addAll([_descripTitle, _descrip]);
  }

  void initTitleText(String valueAction) {
    String valueString = doubleToStringNoTrailingZeros(_value, 5);
    _titleText = ValueActionTitleText(
      valueTypeText: valueAction,
      numberTitleText: valueString,
    );
    add(_titleText);
    final center = _titleText.getCenterSize();
    _titleText.position =
        Vector2(Card.halfCardSize.x, Card.cardSize.y * .3) - center;
  }

  @override
  Future<void> executeOnEvent() async {}

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    // size = Card.cardSize;
    // fillColor = Colors.white;
    // _bodyDescriptionBorder = RoundedBorderComponent(
    //   position: _bodyDescripPos,
    //   size: _bodyDescripSize,
    //   borderWidth: 1.5,
    //   borderColor: Colors.black,
    //   borderRadius: 5.0,
    // );
    // add(_bodyDescriptionBorder);
  }

  // @override
  // void onDragStart(DragStartEvent event) {
  //   super.onDragStart(event);
  //   if (!dragEnabled) return;
  //   fillColor = Colors.red;
  // }

  // @override
  // void onDragUpdate(DragUpdateEvent event) {
  //   super.onDragUpdate(event);
  //   if (!dragEnabled) return;
  //   position += event.localDelta;
  // }

  // @override
  // void onDragEnd(DragEndEvent event) {
  //   super.onDragEnd(event);
  //   if (!isDraggable) return;
  //   // fillColor = Colors.white;
  //   dragEndReturnEffect();
  // }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!isClickable) return;
    if (onTapDownSelector != null) {
      onTapDownSelector!(this);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (!isClickable) return;
    if (onTapUpSelector != null) {
      onTapUpSelector!(this);
    }
  }
}
