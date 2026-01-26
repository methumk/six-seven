import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/components/card_helpers/glow_component.dart';
import 'package:six_seven/components/rounded_border_component.dart';

/// CardComponent with movement, flipping, tap, drag functionalities
class CardComponent extends PositionComponent
    with DragCallbacks, TapCallbacks, HoverCallbacks, HasVisibility {
  final Vector2 totalCardSize;
  final double borderWidth;
  final Color borderColor;
  final double borderRadius;
  final Color? frontFillColor;
  final Color? backFillColor;
  final Color glowColor;
  final int glowLayers;

  late RoundedBorderComponent frontFace;
  late RoundedBorderComponent backFace;
  late PositionComponent _backContent; // Container to un-flip back content
  late GlowComponent _glowComponent;

  bool _isFlipped = false;
  double _flipProgress = 0.0; // 0 = front visible, 1 = back visible
  bool _isFlipping = false;

  Vector2? _dragOffset;
  bool _isClickable = true;
  bool _isDraggable = true;
  bool _isGlowing = false;
  bool _animateGlow = false;

  CardComponent({
    required this.totalCardSize,
    Vector2? position,
    this.borderWidth = 2.5,
    this.borderColor = Colors.white,
    this.borderRadius = 5.0,
    this.frontFillColor = const Color.fromARGB(255, 196, 209, 229),
    this.backFillColor = const Color.fromARGB(255, 34, 91, 176),
    this.glowColor = Colors.yellow,
    this.glowLayers = 3,
    bool isClickable = false,
    bool isDraggable = false,
    bool isGlowing = false,
    bool animateGlow = true,
    bool faceUp = false,
    bool showCard = true,
    super.priority = 1,
  }) : _isClickable = isClickable,
       _isDraggable = isDraggable,
       _isGlowing = isGlowing,
       _animateGlow = animateGlow,
       _isFlipped = !faceUp,
       _flipProgress = faceUp ? 0.0 : 1.0 {
    this.position = position ?? Vector2.zero();
    size = totalCardSize;
    isVisible = showCard;
  }

  @override
  FutureOr<void> onLoad() async {
    // Create glow effect (rendered first, so it's behind everything)
    _glowComponent = GlowComponent(
      cardSize: totalCardSize,
      glowColor: glowColor,
      borderRadius: borderRadius,
      glowLayers: glowLayers,
      animate: _animateGlow,
    );
    _glowComponent.isVisible = _isGlowing;
    add(_glowComponent);

    // Create front face
    frontFace = RoundedBorderComponent(
      size: totalCardSize,
      borderWidth: borderWidth,
      borderColor: borderColor,
      borderRadius: borderRadius,
      fillColor: frontFillColor,
    );

    // Create back face (flipped horizontally)
    backFace = RoundedBorderComponent(
      size: totalCardSize,
      borderWidth: borderWidth,
      borderColor: borderColor,
      borderRadius: borderRadius,
      fillColor: backFillColor,
    );
    backFace.scale.x = -1; // Flip the background

    // Create content container that counter-flips to show content normally
    _backContent = PositionComponent(
      size: totalCardSize,
      position: Vector2(totalCardSize.x, 0), // Position at right edge
    );
    _backContent.scale.x = -1; // Counter-flip so content appears normal
    backFace.add(_backContent);

    // Add faces (back first, so front renders on top initially)
    add(backFace);
    add(frontFace);

    // Build custom content (override these methods in subclasses)
    await buildFront(frontFace);
    await buildBack(
      _backContent,
    ); // Add to content container, not backFace directly

    // Set initial visibility based on starting face
    _updateFlipTransform();
  }

  /// Override this method to add components to the front face
  /// Add components directly to the frontFace container
  Future<void> buildFront(RoundedBorderComponent container) async {
    // Default implementation - add nothing
    // Subclasses should override this
  }

  /// Override this method to add components to the back face
  /// Add components directly to the container - they will appear normally (not mirrored)
  Future<void> buildBack(PositionComponent container) async {
    // Default implementation - add nothing
    // Subclasses should override this
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isFlipping) {
      _updateFlipTransform();
    }
  }

  void _updateFlipTransform() {
    // Calculate skew based on flip progress
    // At 0.5 (90 degrees), the card is edge-on
    final angle = _flipProgress * math.pi; // 0 to PI radians
    final skewX = math.cos(angle); // 1 to -1

    // Scale X based on viewing angle
    final scaleX = skewX.abs();

    // Update glow
    _glowComponent.scale.x = scaleX;

    // Update front face
    frontFace.scale.x = scaleX;

    // Update back face (remember it starts flipped)
    backFace.scale.x = -scaleX;

    // Adjust position to keep card centered during flip
    final offset = (totalCardSize.x - totalCardSize.x * scaleX) / 2;
    _glowComponent.position.x = offset;
    frontFace.position.x = offset;
    backFace.position.x = totalCardSize.x - offset;

    _updateVisibility();
  }

  void _updateVisibility() {
    // Switch visibility at 50% flip
    final showFront = _flipProgress < 0.5;

    frontFace.isVisible = showFront;
    backFace.isVisible = !showFront;
  }

  /// Flip the card with animation
  /// If duration <= 0 it will flip instantly
  /// You can run this function async or not, flip instant doesn't require an await
  Future<void> flip({double duration = 0.6}) async {
    if (_isFlipping) return;

    if (duration <= 0.0) {
      flipInstant();
    } else {
      _isFlipping = true;
      final targetProgress = _isFlipped ? 0.0 : 1.0;
      final startProgress = _flipProgress;
      final delta = targetProgress - startProgress;

      final completer = Completer<void>();

      // Create animator component
      final animator = _FlipAnimator(
        duration: duration,
        startProgress: startProgress,
        delta: delta,
        onUpdate: (progress) {
          _flipProgress = progress;
        },
        onComplete: () {
          _flipProgress = targetProgress;
          _isFlipped = !_isFlipped;
          _isFlipping = false;
          completer.complete();
        },
      );

      add(animator);

      await completer.future;
      animator.removeFromParent();
    }
  }

  //Flip up
  Future<void> flipUp({double duration = 0.6}) async {
    if (isFaceDown) {
      await flip(duration: duration);
    }
  }

  //Flip down
  Future<void> flipDown({double duration = 0.6}) async {
    if (!isFaceDown) {
      await flip(duration: duration);
    }
  }

  /// Instantly flip without animation
  void flipInstant() {
    _isFlipped = !_isFlipped;
    _flipProgress = _isFlipped ? 1.0 : 0.0;
    _updateFlipTransform();
  }

  // Moves to a target
  Future<void> moveTo(Vector2 target, EffectController effectController) async {
    final completer = Completer<void>();

    final effect = MoveEffect.to(
      target,
      effectController,
      onComplete: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    add(effect);
    await completer.future;
    effect.removeFromParent();
  }

  // Moves from current position based on the moveOffset
  Future<void> moveBy(
    Vector2 moveOffset,
    EffectController effectController,
  ) async {
    final completer = Completer<void>();

    final effect = MoveEffect.by(
      moveOffset,
      effectController,
      onComplete: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    add(effect);
    await completer.future;
    effect.removeFromParent();
  }

  // Scales to an absolute value of the card's scale
  Future<void> scaleTo(Vector2 scale, EffectController effectController) async {
    final completer = Completer<void>();

    final effect = ScaleEffect.to(
      scale,
      effectController,
      onComplete: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    add(effect);
    await completer.future;
    effect.removeFromParent();
  }

  // Scales the card by it's current scale
  Future<void> scaleBy(Vector2 scale, EffectController effectController) async {
    final completer = Completer<void>();

    final me = ScaleEffect.by(
      scale,
      effectController,
      onComplete: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    add(me);
    await completer.future;
    me.removeFromParent();
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_isDraggable) {
      _dragOffset = event.localPosition;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_isDraggable && _dragOffset != null) {
      position += event.localDelta;
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _dragOffset = null;
  }

  /// Enable or disable dragging
  void setDraggable(bool draggable) {
    _isDraggable = draggable;
    if (!draggable) {
      _dragOffset = null; // Cancel any ongoing drag
    }
  }

  void setClickable(bool clickable) {
    _isClickable = clickable;
  }

  void setVisibility(bool visible) {
    isVisible = visible;
  }

  /// Enable or disable glow effect
  void setGlowing(bool glowing) {
    _isGlowing = glowing;
    _glowComponent.isVisible = true; // Keep visible during transition
    _glowComponent.startTransition(glowing);
  }

  /// Enable or disable glow animation
  void setAnimateGlow(bool animate) {
    _animateGlow = animate;
    _glowComponent.animate = animate;
  }

  bool get isClickable => _isClickable;
  bool get isDraggable => _isDraggable;
  bool get isGlowing => _isGlowing;
  bool get animateGlow => _animateGlow;
  bool get isFaceDown => _isFlipped;
  bool get isFlipping => _isFlipping;
}

/// Helper component for flip animation
class _FlipAnimator extends Component {
  final double duration;
  final double startProgress;
  final double delta;
  final void Function(double) onUpdate;
  final void Function() onComplete;

  double _elapsed = 0.0;

  _FlipAnimator({
    required this.duration,
    required this.startProgress,
    required this.delta,
    required this.onUpdate,
    required this.onComplete,
  });

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;
    final t = (_elapsed / duration).clamp(0.0, 1.0);

    // Ease in-out curve
    final curvedT = t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 2) / 2;

    onUpdate(startProgress + delta * curvedT);

    if (t >= 1.0) {
      onComplete();
    }
  }
}
