import 'package:flutter/material.dart';

class ClothesAddressDialog extends StatefulWidget {
  const ClothesAddressDialog({super.key});

  @override
  State<ClothesAddressDialog> createState() => _ClothesAddressDialogState();
}

class _ClothesAddressDialogState extends State<ClothesAddressDialog> {
  String? fromAddress;
  String? toAddress;

  final List<String> addresses = [
    'Home',
    'Work',
    'Friend\'s Place',
    'Other...',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Pickup & Dropoff'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'From'),
            value: fromAddress,
            items: addresses
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => fromAddress = val),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'To'),
            value: toAddress,
            items: addresses
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) => setState(() => toAddress = val),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Job: From $fromAddress to $toAddress'),
              ),
            );
            // TODO: Submit or continue to job creation flow
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
