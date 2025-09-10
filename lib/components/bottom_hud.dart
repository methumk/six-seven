// import 'package:flame/components.dart';
// import 'package:flame/experimental.dart';
// import 'package:flame/input.dart';
// import 'package:flutter/material.dart';
// import 'package:six_seven/pages/game/game_screen.dart';

// class BottomHud extends HudMarginComponent with HasGameReference<GameScreen> {
//   late SpriteButtonComponent hit;
//   late SpriteButtonComponent stay;

//   BottomHud({
//     required Component leftButton,
//     required Component rightButton,
//     double marginBottom = 12,
//   }) : super(
//          anchor: Anchor.bottomCenter,
//          margin: EdgeInsets.only(bottom: marginBottom),
//          children: [
//            RowComponent(
//              gap: 0,
//              children: [
//                leftButton..position = Vector2(-600, 0), // left edge
//                rightButton..position = Vector2(600, 0), // right edge
//              ],
//            ),
//          ],
//        );

//   @override
//   bool get debugMode => true;
// }
