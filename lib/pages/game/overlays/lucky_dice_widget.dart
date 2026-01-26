import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:six_seven/components/players/cpu_player.dart';
import 'package:six_seven/utils/dice_helper.dart';

class LuckyDieWidget extends StatefulWidget {
  final double startSize;
  final double endSize;
  final Duration dropDuration;
  final Duration wobbleDuration;
  final bool isAi;
  final Difficulty aiDifficulty;

  const LuckyDieWidget({
    super.key,
    this.startSize = 200,
    this.endSize = 80,
    this.dropDuration = const Duration(seconds: 1),
    this.wobbleDuration = const Duration(milliseconds: 600),
    this.isAi = false,
    this.aiDifficulty = Difficulty.medium,
  });

  @override
  State<LuckyDieWidget> createState() => _LuckyDieWidgetState();
}

class _LuckyDieWidgetState extends State<LuckyDieWidget>
    with TickerProviderStateMixin {
  late AnimationController _dropController;
  late Animation<double> _sizeAnimation;
  Timer? _timer;
  int _currentFace = 0;
  int _totalScore = 0;
  late int _finalValue;
  bool _isRolling = false;
  bool _aiShowLeaving = false;
  final Random _random = Random();

  // history slots: length 6, null means placeholder (gray)
  static const _historySlotLength = 7;
  final List<int?> _historySlots = List<int?>.filled(
    _historySlotLength,
    null,
    growable: false,
  );

  // Per-slot wobble controllers/animations while they animate (keyed by slot index)
  final Map<int, AnimationController> _slotControllers = {};
  final Map<int, Animation<double>> _slotAnimations = {};

  @override
  void dispose() {
    if (_timer != null && _timer!.isActive) {
      _timer?.cancel();
    }
    _timer = null;

    _dropController.stop();
    _dropController.dispose();

    // dispose any remaining slot controllers
    for (final c in _slotControllers.values) {
      try {
        c.stop();
        c.dispose();
      } catch (e) {
        debugPrint("Got error disposing $c - $e");
      }
    }

    _slotControllers.clear();
    _slotAnimations.clear();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Animation controller for size
    _dropController = AnimationController(
      vsync: this,
      duration: widget.dropDuration,
    );

    _sizeAnimation = Tween<double>(
      begin: widget.startSize,
      end: widget.endSize,
    ).animate(CurvedAnimation(parent: _dropController, curve: Curves.easeIn));

    if (widget.isAi) {
      // Only launch simulate ai Turn after it's mounted
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _simulateAiTurn();
      });
    }
  }

  Future<void> _simulateAiTurn() async {
    while (mounted) {
      while (_isRolling) {
        // Stay in this loop until rolling has finished
        await Future.delayed(Duration(milliseconds: 500));
      }

      // Think delay
      await Future.delayed(Duration(milliseconds: 1500 + _random.nextInt(100)));

      // If max rolls completed, redeem points
      if (_historySlots.indexWhere((v) => v == null) == -1) {
        if (mounted) {
          // Toggle the redeem button
          setState(() => _aiShowLeaving = true);
          await Future.delayed(Duration(milliseconds: 500));
          Navigator.of(context).pop(_totalScore);
          return;
        }
      }

      // Ai makes a decision
      // hard or expert continues to roll if its total roll points exceeds the expected value of
      // rolling seven times, else it stops. For other difficulties, they decide their choice based on
      // just probability: easy (rolls 50%), medium (85%)
      bool aiWantsToRoll =
          widget.aiDifficulty == Difficulty.easy
              ? _random.nextDouble() < 0.50
              : widget.aiDifficulty == Difficulty.medium
              ? _random.nextDouble() < 0.50
              : (_totalScore >= 7 * evRoll() ? false : true);

      if (aiWantsToRoll) {
        await _startRoll();
      } else {
        if (mounted) {
          // Toggle the redeem button
          setState(() => _aiShowLeaving = true);
          await Future.delayed(Duration(milliseconds: 500));
          Navigator.of(context).pop(_totalScore);
          return;
        }
      }
    }
  }

  //Calculates expected value of a single roll
  double evRoll() {
    return 6 * 5 / 7 - 7 * 2 / 7;
  }

  Future<void> _startRoll() async {
    if (_isRolling) return;
    setState(() => _isRolling = true);

    // pick a final face 1..7
    _finalValue = _random.nextInt(7) + 1;
    debugPrint("FINAL VALUE $_finalValue");

    // reset drop animation and start showing random faces during drop
    _dropController.reset();
    // Create a completer to await the end of the timer logic
    final completer = Completer<void>();

    // _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      if (_dropController.isCompleted) {
        t.cancel();
        setState(() {
          _currentFace = _finalValue;
          _totalScore += (_finalValue >= 6 ? -7 : 6);
        });

        // Insert into history and run wobble there
        _placeIntoHistoryAndWobble(_finalValue);
        completer.complete();
      } else {
        setState(() {
          _currentFace = _random.nextInt(7) + 1;
        });
      }
    });
    // Await the animation
    await _dropController.forward();

    // Wait for the timer logic to complete
    await completer.future;

    if (mounted) {
      // rolling finished
      setState(() => _isRolling = false);
    }
  }

  // Find first null slot, or shift-left and append if full.
  // Then create a wobble controller for that slot and start it.
  void _placeIntoHistoryAndWobble(int face) {
    // find first null
    int slotIndex = _historySlots.indexWhere((v) => v == null);

    if (slotIndex == -1) {
      // all full: shift left and free last slot
      // dispose controller for slot 0 if it's animating
      if (_slotControllers.containsKey(0)) {
        try {
          _slotControllers[0]!.dispose();
        } catch (_) {}
        _slotControllers.remove(0);
        _slotAnimations.remove(0);
      }
      for (int i = 0; i < _historySlots.length - 1; i++) {
        _historySlots[i] = _historySlots[i + 1];
      }
      _historySlots[_historySlots.length - 1] = null;

      // shift controllers keys down by 1
      final newControllers = <int, AnimationController>{};
      final newAnimations = <int, Animation<double>>{};
      _slotControllers.forEach((oldIndex, ctrl) {
        if (oldIndex == 0) return; // already removed
        final newIndex = oldIndex - 1;
        newControllers[newIndex] = ctrl;
        newAnimations[newIndex] = _slotAnimations[oldIndex]!;
      });
      _slotControllers
        ..clear()
        ..addAll(newControllers);
      _slotAnimations
        ..clear()
        ..addAll(newAnimations);

      slotIndex = _historySlots.length - 1; // last index now free
    }

    // put face into history slot (so it visually replaces the gray)
    setState(() {
      _historySlots[slotIndex] = face;
    });

    // create wobble animation for ONLY this slot
    final controller = AnimationController(
      vsync: this,
      duration: widget.wobbleDuration,
    );

    final animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.25), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: -0.15), weight: 35),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.0), weight: 25),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    // store them so build() can animate the specific slot
    _slotControllers[slotIndex] = controller;
    _slotAnimations[slotIndex] = animation;

    // run wobble; after it completes, dispose the controller and remove from maps
    controller.forward().whenComplete(() {
      // small delay to ensure final frame painted
      Future.delayed(const Duration(milliseconds: 10), () {
        // dispose and remove controller/animation for this slot
        if (mounted) {
          setState(() {
            try {
              controller.dispose();
            } catch (_) {}
            _slotControllers.remove(slotIndex);
            _slotAnimations.remove(slotIndex);
          });
        } else {
          try {
            controller.dispose();
          } catch (_) {}
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.isAi,
      child: SizedBox(
        width: 490,
        height: 210,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: Center(child: Text("Points Earned: $_totalScore")),
            ),
            Expanded(
              flex: 3,
              child: Center(
                child: AnimatedBuilder(
                  animation: _sizeAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      width: _sizeAnimation.value,
                      height: _sizeAnimation.value,
                      child:
                          _currentFace < 6
                              ? SvgPicture.asset(
                                getWhiteDiePath(
                                  numDots: 6,
                                  version: _currentFace,
                                ),
                              )
                              : SvgPicture.asset(
                                getRedDiePath(
                                  numDots: 7,
                                  version: _currentFace % 5,
                                ),
                              ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: FittedBox(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_historySlots.length, (i) {
                      final val = _historySlots[i];
                      Widget child;
                      if (val == null) {
                        // placeholder gray
                        child = SvgPicture.asset(
                          'assets/images/game_ui/dice_gray.svg',
                          width: 28,
                        );
                      } else {
                        // if this slot is currently animating, wrap with rotation animation
                        if (_slotAnimations.containsKey(i) &&
                            _slotControllers.containsKey(i)) {
                          child = AnimatedBuilder(
                            animation: _slotAnimations[i]!,
                            builder: (context, w) {
                              return Transform.rotate(
                                angle: _slotAnimations[i]!.value,
                                child:
                                    val < 6
                                        ? SvgPicture.asset(
                                          getWhiteDiePath(
                                            numDots: 6,
                                            version: val,
                                          ),
                                          width: 28,
                                        )
                                        : SvgPicture.asset(
                                          getRedDiePath(
                                            numDots: 7,
                                            version: val % 5,
                                          ),
                                          width: 28,
                                        ),
                              );
                            },
                          );
                        } else {
                          // static final face
                          child =
                              val < 6
                                  ? SvgPicture.asset(
                                    getWhiteDiePath(numDots: 6, version: val),
                                    width: 28,
                                  )
                                  : SvgPicture.asset(
                                    getRedDiePath(numDots: 7, version: val % 5),
                                    width: 28,
                                  );
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: child,
                      );
                    }),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: ElevatedButton(
                          onPressed:
                              _aiShowLeaving
                                  ? null
                                  : () {
                                    if (!_isRolling) {
                                      Navigator.of(context).pop(_totalScore);
                                    }
                                  },
                          child: Text(
                            'Redeem',
                            style: TextStyle(
                              color: widget.isAi ? Colors.green : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ElevatedButton(
                          onPressed:
                              (_isRolling ||
                                      (_historySlots.indexWhere(
                                            (v) => v == null,
                                          ) ==
                                          -1))
                                  ? null
                                  : _startRoll,
                          child: Text(
                            'Roll',
                            style: TextStyle(
                              color: widget.isAi ? Colors.green : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
