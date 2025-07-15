import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart' as http;
/// Fetches calories per serving via the OpenFoodFacts API.
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<int?> fetchCaloriesForBarcode(String code) async {
  final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$code.json');
  final resp = await http.get(url);
  if (resp.statusCode != 200) return null;

  final jsonBody = jsonDecode(resp.body) as Map<String, dynamic>;
  final product = jsonBody['product'] as Map<String, dynamic>?;
  final nutriments = product?['nutriments'] as Map<String, dynamic>?;
  if (nutriments == null) return null;

  final perServing = nutriments['energy-kcal_serving'] as num?;
  if (perServing != null) {
    return perServing.round();
  }

  final servingSize = product?['serving_size'] as String?;
  if (servingSize != null) {
    final match = RegExp(r'([\d.]+)\s*g', caseSensitive: false).firstMatch(servingSize);
    if (match != null) {
      final grams = double.tryParse(match.group(1)!);
      final energyPer100g = nutriments['energy-kcal_100g'] as num?;
      if (grams != null && energyPer100g != null) {
        return (energyPer100g * grams / 100).round();
      }
    }
  }

  final energy100 = nutriments['energy-kcal_100g'] as num?;
  return energy100?.round();
}


class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController _scannerController =
  MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    setState(() => _isProcessing = true);
    final calories = await fetchCaloriesForBarcode(code);
    if (calories == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food data not found')),
      );
      setState(() => _isProcessing = false);
    } else {
      Navigator.of(context).pop(calories);
    }
  }


  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
