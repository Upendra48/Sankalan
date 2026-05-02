import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:trash_map/fohor/fohor_here.dart';

Future<void> requestNewFohor(Report_Fohor request) async {
  final url = Uri.parse('http://127.0.0.1:8000/api/report-waste/');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(request.context).showSnackBar(
        SnackBar(
          content: Text("Report submitted successfully"),
        ),
      );
      print("Report submitted successfully");
    } else {
      print("Failed to submit request: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}
