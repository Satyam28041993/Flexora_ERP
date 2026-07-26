/// Central place for Firestore collection paths so no screen ever hardcodes
/// a collection name inline (Doc/Flexora-Master-Requirements-v1.2.md, Section 0A —
/// "no screen wired directly to a random Firestore collection").
class FirestorePaths {
  static const String orders = 'orders';

  static String orderLineItems(String orderId) => 'orders/$orderId/line_items';
}

/// Placeholder until the Plant/Multi-plant master module is designed.
/// Single plant in production today (Doc Section 1) — kept as a named constant,
/// not scattered string literals, so switching to a real Plant Master later is a
/// one-place change.
class DefaultPlant {
  static const String id = 'pgpl-vasai';
}
