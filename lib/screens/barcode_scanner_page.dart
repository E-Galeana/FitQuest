// barcode_scanner_page.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> fetchProductForBarcode(String code) async {
  final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$code.json');
  final resp = await http.get(url);
  if (resp.statusCode != 200) return null;

  final jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;
  final product = jsonBody['product'] as Map<String, dynamic>?;
  if (product == null) return null;

  // Get product name
  final name = product['product_name'] as String? ?? 'Unknown';
  final nutriments = product['nutriments'] as Map<String, dynamic>?;
  int? cal;
  if (nutriments != null) {
    final perServing = nutriments['energy-kcal_serving'] as num?;
    if (perServing != null) {
      cal = perServing.round();
    } else {
      final servingSize = product['serving_size'] as String?;
      if (servingSize != null) {
        final match = RegExp(r'([\d.]+)\\s*g', caseSensitive: false).firstMatch(servingSize);
        final grams = match != null ? double.tryParse(match.group(1)!) : null;
        final per100 = nutriments['energy-kcal_100g'] as num?;
        if (grams != null && per100 != null) {
          cal = (per100 * grams / 100).round();
        }
      }
      cal ??= (nutriments['energy-kcal_100g'] as num?)?.round();
    }
  }
  if (cal == null) return null;

  return {'name': name, 'calories': cal};
}

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController scannerController =
  MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  bool isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() => isProcessing = true);
    final product = await fetchProductForBarcode(code);
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food data not found')),
      );
      setState(() => isProcessing = false);
    } else {
      // Return name & calories
      Navigator.of(context).pop(product);
    }
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: Stack(
        children: [
          MobileScanner(
            controller: scannerController,
            onDetect: _onDetect,
          ),
          if (isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
