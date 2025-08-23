import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'
    show ScreenUtil, SizeExtension;
import 'package:six_seven/pages/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Screen Utility
  await ScreenUtil.ensureScreenSize();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    ProviderScope(
      child: MaterialApp(
        builder: (ctx, child) {
          ScreenUtil.init(ctx);
          // NOTE: Can define common theme with font sizes for a unified approach
          return Theme(
            data: ThemeData(
              primaryColor: Colors.black,
              textTheme: TextTheme(
                titleLarge: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 30.sp,
                ),
              ),
            ),
            child: child!,
          );
        },
        home: const HomeScreenContainer(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
