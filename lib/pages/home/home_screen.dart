import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:six_seven/widgets/home/buttons.dart';

class HomeScreenContainer extends StatelessWidget {
  const HomeScreenContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  "My Game",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40.h),

                // Buttons in center
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100.w,
                        height: 100.h,
                        child: ElevatedHomeButton(
                          onPressed: () {},
                          title: "Play",
                        ),
                      ),

                      SizedBox(height: 30.h),

                      SizedBox(
                        width: 100.w,
                        height: 100.h,
                        child: ElevatedHomeButton(
                          onPressed: () {},
                          title: "Settings",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
