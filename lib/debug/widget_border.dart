// TESTING purposes
import 'package:flutter/material.dart';

BoxDecoration debugBorder({Color color = Colors.red, double width = 2}) {
  return BoxDecoration(border: Border.all(color: color, width: width));
}

class DebugContainer extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderWidth;
  final bool showBackground;
  final Color backgroundColor;

  const DebugContainer({
    super.key,
    required this.child,
    this.borderColor = Colors.red,
    this.borderWidth = 2.0,
    this.showBackground = false,
    this.backgroundColor = const Color(0x33FF0000), // semi-transparent
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: showBackground ? backgroundColor : null,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: child,
    );
  }
}
