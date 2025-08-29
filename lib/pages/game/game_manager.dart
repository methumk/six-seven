import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flutter/widgets.dart';
import 'package:six_seven/components/ui/card_ui.dart';
import 'package:six_seven/pages/game/game_screen.dart';

class GameManager extends Component with HasGameReference<GameScreen> {
  final List<NumberCardUI> testNumbers = [];
  int currentCard = 0;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    // NOTE: these don't resize when game screen size changes
    final count = game.setupSettings.totalPlayerCount;
    for (int i = 0; i < count; ++i) {
      if (i == 0)
        testNumbers.add(NumberCardUI(pos: Vector2(200, 0)));
      else if (i == 1)
        testNumbers.add(NumberCardUI(pos: Vector2(0, 200)));
      else if (i == 2)
        testNumbers.add(NumberCardUI(pos: Vector2(-200, 0)));
      else if (i == 3)
        testNumbers.add(NumberCardUI(pos: Vector2(0, -200)));
    }

    final downButtonImg = await Flame.images.load("game_ui/button_down.png");
    final upButtonImg = await Flame.images.load("game_ui/button_up.png");

    game.world.addAll(testNumbers);

    final button = SpriteButtonComponent(
      button: Sprite(upButtonImg, srcSize: Vector2(60, 18)),
      buttonDown: Sprite(downButtonImg, srcSize: Vector2(60, 20)),
      size: Vector2(120, 36),
      onPressed: () {
        testNumbers[currentCard].onButtonTestUnClick();
        currentCard = ++currentCard % testNumbers.length;
        print("Button pressed! $currentCard");
        testNumbers[currentCard].onButtonTestClick();
      },
    );

    // For HUD look at maybe adding it to camera.viewport instead of just add
    game.camera.viewport.add(
      HudMarginComponent(
        margin: EdgeInsets.only(bottom: 5, left: 7, top: 5, right: 7),
        children: [button],
      ),
    );
  }
}
