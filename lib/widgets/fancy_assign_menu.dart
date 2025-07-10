import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:paradosis_flutter/widgets/select_address_popup.dart';

void showFancyAssignJobMenu(
  BuildContext context,
  GlobalKey buttonKey, {
  required Function(LatLng from, LatLng to, String amountTotal, String method) onClothesSelected,
}) {
  final overlay = Overlay.of(context);
  final renderBox = buttonKey.currentContext!.findRenderObject() as RenderBox;
  final offset = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;

  OverlayEntry? overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: offset.dy + size.height + 8,
      left: offset.dx,
      width: 280,
      child: Material(
        elevation: 10,
        color: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOption(context, icon: Icons.shopping_cart_sharp, text: "Super Market", onTap: () {
                _select(context, overlayEntry!, "supermarket", onClothesSelected);
              }),
              _buildOption(context, icon: Icons.receipt_long, text: "Pay a Bill", onTap: () {
                _select(context, overlayEntry!, "bills", onClothesSelected);
              }),
              _buildOption(context, icon: Icons.checkroom, text: "Buy Clothes", onTap: () {
                _select(context, overlayEntry!, "clothes", onClothesSelected);
              }),
              _buildOption(context, icon: Icons.grass, text: "Farmers Market", onTap: () {
                _select(context, overlayEntry!, "market", onClothesSelected);
              }),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
}

void _select(
  BuildContext context,
  OverlayEntry entry,
  String selection,
  Function(LatLng from, LatLng to, String amountTotal, String method) onClothesSelected,
) {
  entry.remove();

  if (selection == 'clothes') {
    showDialog(
      context: context,
      builder: (_) => const SelectAddressPopup(),
    ).then((result) {
      if (result != null && result['method'] == 'map') {
        final LatLng from = result['from'];
        final LatLng to = result['to'];
        final amountTotal = result['amountTotal'] ?? '0';
        final method = result['paymentMethod'] ?? 'cash';
        onClothesSelected(from, to, amountTotal, method);
      }
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected: $selection')),
    );
  }
}

Widget _buildOption(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );
}
