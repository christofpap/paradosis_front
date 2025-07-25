import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:paradosis_flutter/widgets/fancy_assign_menu.dart';
import 'package:paradosis_flutter/widgets/delivery_item_service.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class map_page extends StatefulWidget {
  const map_page({super.key});

  @override
  State<map_page> createState() => _MapPageState();
}

String generateQrCode() {
  final datePart = DateFormat('yyyyMMdd').format(DateTime.now());
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random();
  final randomPart = List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  return '\$datePart-\$randomPart';
}

class _MapPageState extends State<map_page> {
  LatLng? pickupLocation;
  LatLng? dropoffLocation;
  List<LatLng> routePoints = [];
  List<LatLng> endMarkers = [];
  List<DeliveryItem> deliveryItems = [];
  DeliveryItem? selectedItem;
  LatLng? currentLocation;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchEndMarkers();
    _loadUserRole(); 
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole');
    setState(() {
      userRole = role;
    });
  } 

  Future<void> _fetchEndMarkers() async {
    final items = await DeliveryItemService.fetchFullItems();
    setState(() {
      deliveryItems = items;
    });
  }

  Future<void> _getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permission denied.');
    }
  }

  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  setState(() {
    currentLocation = LatLng(position.latitude, position.longitude);
  });
}


  Future<void> _loadRoute(LatLng from, LatLng to, String amountTotal, String method) async {
    try {
      final double parsedAmountTotal = double.parse(amountTotal);

      setState(() {
        pickupLocation = from;
        dropoffLocation = to;
      });

      final qr = generateQrCode();
      final double amountFeeCourier = 53.0;
      final referenceCode = '34';
      final status = 'pending';
      final now = DateTime.now();
      final completedAt = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(now);

      final uri = Uri.parse(
        'http://beeaware.ddns.net:3002/api/123456789/trans/'
        'qr/$qr/amountFeeCourier/$amountFeeCourier/'
        'amountTotal/$parsedAmountTotal/method/$method/referenceCode/$referenceCode/'
        'status/$status/completedAt/${Uri.encodeComponent(completedAt)}',
      );


      final response = await http.get(uri, headers: {'accept': 'application/json'});
      if (response.statusCode == 200) {
        print('✅ Transaction API succeeded');
      } else {
        print('❌ Transaction API failed: \${response.statusCode}');
      }

      final sessionId = 'cma5h66bz0001tv3wt3f6dt2l';
      final sellerId = 'vbhyje5gbd4g56b6d5yg5';
      final courierId = '435f324fg5g45gdrfgds';
      final double latStart = from.latitude;
      final double longStart = from.longitude;
      final double latEnd = to.latitude;
      final double longEnd = to.longitude;
      final verified = 'ttt';
      final statusItem = 'pending';

      final urlItem = Uri.parse(
        'http://beeaware.ddns.net:3002/api/$sessionId/items/'
        'sellerId/$sellerId/courierId/$courierId/'
        'latStart/$latStart/longStart/$longStart/'
        'latEnd/$latEnd/longEnd/$longEnd/'
        'verified/$verified/status/$statusItem',
      );

      final responseItem = await http.get(urlItem, headers: {'accept': 'application/json'});
      if (responseItem.statusCode == 200) {
        print('✅ Item API succeeded');
      } else {
        print('❌ Item API failed: \${responseItem.statusCode}');
      }

    } catch (e) {
      print('Route error: \$e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load route or call API')),
      );
    }
  }

  void _takeJob(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚚 Take Job')),
    );
  }

  void _logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Optional: remove just specific keys if needed

  if (!mounted) return;

  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
}

  @override
Widget build(BuildContext context) {
  final GlobalKey assignKey = GlobalKey();

  return Scaffold(
    extendBodyBehindAppBar: true,
    backgroundColor: Colors.black,
    appBar: AppBar(
      title: const Text('Χάρτης'),
      backgroundColor: Colors.black.withOpacity(0.3),
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Logout',
          onPressed: _logout,
        ),
      ],
    ),
    body: Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            center: LatLng(37.9838, 23.7275),
            zoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
            ),
            PolylineLayer(
              polylines: [
                Polyline(points: routePoints, strokeWidth: 5, color: Colors.blue),
              ],
            ),
            MarkerLayer(
              markers: [
                if (currentLocation != null)
                Marker(
                  point: currentLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
                ),
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
                ...deliveryItems.map((item) => Marker(
                  point: item.position,
                  width: 30,
                  height: 30,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedItem = item;
                      });
                    },
                    child: const Icon(Icons.flag, color: Colors.orange),
                  ),
                )),
              ],
            ),
          ],
        ),

        
    //  Blur background when popup is visible
        if (selectedItem != null)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),

        if (selectedItem != null)
          Center(
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.65,
                constraints: const BoxConstraints(maxHeight: 600),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "📦 Delivery Info",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text("ID: ${selectedItem!.id}", style: const TextStyle(fontSize: 14)),
                    Text("Courier: ${selectedItem!.courierId}", style: const TextStyle(fontSize: 14)),
                    Text("Seller: ${selectedItem!.sellerId}", style: const TextStyle(fontSize: 14)),
                    Text("Status: ${selectedItem!.status}", style: const TextStyle(fontSize: 14)),

                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 380,
                        child: FlutterMap(
                          options: MapOptions(
                            center: selectedItem!.start,
                            zoom: 13.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: selectedItem!.start,
                                  width: 30,
                                  height: 30,
                                  child: const Icon(Icons.circle, color: Colors.green, size: 20),
                                ),
                                Marker(
                                  point: selectedItem!.end,
                                  width: 30,
                                  height: 30,
                                  child: const Icon(Icons.location_on, color: Colors.red, size: 25),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => setState(() => selectedItem = null),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),


        // Fancy buttons
        Positioned(
          top: MediaQuery.of(context).padding.top + kToolbarHeight + 10,
          left: 20,
          right: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (userRole == 'Seller')
                      buildFancyButton(
                        context: context,
                        key: assignKey,
                        text: "Assign Job",
                        icon: Icons.assignment_outlined,
                        onPressed: () {
                          showFancyAssignJobMenu(
                            context,
                            assignKey,
                            onClothesSelected: (from, to, amountTotal, method) =>
                                _loadRoute(from, to, amountTotal, method),
                          );
                        },
                        gradient: [Colors.deepPurple, Colors.purpleAccent],
                      ),
                    if (userRole == 'Courier')
                      buildFancyButton(
                        context: context,
                        text: "Take Job",
                        icon: Icons.delivery_dining,
                        onPressed: () => _takeJob(context),
                        gradient: [Colors.green.shade700, Colors.teal],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget buildFancyButton({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    required List<Color> gradient,
    Key? key,
  }) {
    return GestureDetector(
      key: key,
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}