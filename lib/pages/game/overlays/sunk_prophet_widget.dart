import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:six_seven/components/players/cpu_player.dart';

class SunkProphetWidget extends StatefulWidget {
  final double startSize;
  final double endSize;
  final Duration dropDuration;
  final Duration wobbleDuration;
  final bool isAi;
  final Difficulty aiDifficulty;
  const SunkProphetWidget({
    super.key,
    this.startSize = 200,
    this.endSize = 80,
    this.dropDuration = const Duration(seconds: 1),
    this.wobbleDuration = const Duration(milliseconds: 600),
    this.isAi = false,
    this.aiDifficulty = Difficulty.medium,
  });

  @override
  State<SunkProphetWidget> createState() => _SunkProphetWidgetState();
}

class _SunkProphetWidgetState extends State<SunkProphetWidget>
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
  //Bool for if player rolled a six or seven
  bool sixOrSevenRolled = false;

  //Bool for if player finished a roll
  bool _finishedARoll = true;
  //Int for number of rolls player has made: when player rolls 7 failures, they
  //will automatically quit
  int numRolls = 0;
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
      // Sunk prophet forces AI to roll until they roll a 6 or 7. Hence they are forced to roll
      //until this happens, or they rolled seven times in a roll with no 6 or 7.
      bool aiWantsToRoll = sixOrSevenRolled ? false : true;

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
    return -6 * 5 / 7 + 7 * 2 / 7;
  }

  Future<void> _startRoll() async {
    if (_isRolling) return;
    //Increment number of rolls by 1
    numRolls += 1;
    setState(() {
      _finishedARoll = true;
      _isRolling = true;
    });

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
          int pointsFromRoll = 0;
          if (_finalValue == 6 || _finalValue == 7) {
            pointsFromRoll = 7;
            sixOrSevenRolled = true;
          } else {
            pointsFromRoll = -6;
          }
          _totalScore += 1 * pointsFromRoll;
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

      setState(() => _finishedARoll = true);
    }
    // _dropController.forward().whenComplete(() {
    //   if (mounted) {
    //     // rolling finished
    //     setState(() => _isRolling = false);
    //     setState(() => _finishedARoll = true);
    //   }
    // });
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
                                'assets/images/game_ui/dice_${6}_red_dots_${_currentFace}.svg',
                              )
                              : SvgPicture.asset(
                                'assets/images/game_ui/dice_${7}_white_dots_${_currentFace % 5}.svg',
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
                                          'assets/images/game_ui/dice_${6}_red_dots_${val}.svg',
                                          width: 28,
                                        )
                                        : SvgPicture.asset(
                                          'assets/images/game_ui/dice_${7}_white_dots_${val % 5}.svg',
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
                                    'assets/images/game_ui/dice_${6}_red_dots_${val}.svg',
                                    width: 28,
                                  )
                                  : SvgPicture.asset(
                                    'assets/images/game_ui/dice_${7}_white_dot_${val % 5}.svg',
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
                              (!_aiShowLeaving &&
                                      !sixOrSevenRolled &&
                                      numRolls < 7 &&
                                      _finishedARoll)
                                  ? null
                                  : () {
                                    if (!_isRolling) {
                                      Navigator.of(context).pop(_totalScore);
                                    }
                                  },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.resolveWith<
                              Color
                            >((Set<WidgetState> states) {
                              if (states.contains(WidgetState.disabled)) {
                                return Colors.grey.shade400;
                              }
                              return widget.isAi ? Colors.green : Colors.black;
                            }),
                            foregroundColor:
                                WidgetStateProperty.resolveWith<Color>((
                                  Set<WidgetState> states,
                                ) {
                                  if (states.contains(WidgetState.disabled)) {
                                    return Colors.black45;
                                  }
                                  return Colors.white;
                                }),
                          ),
                          child: const Text('Redeem'),
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
