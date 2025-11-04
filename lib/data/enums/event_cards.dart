enum EventCardEnum {
  ChoiceDraw("Choice Draw Card"),
  Cribber("Cribber Card"),
  DoubleChance("Double Chance Card"),
  FlipThree("Flip Three Card"),
  Forecaster("Forcaster Card"),
  Freeze("Freeze Card"),
  IncomeTax("Income Tax Card"),
  LuckyDie("Lucky Die Card"),
  MagnifyingGlass("Magnifying Glass Card"),
  ReverseTurn("Reverse Turn Card"),
  SalesTax("Sales Tax Card"),
  SunkProphet("Sunk Prophet Card"),
  Thief("Thief Card"),
  Discarder("Discarder Card"),
  Redeemer("Redeemer Card"),
  TopPeek("Top Peek Card"),
  None("Not Event Card");

  final String label;
  const EventCardEnum(this.label);
}
