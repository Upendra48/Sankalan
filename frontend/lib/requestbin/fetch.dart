import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trash_map/requestbin/request_bin.dart';


Future<void> requestNewBin(RequestBin request) async {
  final url = Uri.parse('http://127.0.0.1:8000/api/requests/');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(request.context).showSnackBar(
        SnackBar(
          content: Text("Request submitted successfully"),
        ),
      );
      print("Request submitted successfully");
    } else {
      print("Failed to submit request: ${response.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }
}
