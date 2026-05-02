import 'package:flutter/material.dart';

class Report_Fohor{
  final BuildContext context;
  final String userName;
  final double latitude;
  final double longitude;
  final String description;

  Report_Fohor({
    required this.context,
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_name": userName,
      "latitude": latitude,
      "longitude": longitude,
      "description": description,
    };
  }
}