import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:six_seven/data/enums/player_rotation.dart';

class SpinningArrowRing extends SvgComponent {
  PlayerRotation rotationDirection;
  double rotationSpeed; // radians per second;
  late final Svg cwSvg;
  late final Svg ccwSvg;

  SpinningArrowRing({
    this.rotationSpeed = 0.3,
    this.rotationDirection = PlayerRotation.clockWise,
    super.size,
    super.position,
  }) : super(anchor: Anchor.center, priority: -10);

  bool isClockwise() => rotationDirection == PlayerRotation.clockWise;

  String _getRotationString(PlayerRotation rotDir) {
    return rotDir == PlayerRotation.clockWise
        ? 'images/game_ui/rotation_arrows_cw.svg'
        : 'images/game_ui/rotation_arrows_ccw.svg';
  }

  void setRotation({PlayerRotation rotDir = PlayerRotation.clockWise}) {
    if (rotDir == PlayerRotation.clockWise) {
      svg = cwSvg;
    } else {
      svg = ccwSvg;
    }
    rotationDirection = rotDir;
  }

  @override
  Future<void> onLoad() async {
    cwSvg = await Svg.load(_getRotationString(PlayerRotation.clockWise));
    ccwSvg = await Svg.load(
      _getRotationString(PlayerRotation.counterClockWise),
    );

    print("ROTATION DIRECTION $rotationDirection");

    // Sets the svg to current spin orientation
    setRotation(rotDir: rotationDirection);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final direction = isClockwise() ? 1 : -1;
    angle += (direction) * rotationSpeed * dt;
  }
}
