import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../features/order_intake/data/models/order_model.dart';
import '../utils/po_document_parser.dart';

/// Gemini AI PO Document Intelligence Engine.
///
/// Sends uploaded Purchase Order PDF / Image documents directly to Google Gemini 2.0 Flash / 1.5 Flash API
/// to dynamically parse ANY client PO layout (Aries Agro, Isha Agro, Savannah, Benchmark, Propix, or any new customer format)
/// into a structured JSON response.
class GeminiPOService {
  static String? userApiKey;

  static bool get hasKey => userApiKey != null && userApiKey!.trim().isNotEmpty;

  /// Send document bytes to Gemini Vision API for dynamic JSON PO extraction.
  static Future<ParsedPOData?> extractPOWithGemini({
    required Uint8List fileBytes,
    required String fileName,
    required String mimeType,
  }) async {
    if (!hasKey) return null;

    final apiKey = userApiKey!.trim();
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');

    final base64Data = base64Encode(fileBytes);

    final promptText = '''
You are an expert flexographic label printing Purchase Order OCR parser.
Analyze this Purchase Order document or SAP ERP Table Screenshot image and extract ALL line items present (support up to 50 line items per PO). Do NOT omit, truncate, or skip any line items.

Notes for SAP / ERP Table Screenshots:
- "poNumber" / "Purchasing Doc.": Look for "Purchasing Doc.", "Pur. Doc.", or "PO No." (e.g., "5400094026", "5400093969").
- "poDate" / "Doc. Date": Look for "Doc. Date" (e.g., "31.07.2026", "29.07.2026").
- "itemName" / "Short Text": Look for "Short Text" or "Material Description" (e.g., "STICK LABEL ROLL TAFGOR-250ML", "STICKER LABEL ROLLS REEVA 5").
- "quantityPcs" / "PO Quantity": Look for "PO Quantity" or "Quantity" (e.g., 50000, 15000, 20000).
- "unitRateRs" / "Net Price": Look for "Net Price" or "Rate" (e.g., 1.58, 1.22, 2.15, 1.64, 4.70, 3.50, 0.83, 1.98).
- "customerName": Look for "Supplier/Supplying Plant" or Billing Party. If "PRAKRUTI GRAPHICS" is supplier, leave customerName or infer buyer.

Return a structured JSON object with:
- "poNumber": string
- "poDate": "YYYY-MM-DD"
- "customerName": string
- "customerGstNo": string
- "shippingAddress": string
- "specialNotes": string
- "oneTimePunchCost": number (default 0.0)
- "freightCharges": number (default 0.0)
- "lineItems": array of objects (extract up to 50 items if present):
    {
      "itemNo": number,
      "itemName": string,
      "labelDescription": string,
      "sizeWidthMm": number,
      "sizeHeightMm": number,
      "hsnCode": string (default "48211020"),
      "quantityPcs": number,
      "unitRateRs": number,
      "lineAmountRs": number
    }

Respond strictly in valid JSON format only, without markdown formatting or code fences.
''';

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': promptText},
                {
                  'inline_data': {
                    'mime_type': mimeType.contains('pdf') ? 'application/pdf' : mimeType,
                    'data': base64Data,
                  }
                }
              ]
            }
          ],
          'generationConfig': {
            'response_mime_type': 'application/json',
            'temperature': 0.1,
          }
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final candidates = body['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]['content']['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            String jsonText = parts[0]['text'] as String;
            jsonText = jsonText.replaceAll('```json', '').replaceAll('```', '').trim();

            final map = jsonDecode(jsonText) as Map<String, dynamic>;

            final rawItems = map['lineItems'] as List<dynamic>? ?? [];
            final items = rawItems.map((item) {
              final m = item as Map<String, dynamic>;
              final qty = (m['quantityPcs'] as num?)?.toDouble() ?? 0.0;
              final rate = (m['unitRateRs'] as num?)?.toDouble() ?? 0.0;
              final amt = (m['lineAmountRs'] as num?)?.toDouble() ?? (qty * rate);

              return OrderLineItemModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                itemNo: (m['itemNo'] as num?)?.toInt() ?? 1,
                itemName: m['itemName'] as String? ?? '',
                labelDescription: m['labelDescription'] as String? ?? '',
                sizeWidthMm: (m['sizeWidthMm'] as num?)?.toDouble() ?? 0.0,
                sizeHeightMm: (m['sizeHeightMm'] as num?)?.toDouble() ?? 0.0,
                hsnCode: m['hsnCode'] as String? ?? '48211020',
                quantityPcs: qty,
                unitRateRs: rate,
                lineAmountRs: amt,
              );
            }).toList();

            return ParsedPOData(
              poNumber: map['poNumber'] as String? ?? '',
              poDate: map['poDate'] != null ? DateTime.tryParse(map['poDate'] as String) ?? DateTime.now() : DateTime.now(),
              customerName: map['customerName'] as String? ?? '',
              customerGstNo: map['customerGstNo'] as String? ?? '',
              shippingAddress: map['shippingAddress'] as String? ?? '',
              specialNotes: map['specialNotes'] as String?,
              oneTimePunchCost: (map['oneTimePunchCost'] as num?)?.toDouble() ?? 0.0,
              freightCharges: (map['freightCharges'] as num?)?.toDouble() ?? 0.0,
              lineItems: items,
            );
          }
        }
      } else {
        debugPrint('Gemini API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Gemini Extraction Exception: $e');
    }

    return null;
  }
}
