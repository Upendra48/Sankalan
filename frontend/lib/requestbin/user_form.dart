import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trash_map/requestbin/fetch.dart';
import 'package:trash_map/requestbin/request_bin.dart';

class RequestBinForm extends StatefulWidget {
  @override
  State<RequestBinForm> createState() => _RequestBinFormState();
}

class _RequestBinFormState extends State<RequestBinForm> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

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
              "Request New Bin",
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
              controller: reasonController,
              decoration: const InputDecoration(labelText: "Reason"),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300, // Small map box
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(28.261336, 83.971944), 
                  initialZoom: 16,// Default location
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
                          child:  Icon(
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
                final request = RequestBin(
                  userName: userNameController.text,
                  latitude: double.parse(latitudeController.text),
                  longitude: double.parse(longitudeController.text),
                  reason: reasonController.text,
                  context: context,
                );

                requestNewBin(request).then((_) {
                  Navigator.pop(context);
                });
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
