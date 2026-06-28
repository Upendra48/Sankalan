import 'dart:convert';

import 'package:trash_map/api.dart';

class Bin {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String fillLevel;

  Bin({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.fillLevel,
  });

  factory Bin.fromJson(Map<String, dynamic> json) {
    return Bin(
      id: json['id'],
      name: json['name'],
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      fillLevel: json['fill_level']?.toString() ?? 'Empty',
    );
  }
}

class OptimizedRoute {
  final double startLat;
  final double startLng;
  final List<Bin> route;
  final double totalDistance;

  OptimizedRoute({
    required this.startLat,
    required this.startLng,
    required this.route,
    required this.totalDistance,
  });

  factory OptimizedRoute.fromJson(Map<String, dynamic> json) {
    final routeList = json['route'] as List? ?? [];
    return OptimizedRoute(
      startLat:
          double.tryParse(json['start_point']['latitude'].toString()) ?? 0.0,
      startLng:
          double.tryParse(json['start_point']['longitude'].toString()) ?? 0.0,
      route: routeList.map((item) => Bin.fromJson(item)).toList(),
      totalDistance:
          double.tryParse(json['total_distance_km'].toString()) ?? 0.0,
    );
  }
}

Future<List<Bin>> fetchBins() async {
  final response = await apiGet('waste-bins/');
  ApiClient.ensureSuccess(response);
  return unwrapList(response).map((bin) => Bin.fromJson(bin)).toList();
}

Future<OptimizedRoute> fetchOptimizedRoute(
  double startLat,
  double startLng,
) async {
  final response = await apiGet(
    'collection-routes/?start_lat=$startLat&start_lng=$startLng',
  );
  ApiClient.ensureSuccess(response);
  return OptimizedRoute.fromJson(unwrapMap(response));
}

Future<void> updateBinFillLevel(int binId, String fillLevel) async {
  final response = await apiPatch(
    'waste-bins/$binId/',
    body: json.encode({'fill_level': fillLevel}),
  );
  ApiClient.ensureSuccess(response);
}
