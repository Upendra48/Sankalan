import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trash_map/api.dart';
import 'package:trash_map/fohor/fohor_here.dart';

Future<void> requestNewFohor(Report_Fohor request) async {
  try {
    final response = await apiPost(
      'waste-reports/',
      body: json.encode(request.toJson()),
    );
    ApiClient.ensureSuccess(response);

    if (request.context.mounted) {
      ScaffoldMessenger.of(request.context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully')),
      );
    }
  } catch (e) {
    if (request.context.mounted) {
      ScaffoldMessenger.of(request.context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
