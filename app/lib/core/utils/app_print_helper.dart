import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';

/// Cross-platform print helper using printing package.
/// Works cleanly across Web, Windows Desktop, Linux, macOS, Android, and iOS.
class AppPrintHelper {
  /// Triggers PDF preview and print dialog cleanly on all supported platforms.
  static Future<void> printPdfBytes({
    required Uint8List pdfBytes,
    required String documentName,
  }) async {
    try {
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: documentName,
      );
    } catch (e) {
      debugPrint('Print error for $documentName: $e');
    }
  }
}

/// Legacy fallback function alias for backwards compatibility.
void printCurrentWebPage() {
  debugPrint('printCurrentWebPage called - use AppPrintHelper.printPdfBytes for document printing');
}
