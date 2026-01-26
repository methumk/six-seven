//Return file path for die for face with red dots
String getRedDiePath({required int numDots, required int version}) {
  return 'assets/images/game_ui/dice_${numDots}_red_dots_${version}.svg';
}

//Return file path for die for face with white dots
String getWhiteDiePath({required int numDots, required int version}) {
  return 'assets/images/game_ui/dice_${numDots}_white_dots_${version}.svg';
}
