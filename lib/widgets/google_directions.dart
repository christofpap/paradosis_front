import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GoogleDirectionsService {
  static const String _apiKey = 'AIzaSyBt33aPvHPCQgR1PzIV2roDYu5XpWpkh2U'; 
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  static Future<List<LatLng>> getRouteCoordinates({
    required LatLng origin,
    required LatLng destination,
  }) async {
  final proxyUrl = Uri.parse(
    'http://192.168.1.162:56260/directions?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}',
  );

  final response = await http.get(proxyUrl);
  final data = jsonDecode(response.body);

  if (data['status'] != 'OK') {
    throw Exception('Failed to fetch route: ${data['status']}');
  }

  final encoded = data['routes'][0]['overview_polyline']['points'];
  return _decodePolyline(encoded);
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      polyline.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return polyline;
  }
}
