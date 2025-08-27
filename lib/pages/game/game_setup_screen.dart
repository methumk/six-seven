import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:six_seven/data/constants/game_setup_settings_constants.dart';
import 'package:six_seven/notifiers/game_setup_setting_notifier.dart';
import 'package:six_seven/widgets/home/buttons.dart';
import 'package:six_seven/widgets/settings/single_slider.dart';
import 'package:six_seven/widgets/settings/switch.dart';

class GameSetupScreen extends ConsumerStatefulWidget {
  const GameSetupScreen({super.key});

  @override
  ConsumerState<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends ConsumerState<GameSetupScreen> {
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(gameSetupSettingProvider);
    final dataNotifier = ref.read(gameSetupSettingProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top row with two equal panels
            Expanded(
              child: Row(
                children: [
                  // Left panel
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Player Options",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Scrollable settings
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SingleSlider(
                                    settingName: "Total Players (including AI)",
                                    isInt: true,
                                    minRange:
                                        GameSetupSettingsConstants
                                            .totalPlayerCountMin
                                            .toDouble(),
                                    maxRange:
                                        GameSetupSettingsConstants
                                            .totalPlayerCountMax
                                            .toDouble(),
                                    startValue:
                                        GameSetupSettingsConstants
                                            .defTotalPlayerCount
                                            .toDouble(),
                                    onChanged:
                                        (value) =>
                                            dataNotifier.updateTotalPlayerCount(
                                              value.toInt(),
                                            ),
                                  ),
                                  SingleSlider(
                                    settingName: "Total AI Players",
                                    isInt: true,
                                    minRange:
                                        GameSetupSettingsConstants
                                            .aiPlayerCountMin
                                            .toDouble(),
                                    maxRange:
                                        data.totalPlayerCount.toDouble() - 1,
                                    startValue:
                                        GameSetupSettingsConstants
                                            .defAiPlayerCount
                                            .toDouble(),
                                    onChanged:
                                        (value) => dataNotifier
                                            .updateAiPlayerCount(value.toInt()),
                                  ),
                                  SingleSlider(
                                    settingName: "AI Difficulty",
                                    isInt: true,
                                    isEnabled: data.aiPlayerCount != 0,
                                    minRange:
                                        GameSetupSettingsConstants
                                            .aiDifficultyMin
                                            .toDouble(),
                                    maxRange:
                                        GameSetupSettingsConstants
                                            .aiDifficultyMax
                                            .toDouble(),
                                    startValue:
                                        GameSetupSettingsConstants
                                            .defAiDifficulty
                                            .toDouble(),
                                    onChanged:
                                        (value) => dataNotifier
                                            .updateAiDifficulty(value.toInt()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right panel
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Game Options",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SwitchSetting(
                                    settingName: "Show Deck Distribution",
                                    switchValue:
                                        GameSetupSettingsConstants
                                            .defShowDeckDistribution,
                                    enableColor: Colors.red,
                                    onChanged:
                                        (value) => dataNotifier
                                            .updateShowDeckDistribution(value),
                                  ),
                                  SwitchSetting(
                                    settingName: "Show Failure Probability",
                                    switchValue:
                                        GameSetupSettingsConstants
                                            .defShowDeckDistribution,
                                    enableColor: Colors.red,
                                    onChanged: (value) {},
                                  ),
                                  SingleSlider(
                                    settingName: "Winning Score",
                                    minRange:
                                        GameSetupSettingsConstants
                                            .winningScoreMin
                                            .toDouble(),
                                    maxRange:
                                        GameSetupSettingsConstants
                                            .winningScoreMax
                                            .toDouble(),
                                    startValue:
                                        GameSetupSettingsConstants
                                            .defWinningScore
                                            .toDouble(),
                                    onChanged:
                                        (value) => dataNotifier
                                            .updateWinningScore(value),
                                  ),
                                  SwitchSetting(
                                    settingName: "Show other Player's Cards",
                                    switchValue:
                                        GameSetupSettingsConstants
                                            .defShowOtherPlayersHand,
                                    enableColor: Colors.red,
                                    onChanged:
                                        (value) => dataNotifier
                                            .updateShowOtherPlayersHand(value),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Start button at bottom
            Padding(
              padding: const EdgeInsets.all(30),
              child: ElevatedHomeButton(
                onPressed: () {},
                title: "Start",
                fontSize: 10.5.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _GameSetupScreenState extends ConsumerState<GameSetupScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             children: [
//               // Top row with 2 containers
//               Expanded(
//                 child: Row(
//                   children: [
//                     // Left container
//                     Expanded(
//                       child: Container(
//                         color: Colors.blue.shade50,
//                         child: SingleChildScrollView(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             children: const [
//                               Text("Left Setting 1"),
//                               SizedBox(height: 10),
//                               Text("Left Setting 2"),
//                               SizedBox(height: 10),
//                               Text("Left Setting 3"),
//                               // add as many fixed settings as you want
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),

//                     // Right container
//                     Expanded(
//                       child: Container(
//                         color: Colors.green.shade50,
//                         child: SingleChildScrollView(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             children: const [
//                               Text("Right Setting 1"),
//                               Text("Right Setting 1"),
//                               SizedBox(height: 10),
//                               // add as many fixed settings as you want
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Start button at the bottom
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Start game action
//                     },
//                     child: const Text("Start"),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _GameSetupScreenState extends ConsumerState<GameSetupScreen> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final data = ref.watch(gameSetupSettingProvider);
//     final dataNotifier = ref.read(gameSetupSettingProvider.notifier);

//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Left Data
//                   // NOTE: Remove debug container
//                   Expanded(
//                     child: DebugContainer(
//                       child: Container(
//                         margin: EdgeInsets.all(5),
//                         padding: EdgeInsets.all(5),
//                         child: Column(children: []),
//                       ),
//                     ),
//                   ),

//                   // Right Data
//                   // NOTE: Remove debug container
//                   Expanded(
//                     child: SingleChildScrollView(
//                       padding: EdgeInsets.all(5),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Container(child: Text("Game Options")),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                           Text("TEXT 1"),
//                         ],
//                       ),
//                     ),
//                     // child: DebugContainer(
//                     //   child: Container(
//                     //     margin: EdgeInsets.all(5),
//                     //     padding: EdgeInsets.all(5),
//                     //     child: SingleChildScrollView(
//                     //       padding: EdgeInsets.all(5),
//                     //       child: Column(
//                     //         crossAxisAlignment: CrossAxisAlignment.center,
//                     //         children: [
//                     //           Container(child: Text("Game Options")),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //           Text("TEXT 1"),
//                     //         ],
//                     //       ),
//                     //     ),
//                     //   ),
//                     // ),
//                   ),
//                 ],
//               ),
//               ElevatedHomeButton(
//                 onPressed: () {},
//                 title: "Start",
//                 fontSize: 10.5.sp,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
