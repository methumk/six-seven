import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class TopHud extends HudMarginComponent {
  Iterable<Component>? hudItems;
  EdgeInsets? hudMargin;
  Anchor? hudAnchor;

  TopHud({
    required this.hudItems,
    required this.hudMargin,
    required this.hudAnchor,
  }) : super(
         margin: hudMargin,
         anchor: hudAnchor,
         children: [RowComponent(gap: 10, children: hudItems)],
       );

  @override
  bool get debugMode => true;
}
