import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trash_map/fohor/fetch.dart';
import 'package:trash_map/fohor/fohor_here.dart';


class ReportFohor extends StatefulWidget {
  @override
  State<ReportFohor> createState() => _ReportFohorState();
}


class _ReportFohorState extends State<ReportFohor> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  LatLng? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Report Fohor",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: userNameController,
              decoration: const InputDecoration(labelText: "User Name"),
            ),
            TextField(
              controller: latitudeController,
              decoration: const InputDecoration(labelText: "Latitude"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: longitudeController,
              decoration: const InputDecoration(labelText: "Longitude"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300, // Small map box
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(28.261336, 83.971944), 
                  initialZoom: 16,
                  onTap: (tapPosition, point) {
                    setState(() {
                      selectedLocation = point;
                      latitudeController.text = point.latitude.toString();
                      longitudeController.text = point.longitude.toString();
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  if (selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: selectedLocation!,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final Report_Fohor request = Report_Fohor(
                  userName: userNameController.text,
                  latitude: double.parse(latitudeController.text),
                  longitude: double.parse(longitudeController.text),
                  description: descriptionController.text,
                  context: context,
                );

                requestNewFohor(request).then((_) {
                  Navigator.pop(context);
                });
              },
              child: const Text("Report Fohor"),
            ),
          ],
        ),
      ),
    );
  }
}
