// TODO
// The actual flame game
import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:six_seven/components/ui/card_ui.dart';
import 'package:six_seven/data/game_setup_settings.dart';

class GameScreen extends FlameGame with TapCallbacks, DragCallbacks {
  late final GameSetupSettings setupSettings;
  late final NumberCardUI testNumber;

  GameScreen({required this.setupSettings});

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    testNumber = NumberCardUI();
    world.add(testNumber);
  }
}
