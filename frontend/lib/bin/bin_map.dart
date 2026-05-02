import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trash_map/bin/bin_details_sheet.dart';
import 'package:trash_map/bin/bin_fetch.dart';

class BinMap extends StatelessWidget {
  final List<Bin> bins;

  const BinMap({super.key, required this.bins});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(28.261336, 83.971944),
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: bins.map((bin) {
            Color markerColor = _getMarkerColor(bin.fillLevel);
            return Marker(
              point: LatLng(bin.latitude, bin.longitude),
              child: GestureDetector(
                onTap: () {
                  // Show bin details
                  _onMarkerTap(context, bin);
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

void _onMarkerTap(BuildContext context, Bin bin) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return BinDetailsBottomSheet(bin: bin);
    },
  );
}
