import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ElevatedHomeButton extends StatelessWidget {
  final String title;
  final void Function() onPressed;
  final Color textColor;
  final Color backgroundColor;
  late final double fontSize;
  late final double buttonRadius;

  ElevatedHomeButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.blueGrey,
    double? buttonRadius,
    double? fontSize,
  }) : buttonRadius = buttonRadius ?? 100.r,
       fontSize = fontSize ?? 15.sp;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100.r),
        ),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15.sp, color: Colors.white),
      ),
    );
  }
}
