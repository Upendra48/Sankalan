import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Bin {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String fillLevel;

  Bin({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.fillLevel,
  });

  factory Bin.fromJson(Map<String, dynamic> json) {
    return Bin(
      id: json['id'],
      name: json['name'],
      // Convert latitude and longitude from String to double
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      // Assuming fill_level is an integer, adjust if necessary
      fillLevel: json['fill_level'] ?? 0,
    );
  }
}

Future<List<Bin>> fetchBins() async {
  final url = Uri.parse('http://127.0.0.1:8000/api/wastebins/');
  try {
    final response = await http.get(url);

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((bin) => Bin.fromJson(bin)).toList();
    } else {
      throw Exception('Failed to load bins');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Failed to connect to server');
  }
}
