import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trash_map/api.dart';
import 'package:trash_map/requestbin/request_bin.dart';

Future<bool> requestNewBin(RequestBin request) async {
  try {
    final response = await apiPost(
      'bin-requests/',
      body: json.encode(request.toJson()),
    );
    ApiClient.ensureSuccess(response);

    if (request.context.mounted) {
      ScaffoldMessenger.of(request.context).showSnackBar(
        const SnackBar(content: Text('Request submitted successfully')),
      );
    }
    return true;
  } catch (e) {
    if (request.context.mounted) {
      ScaffoldMessenger.of(request.context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return false;
  }
}
