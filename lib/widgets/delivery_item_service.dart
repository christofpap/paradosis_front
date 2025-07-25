import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class DeliveryItem {
  final String id;
  final double latStart;
  final double longStart;
  final double latEnd;
  final double longEnd;
  final String status;
  final String courierId;
  final String sellerId;

  DeliveryItem({
    required this.id,
    required this.latStart,
    required this.longStart,
    required this.latEnd,
    required this.longEnd,
    required this.status,
    required this.courierId,
    required this.sellerId,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      id: json['id'],
      latStart: (json['latStart'] as num).toDouble(),
      longStart: (json['longStart'] as num).toDouble(),
      latEnd: (json['latEnd'] as num).toDouble(),
      longEnd: (json['longEnd'] as num).toDouble(),
      status: json['status'],
      courierId: json['courierId'],
      sellerId: json['sellerId'],
    );
  }

  LatLng get start => LatLng(latStart, longStart);
  LatLng get end => LatLng(latEnd, longEnd);
  LatLng get position => LatLng(latEnd, longEnd);
}


class DeliveryItemService {
  static Future<List<LatLng>> fetchEndMarkers() async {
    try {
      final url = Uri.parse(
        'http://beeaware.ddns.net:3002/api/cma5h66bz0001tv3wt3f6dt2l/items',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final items = data.map((e) => DeliveryItem.fromJson(e)).toList();
        return items.map((e) => LatLng(e.latEnd, e.longEnd)).toList();
      } else {
        print('❌ Failed to fetch items: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching delivery items: $e');
      return [];
    }
  }
  
  static Future<List<DeliveryItem>> fetchFullItems() async {
  final url = Uri.parse('http://beeaware.ddns.net:3002/api/cma5h66bz0001tv3wt3f6dt2l/items');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List.from(data).map((e) => DeliveryItem.fromJson(e)).toList();
  } else {
    print('❌ Failed to load');
    return [];
  }
}
}
