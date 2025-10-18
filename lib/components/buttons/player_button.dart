import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:six_seven/pages/game/game_screen.dart';

//class for player buttons that are clickable when a player needs to be chosen
class PlayerButton extends ButtonComponent with HasGameReference<GameScreen> {
  late final Vector2 pos;
  late final int playerNum;
  late final double radius;
  late void Function() onHit;
  late final bool isCPU;
  late CircleComponent physicalButton;
  //Bool for if button is clickable
  bool buttonIsClickable = false;
  PlayerButton({
    required this.pos,
    required this.playerNum,
    required this.radius,
    required this.onHit,
    required this.isCPU,
  }) : super(
         position: pos,
         size: Vector2.all(radius * 2),
         button: CircleComponent(
           radius: radius,
           paint: Paint()..color = const Color.fromARGB(0, 255, 255, 255),
           children: [
             TextComponent(
               text: "Player $playerNum",
               textRenderer: TextPaint(
                 style: TextStyle(
                   color: isCPU ? Colors.lightBlue : Colors.white,
                   fontSize: radius / 2,
                 ),
               ),
               anchor: Anchor.center,
               position: Vector2(radius, radius),
             ),
           ],
         ),
         onPressed: onHit,
       ) {
    physicalButton = super.button as CircleComponent;
  }
  //setter for buttonIsClickable
  set buttonClickStatus(bool buttonStatus) {
    buttonIsClickable = buttonStatus;
    physicalButton.paint =
        Paint()
          ..color =
              buttonIsClickable
                  ? const Color.fromARGB(255, 124, 0, 143)
                  : const Color.fromARGB(0, 255, 255, 255);
  }
}
