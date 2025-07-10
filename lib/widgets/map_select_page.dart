import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapSelectPage extends StatefulWidget {
  const MapSelectPage({super.key});

  @override
  State<MapSelectPage> createState() => _MapSelectPageState();
}

class _MapSelectPageState extends State<MapSelectPage> {
  LatLng? pickupLocation;
  LatLng? dropoffLocation;

  String? fromText;
  String? toText;

  bool useMap = true; // εναλλαγή μεταξύ Map / Manual

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
    if (useMap) {
      if (pickupLocation != null && dropoffLocation != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Route created from map.")),
        );
        // TODO: Save or send locations
      }
    } else {
      if (fromText?.isNotEmpty == true && toText?.isNotEmpty == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Manual route: $fromText → $toText")),
        );
        // TODO: Geocode addresses & show on map
      }
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

    final lines = <Polyline>[
      if (pickupLocation != null && dropoffLocation != null)
        Polyline(
          points: [pickupLocation!, dropoffLocation!],
          strokeWidth: 4.0,
          color: Colors.deepPurple,
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pickup & Drop-off"),
      ),
      body: Column(
        children: [
          ToggleButtons(
            isSelected: [useMap, !useMap],
            onPressed: (index) {
              setState(() => useMap = (index == 0));
            },
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
                      PolylineLayer(polylines: lines),
                      MarkerLayer(markers: markers),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            labelText: 'From Address',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (val) => fromText = val,
                        ),
                        const SizedBox(height: 12),
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
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _continue,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Continue"),
            ),
          )
        ],
      ),
    );
  }
}
