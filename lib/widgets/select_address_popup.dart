import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SelectAddressPopup extends StatefulWidget {
  const SelectAddressPopup({super.key});

  @override
  State<SelectAddressPopup> createState() => _SelectAddressPopupState();
}

class _SelectAddressPopupState extends State<SelectAddressPopup> {
  bool useMap = true;
  LatLng? pickupLocation;
  LatLng? dropoffLocation;
  String? fromText;
  String? toText;
  String? amountTotalText;
  String paymentMethod = 'cash'; // default value

  void _handleTap(LatLng latLng) {
    setState(() {
      if (pickupLocation == null) {
        pickupLocation = latLng;
      } else if (dropoffLocation == null) {
        dropoffLocation = latLng;
      } else {
        pickupLocation = latLng;
        dropoffLocation = null;
      }
    });
  }

  void _continue() {
    if (useMap && pickupLocation != null && dropoffLocation != null && amountTotalText?.isNotEmpty == true) {
      Navigator.pop(context, {
        'from': pickupLocation,
        'to': dropoffLocation,
        'method': 'map',
        'amountTotal': amountTotalText,
        'paymentMethod': paymentMethod,
      });
    } else if (!useMap && fromText?.isNotEmpty == true && toText?.isNotEmpty == true && amountTotalText?.isNotEmpty == true) {
      Navigator.pop(context, {
        'from': fromText,
        'to': toText,
        'method': 'manual',
        'amountTotal': amountTotalText,
        'paymentMethod': paymentMethod,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      if (pickupLocation != null)
        Marker(
          width: 40,
          height: 40,
          point: pickupLocation!,
          child: const Icon(Icons.location_on, color: Colors.green, size: 40),
        ),
      if (dropoffLocation != null)
        Marker(
          width: 40,
          height: 40,
          point: dropoffLocation!,
          child: const Icon(Icons.location_on, color: Colors.red, size: 40),
        ),
    ];

    final polylines = <Polyline>[
      if (pickupLocation != null && dropoffLocation != null)
        Polyline(
          points: [pickupLocation!, dropoffLocation!],
          strokeWidth: 4,
          color: Colors.deepPurple,
        ),
    ];

    return AlertDialog(
      title: const Text("Pickup & Drop-off"),
      content: SizedBox(
        width: 350,
        height: 420,
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [useMap, !useMap],
              onPressed: (index) => setState(() => useMap = index == 0),
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Select on Map"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Enter Address"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: useMap
                  ? FlutterMap(
                      options: MapOptions(
                        center: LatLng(37.9838, 23.7275),
                        zoom: 13.0,
                        onTap: (_, latLng) => _handleTap(latLng),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        PolylineLayer(polylines: polylines),
                        MarkerLayer(markers: markers),
                      ],
                    )
                  : Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'From Address',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) => fromText = val,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'To Address',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) => toText = val,
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Total Amount (€)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (val) => amountTotalText = val,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'card', child: Text('Card')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    paymentMethod = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _continue,
          child: const Text("Continue"),
        ),
      ],
    );
  }
}
