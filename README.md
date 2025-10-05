# six_seven

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



# Useful Info
## For wireless Debugging on android phone
- Turn developer mode on
- in Developer mode turn on wireless debugging
- Click pair device with pairing code
- In terminal do `adb pair <DEVICEIP>:<PORT>`
- If successful you should see it in `adb devices`
- If you don't see the devices try doing `adb connect <DEVICEIP>:<PORT>` and see if `adb devices` lists it
- Run flutter `flutter run`, should see app on phone

## Running
- Emulate a device or turn on developing on your phone
- Run `flutter pub get` to get the dependencies
- Run `flutter run` to view the application


## Developing
- lib is where all your code will be written
- lib/main.dart is the entry point into the code

- pubspec.yaml, you can include fonts, and I think other dependencies
- Dependencies goes under the dependencies section, copy the pub with it's version and pase it there e.g. (flutter_svg: ^1.1.6)
- run `flutter pub get` after making changes to it to get those changes

- If you include fonts in the pubspec.yaml, make sure to add them to the fonts dir