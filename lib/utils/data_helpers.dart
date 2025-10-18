import 'dart:math' as math;

double truncateToDecimals(double value, int fractionalDigits) {
  double mod = math.pow(10.0, fractionalDigits).toDouble();
  return (value * mod).truncate() / mod;
}

// Will truncate a given double value  to the number of decimal places needed and return the number of digits in the double
int numDigitsInDouble(double value, {int truncateNumDecimals = 0}) {
  double truncated = truncateToDecimals(value, truncateNumDecimals);
  String str = truncated.toString();
  List<String> parts = str.split('.');

  int beforeDecimal = parts[0].length;
  int afterDecimal = parts.length > 1 ? parts[1].length : 0;

  return beforeDecimal + afterDecimal;
}

int numCharsInDouble(double value, {int truncateNumDecimals = 0}) {
  double truncated = truncateToDecimals(value, truncateNumDecimals);
  return truncated.toString().length;
}

// This will round to the safeZone place, so ensure this value doesn't effect your number
String doubleToStringNoTrailingZeros(double value, int safeZone) {
  // Use fixed precision, then strip trailing zeros and decimal if unnecessary
  return value.toStringAsFixed(safeZone).replaceFirst(RegExp(r'\.?0+$'), '');
}

// Digits is number of decimal digits we want, so digits = 2 is hundreths place
String roundAndStringify(double value, {int digits = 2}) {
  // Round to the 10ths place
  double roundedValue =
      (value * math.pow(10, digits)).roundToDouble() / math.pow(10, digits);

  // Convert to string and remove trailing zeros
  return roundedValue
      .toStringAsFixed(digits)
      .replaceAll(RegExp(r'(\.0+$|(?<=\.\d)0+$)'), '');
}

double roundDouble(double value, int places) {
  double mod = math.pow(10.0, places).toDouble();
  return ((value * mod).round().toDouble() / mod);
}
