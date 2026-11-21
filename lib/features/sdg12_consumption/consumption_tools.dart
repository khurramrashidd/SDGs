/// SDG 12 decision logic: reading the nutrition table on a packet.
///
/// Packaged snacks, biscuits, namkeen and drinks are now everyday food in
/// small towns, and the front of the packet says "healthy", "multigrain" or
/// "no added sugar" while the back says otherwise. The tool reads the back.
///
/// Thresholds are the UK's traffic-light values per 100 g of food, used
/// here because they are public, simple and widely used, and because India
/// has not yet put an equivalent on packets. They are a guide to compare
/// two products, not a medical limit. Drinks use different values, so the
/// tool is for foods only and says so.
library;

enum Nutrient { fat, saturates, sugars, salt }

enum Level { low, medium, high }

class Band {
  /// At or below this is low.
  final double lowMax;

  /// Above this is high.
  final double highOver;
  const Band(this.lowMax, this.highOver);
}

/// Grams per 100 g. Source: NHS, "Food labels".
const bands = {
  Nutrient.fat: Band(3.0, 17.5),
  Nutrient.saturates: Band(1.5, 5.0),
  Nutrient.sugars: Band(5.0, 22.5),
  Nutrient.salt: Band(0.3, 1.5),
};

const nhsSource = 'https://www.nhs.uk/live-well/eat-well/food-labelling-terms/';

Level levelOf(Nutrient n, double gramsPer100g) {
  final b = bands[n]!;
  if (gramsPer100g <= b.lowMax) return Level.low;
  if (gramsPer100g > b.highOver) return Level.high;
  return Level.medium;
}

/// Indian labels often give sodium in milligrams instead of salt in grams.
/// Salt = sodium x 2.5.
double saltFromSodiumMg(double sodiumMg) => sodiumMg / 1000 * 2.5;

/// Values are sometimes printed per serving only. Scale to 100 g so they
/// can be compared; null when the serving size is missing or zero.
double? per100g(double perServing, double servingGrams) =>
    servingGrams <= 0 ? null : perServing * 100 / servingGrams;
