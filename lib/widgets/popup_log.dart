import 'package:flutter/material.dart';

enum QuickAction { scanBarcode, selectWorkout }

Future<QuickAction?> showQuickActionModal(BuildContext context) {
  return showModalBottomSheet<QuickAction>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: const Text('Scan Barcode'),
            onTap: () => Navigator.of(context).pop(QuickAction.scanBarcode),
          ),
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Select Workout'),
            onTap: () => Navigator.of(context).pop(QuickAction.selectWorkout),
          ),
        ],
      ),
    ),
  );
}