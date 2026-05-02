import 'package:flutter/material.dart';

class RequestBin {
  final BuildContext context;
  final String userName;
  final double latitude;
  final double longitude;
  final String reason;

  RequestBin({
    required this.context,
    required this.userName,
    required this.latitude,
    required this.longitude,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      "user_name": userName,
      "latitude": latitude,
      "longitude": longitude,
      "reason": reason,
    };
  }
}
