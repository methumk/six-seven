import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
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
  eventActionCard("Event Action Card with effect: ");

  final String label;
  const CardType(this.label);
}

//Base card class
abstract class Card extends RoundedBorderComponent
    with
        HasGameReference<GameScreen>,
        DragCallbacks,
        TapCallbacks,
        HoverCallbacks {
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

  late final CircularImageComponent _eventIcon;
  late final RoundedBorderComponent _bodyDescriptionBorder;
  late final WrappingTextBox _descrip;
  late final TextComponent _descripTitle;

  late final Vector2 _bodyDescripPos;
  late final Vector2 _bodyDescripSize;
  late final Vector2 _bodyDescripPadding;

  SequenceEffect? _onDrawEffect;
  bool get isDrawEffectRunning =>
      _onDrawEffect != null && _onDrawEffect!.isMounted;

  EventCompleter eventCompleted = EventCompleter();
  EventCompleter inputSelect = EventCompleter();
  EventCompleter drawAnimation = EventCompleter();

  // Control tapping and dragging
  bool tapUpEnabled = true;
  bool tapDownEnabled = true;
  bool dragEnabled = true;

  // Completer to determine which card was picked
  // Completer<Card>? onTap;
  void Function()? onTapUpSelector;
  void Function()? onTapDownSelector;

  Card({required this.cardType})
    : super(borderColor: Colors.black, borderWidth: 2.5, borderRadius: 5.0) {
    anchor = Anchor.bottomCenter;
    defaultBorderColor = Colors.black;
  }

  //TO DO: Add players as param inputs for executeOnEvent
  //once player classes have been constructed
  Future<void> executeOnEvent();
  double executeOnStay(double currentValue);
  void description();

  void toggleTap(bool toggle) {
    tapUpEnabled = toggle;
    tapDownEnabled = toggle;
  }

  void toggleDrag(bool toggle) {
    dragEnabled = toggle;
  }

  void toggleAllUserCardMovement(bool toggle) {
    toggleTap(toggle);
    toggleDrag(toggle);
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
  }

  void resetCardSettings() {
    resetSize();
    toggleAllUserCardMovement(true);
    setBorderColor(defaultBorderColor);
  }

  void dragEndReturnEffect() {
    if (deckReturnTo == null) return;

    dragEndMoveTo?.removeFromParent();
    dragEndMoveTo = MoveToEffect(
      deckReturnTo!,
      EffectController(duration: 0.3),
    );

    add(dragEndMoveTo!);
  }

  Future<void> peekAnimation() async {
    _onDrawEffect = SequenceEffect(
      [
        MoveEffect.by(Vector2(0, 110), EffectController(duration: .3)),
        ScaleEffect.by(Vector2.all(1.2), EffectController(duration: .5)),
        ScaleEffect.by(
          Vector2.all(1.1),
          EffectController(
            duration: 0.7,
            reverseDuration: 0.5,
            curve: Curves.easeInOut,
            repeatCount: 3,
          ),
        ),
      ],
      onComplete: () {
        // Set border back to black
        setBorderColor(Colors.black);

        // Remove components and draw effect
        _onDrawEffect!.removeFromParent();
        _onDrawEffect = null;
        removeFromParent();

        // Mark draw animation as resolved to unblock
        drawAnimation.resolve();
        //Reset card size
        resetSize();
      },
    );

    add(_onDrawEffect!);
  }

  Future<void> drawFromDeckAnimation({required bool isInfinite}) async {
    //The effect controller for the third parameter in tbe _onDrawEffect depends
    //on whether the cardUser is human or CPU. If human, it should repeat forever until onTapUp is registered,
    //else it repeates 3 times

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

    _onDrawEffect = SequenceEffect(
      [
        MoveEffect.by(Vector2(0, 110), EffectController(duration: .3)),
        ScaleEffect.by(Vector2.all(2.7), EffectController(duration: .5)),
        ScaleEffect.by(Vector2.all(1.1), scaleController),
      ],
      onComplete: () {
        // Set border back to black
        setBorderColor(Colors.black);

        // Remove components and draw effect
        _onDrawEffect!.removeFromParent();
        _onDrawEffect = null;
        removeFromParent();

        // Mark draw animation as resolved to unblock
        drawAnimation.resolve();
        //Reset card size
        resetSize();
      },
    );

    add(_onDrawEffect!);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!dragEnabled) return;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!dragEnabled) return;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!dragEnabled) return;
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!tapDownEnabled) return;
    if (onTapDownSelector != null) {
      onTapDownSelector!();
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (!tapUpEnabled) return;
    if (onTapUpSelector != null) {
      onTapUpSelector!();
    }
  }
}

//Base Number Card Class
class NumberCard extends Card {
  late final double _value;
  late final TextComponent _tlText, _trText, _blText, _brText, _cText;
  bool componentInitialized = false;
  Vector2? dragOffset;

  NumberCard({required double value}) : super(cardType: CardType.numberCard) {
    _value = value;
  }

  double get value => _value;
  set value(double value) => _value = value;

  void _removeText() {
    if (componentInitialized) {
      removeAll([_tlText, _trText, _blText, _brText, _cText]);
      componentInitialized = false;
    }
  }

  // NOTE: render manually not on load
  void _loadCardComponent({
    required bool firstPersonView,
    required bool faceUp,
  }) {
    _removeText();

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

    if (faceUp) {
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

      size = Card.cardSize;

      if (!firstPersonView) {
        size *= GameManager.thirdPersonScale.x;
        _tlText.scale.setFrom(GameManager.thirdPersonScale);
        _trText.scale.setFrom(GameManager.thirdPersonScale);
        _blText.scale.setFrom(GameManager.thirdPersonScale);
        _brText.scale.setFrom(GameManager.thirdPersonScale);
        _cText.scale.setFrom(GameManager.thirdPersonScale);
      }

      componentInitialized = true;
      addAll([_tlText, _trText, _blText, _brText, _cText]);
    }
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
    fillColor = Colors.white;
    _loadCardComponent(faceUp: true, firstPersonView: true);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!dragEnabled) return;
    // paint.color = Colors.red;
    fillColor = Colors.red;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!dragEnabled) return;
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!dragEnabled) return;
    fillColor = Colors.white;
    dragEndReturnEffect();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!tapDownEnabled) return;
    print("Tapping down");
    if (onTapDownSelector != null) {
      onTapDownSelector!();
    }
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
  late Player? affectedPlayer;

  EventActionCard() : super(cardType: CardType.eventActionCard) {
    _bodyDescripPos = Vector2(Card.cardSize.x * .1, Card.cardSize.y * .37);
    _bodyDescripSize = Vector2(Card.cardSize.x * .8, Card.cardSize.y * .60);
    // x is top and bottom padding y is left, right
    _bodyDescripPadding = Vector2(7, 5);
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

  Future<void> initCardIcon(String imagePath) async {
    _eventIcon = CircularImageComponent(
      imagePath: imagePath,
      radius: Card.cardSize.x * .25,
      borderColor: Colors.black,
      borderWidth: 2.0,
    )..position = Vector2(Card.halfCardSize.x, Card.cardSize.y * .17);
    await add(_eventIcon);
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    size = Card.cardSize;
    fillColor = Colors.white;
    _bodyDescriptionBorder = RoundedBorderComponent(
      position: _bodyDescripPos,
      size: _bodyDescripSize,
      borderWidth: 1.5,
      borderColor: Colors.black,
      borderRadius: 5.0,
    );
    add(_bodyDescriptionBorder);
  }

  @override
  double executeOnStay(double currentValue) {
    print("Check which event action cards have executions on player stay");
    return currentValue;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!dragEnabled) return;
    fillColor = Colors.red;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!dragEnabled) return;
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!dragEnabled) return;
    fillColor = Colors.white;
    dragEndReturnEffect();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!tapDownEnabled) return;
    if (_onDrawEffect != null) {
      // Show a highlight on tap down
      setBorderColor(Colors.blue);
    }
    if (onTapDownSelector != null) {
      onTapDownSelector!();
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    if (!tapUpEnabled) return;
    if (cardUser == null) return;
    // If draw effect running
    if (_onDrawEffect != null && !cardUser!.isCpu()) {
      // Set border back to black
      setBorderColor(Colors.black);

      // Remove components and draw effect
      _onDrawEffect!.removeFromParent();
      _onDrawEffect = null;
      removeFromParent();

      // Mark draw animation as resolved to unblock
      drawAnimation.resolve();
    }
    if (onTapUpSelector != null) {
      onTapUpSelector!();
    }
  }

  //Method for initiating player selection process
  Future<void> choosePlayer() async {
    print("Choose a player to be affected by eventAction card:");
    // Wait for user to select input
    // We expect input to be set when this is resolved
    game.gameManager.makePlayersClickable();
    game.gameManager.runningEvent!.inputSelect.init();
    await game.gameManager.runningEvent!.inputSelect.wait();
    print("The player has been chosen!");
    return;
  }

  void resolveEventCompleter() {
    if (game.gameManager.runningEvent != null) {
      if (game.gameManager.runningEvent!.eventCompleted != null) {
        game.gameManager.runningEvent!.eventCompleted.resolve();
      }
    }
  }

  //Method for finishing event completer
  void finishEventCompleter() {
    //Resolve event completer
    resolveEventCompleter();

    //Make buttons unclickale
    game.gameManager.makePlayersUnclickable();
    return;
  }

  @override
  Future<void> executeOnEvent() async {}

  // @override
  // bool get debugMode => true;
}

// Extension of event - same thing, but gets added to hand instantly unlike regular event cards
abstract class HandEventActionCard extends EventActionCard {}

//Value Action Abstract Card:
abstract class ValueActionCard extends Card {
  late final double _value;
  // late final WrappingTextBox _descrip;
  // late final TextComponent _descripTitle; // Description box
  late final ValueActionTitleText _titleText;
  // late final RoundedBorderComponent _bodyDescriptionBorder;

  // late final Vector2 _bodyDescripPos;
  // late final Vector2 _bodyDescripSize;
  // late final Vector2 _bodyDescripPadding;

  ValueActionCard({required double value})
    : super(cardType: CardType.valueActionCard) {
    _value = value;
    _bodyDescripPos = Vector2(Card.cardSize.x * .1, Card.cardSize.y * .5);
    _bodyDescripSize = Vector2(Card.cardSize.x * .8, Card.cardSize.y * .47);
    // x is top and bottom padding y is left, right
    _bodyDescripPadding = Vector2(7, 5);
  }

  double get value => _value;

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
    size = Card.cardSize;
    fillColor = Colors.white;
    _bodyDescriptionBorder = RoundedBorderComponent(
      position: _bodyDescripPos,
      size: _bodyDescripSize,
      borderWidth: 1.5,
      borderColor: Colors.black,
      borderRadius: 5.0,
    );
    add(_bodyDescriptionBorder);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!dragEnabled) return;
    fillColor = Colors.red;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (!dragEnabled) return;
    position += event.localDelta;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!dragEnabled) return;
    fillColor = Colors.white;
    dragEndReturnEffect();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!tapDownEnabled) return;
    print("Tapping down");
    if (onTapDownSelector != null) {
      onTapDownSelector!();
    }
  }
}
