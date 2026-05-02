import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:trash_map/bin/bin_fetch.dart';
import 'package:trash_map/bin/bin_map.dart';

// class MapPage extends StatefulWidget {
//   @override
//   _MapPageState createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   List<dynamic> wasteBins = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchWasteBins();
//   }

//   // Fetch waste bin data from Django backend
//   Future<void> fetchWasteBins() async {
//     final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/wastebins/'));
//     if (response.statusCode == 200) {
//       setState(() {
//         wasteBins = json.decode(response.body);
//       });
//     } else {
//       print('Failed to load waste bins');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Waste Bin Map'),
//       ),
//       body: FlutterMap(
//         options: MapOptions(
//           initialCenter: LatLng(27.7172, 85.3240), // Default location (Kathmandu, Nepal)
//           onTap: (tapPosition, point) {
//             print('Tapped location: ${point.latitude}, ${point.longitude}');
//           },
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//             subdomains: ['a', 'b', 'c'],
//           ),
//           MarkerLayer(
//             markers: wasteBins.map((bin) {
//               return Marker(
//                 width: 80.0,
//                 height: 80.0,
//                 point: LatLng(bin['latitude'], bin['longitude']),
//                 child: Icon(
//                   Icons.location_on,
//                   color: getMarkerColor(bin['fill_level']),
//                   size: 40.0,
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper function to get marker color based on fill level
//   Color getMarkerColor(String fillLevel) {
//     switch (fillLevel) {
//       case 'Empty':
//         return Colors.green;
//       case 'Half-Filled':
//         return Colors.yellow;
//       case 'Full':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }
// }


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<Bin>> futureBins;

  @override
  void initState() {
    super.initState();
    futureBins = fetchBins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Bin Map'),
      ),
      body: FutureBuilder<List<Bin>>(
        future: futureBins,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading bins'));
          } else {
            return BinMap(bins: snapshot.data!);
          }
        },
      ),
    );
  }
}
