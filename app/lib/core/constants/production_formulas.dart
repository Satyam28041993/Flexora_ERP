/// Shared production/RM conversion constants and formulas.
///
/// SINGLE SOURCE OF TRUTH — do not re-declare these numbers anywhere else.
///
/// Background: the legacy PGPL Excel workbooks use three different values for
/// the same physical constant (metre → inch):
///   * `Stock Managemaent.xlsx` → `Job usage` sheet  : 39.3    (588/589 rows)
///   * `Wastage Report` → `REQUIRED RMT` column      : 39.3    (27/28 rows)
///   * `Wastage Report` → `DISPATCH IN METER` column : 39.37   (28/28 rows)
/// Flexora standardises on the exact value 39.3701 (1 m = 39.3701 in).
/// Versus the legacy 39.3, measured wastage moves ~+1% relative
/// (14.86% → 15.01% across 589 historical jobs) — expected, not a defect.
class ProductionFormulas {
  ProductionFormulas._();

  /// Exact inches in one metre. 1 m = 39.3701 in.
  static const double inchesPerMetre = 39.3701;

  /// Gear teeth to repeat length in inches. One tooth = 1/8 inch.
  /// Excel equivalent: `Gear / 8`
  static double repeatInches(num gearTeethZ) =>
      gearTeethZ > 0 ? gearTeethZ / 8.0 : 0.0;

  /// Labels produced per running metre.
  /// Excel equivalent: `(39.3 * Ups) / (Gear / 8)` — now using the exact constant.
  static double labelsPerMetre({required num gearTeethZ, required num ups}) {
    final repeat = repeatInches(gearTeethZ);
    if (repeat <= 0 || ups <= 0) return 0.0;
    return (inchesPerMetre * ups) / repeat;
  }

  /// Running metres needed to produce [labelQty] labels.
  /// Excel equivalent (`Job usage`!L): `(OkQty * (Gear / 8)) / (39.3 * Ups)`
  ///
  /// Used for both Ok-Quantity RMT and Dispatch RMT — the Excel uses the same
  /// formula for each, only the quantity differs.
  static double rmtForLabelQty({
    required num labelQty,
    required num gearTeethZ,
    required num ups,
  }) {
    final lpm = labelsPerMetre(gearTeethZ: gearTeethZ, ups: ups);
    if (lpm <= 0) return 0.0;
    return labelQty / lpm;
  }

  /// Linear metres → square metres for a given web width.
  /// Excel equivalent: `(WebSizeMm * RMT) / 1000`
  static double sqMtr({required num webSizeMm, required num rmt}) =>
      (webSizeMm * rmt) / 1000.0;
}
