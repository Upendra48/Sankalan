import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trash_map/bin/bin_details_sheet.dart';
import 'package:trash_map/bin/bin_fetch.dart';

class BinMap extends StatelessWidget {
  final List<Bin> bins;
  final List<LatLng>? routePoints;
  final MapController? mapController;
  final VoidCallback? onBinsChanged;

  const BinMap({
    super.key,
    required this.bins,
    this.routePoints,
    this.mapController,
    this.onBinsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(28.261336, 83.971944),
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        if (routePoints != null && routePoints!.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints!,
                strokeWidth: 4.0,
                color: Colors.blue.shade600,
                borderColor: Colors.blue.shade900,
                borderStrokeWidth: 1.0,
              ),
            ],
          ),
        MarkerLayer(
          markers: bins.map((bin) {
            Color markerColor = _getMarkerColor(bin.fillLevel);
            return Marker(
              point: LatLng(bin.latitude, bin.longitude),
              child: GestureDetector(
                onTap: () {
                  // Show bin details
                  _onMarkerTap(context, bin, onBinsChanged);
                },
                child: Icon(
                  Icons.location_on,
                  color: markerColor,
                  size: 30,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

Color _getMarkerColor(String fillLevel) {
  switch (fillLevel) {
    case 'Empty':
      return Colors.green;
    case 'Half-Filled':
      return Colors.yellow;
    case 'Full':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

void _onMarkerTap(BuildContext context, Bin bin, VoidCallback? onBinsChanged) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return BinDetailsBottomSheet(
        bin: bin,
        onUpdated: onBinsChanged,
      );
    },
  );
}
