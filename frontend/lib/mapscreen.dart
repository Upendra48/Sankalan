import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> markers = [];
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    _fetchWasteBins();
  }

  Future<void> _fetchWasteBins() async {
    final response =
        await http.get(Uri.parse('http://127.0.0.1:8000/api/wastebins/'));
    if (response.statusCode == 200) {
      List<dynamic> bins = json.decode(response.body);
      setState(() {
        markers.clear();
        for (var bin in bins) {
          markers.add(Marker(
            point: LatLng(bin['latitude'], bin['longitude']),
            width: 40.0,
            height: 40.0,
            child: Icon(
              Icons.location_on,
              color: bin['fill_level'] == 'Empty'
                  ? Colors.green
                  : bin['fill_level'] == 'Half-Filled'
                      ? Colors.yellow
                      : Colors.red,
              size: 40.0,
            ),
          ));
        }
      });
    }
  }

  void _handleTap(TapPosition tapPosition, LatLng latLng) {
    setState(() {
      selectedLocation = latLng;
    });
    _showRequestBinDialog();
  }

  void _showRequestBinDialog() {
    if (selectedLocation != null) {
      // Request Bin Logic
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(28.261336, 83.971944),
          initialZoom: 16,
          onTap: _handleTap,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}
