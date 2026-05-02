import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trash_map/bin/bin_fetch.dart';
import 'package:http/http.dart' as http;


class BinDetailsBottomSheet extends StatelessWidget {
  final Bin bin;

  const BinDetailsBottomSheet({super.key, required this.bin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bin.name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text("Latitude: ${bin.latitude}"),
          Text("Longitude: ${bin.longitude}"),
          const SizedBox(height: 10),
          Text("Current Status: ${bin.fillLevel}"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _changeBinStatus(context, bin, 'Empty');
            },
            child: const Text("Mark as Empty"),
          ),
          ElevatedButton(
            onPressed: () {
              _changeBinStatus(context, bin, 'Half-Filled');
            },
            child: const Text("Mark as Half-Filled"),
          ),
          ElevatedButton(
            onPressed: () {
              _changeBinStatus(context, bin, 'Full');
            },
            child: const Text("Mark as Full"),
          ),
        ],
      ),
    );
  }

  void _changeBinStatus(BuildContext context, Bin bin, String newStatus) async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/wastebins/${bin.id}/');
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"fill_level": newStatus}),
      );

      if (response.statusCode == 200) {
        // Successfully updated the bin status
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bin status updated to: $newStatus")),
        );
      } else {
        // Handle server errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update bin. Try again.")),
        );
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    } finally {
      Navigator.pop(context); // Close the bottom sheet
    }
  }
}
