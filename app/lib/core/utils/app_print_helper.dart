import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Helper to trigger browser native print / Save as PDF modal in Flutter Web.
void printCurrentWebPage() {
  if (kIsWeb) {
    try {
      html.window.print();
    } catch (e) {
      debugPrint('Print error: $e');
    }
  }
}
