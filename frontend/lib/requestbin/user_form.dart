import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:trash_map/auth/auth_service.dart';
import 'package:trash_map/requestbin/fetch.dart';
import 'package:trash_map/requestbin/request_bin.dart';

class RequestBinForm extends StatefulWidget {
  const RequestBinForm({super.key});

  @override
  State<RequestBinForm> createState() => _RequestBinFormState();
}

class _RequestBinFormState extends State<RequestBinForm> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  LatLng? selectedLocation;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    userNameController.text = AuthService.instance.displayName;
  }

  @override
  void dispose() {
    userNameController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final latitude = double.tryParse(latitudeController.text.trim());
    final longitude = double.tryParse(longitudeController.text.trim());

    if (userNameController.text.trim().isEmpty ||
        latitude == null ||
        longitude == null ||
        reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a name, valid map location, and reason.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final request = RequestBin(
      userName: userNameController.text.trim(),
      latitude: latitude,
      longitude: longitude,
      reason: reasonController.text.trim(),
      context: context,
    );

    final success = await requestNewBin(request);

    if (!mounted) return;
    setState(() => isSubmitting = false);
    if (success) Navigator.pop(context);
  }

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
                  initialZoom: 16, // Default location
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
              onPressed: isSubmitting ? null : _submit,
              child: isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
