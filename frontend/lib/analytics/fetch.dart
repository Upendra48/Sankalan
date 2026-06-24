import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trash_map/api.dart';

class ApiService {
  static final Uri apiUrl = apiUri('waste-bin-analytics/');

  Future<Map<String, dynamic>> fetchAnalyticsData() async {
    final response = await http.get(apiUrl);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load analytics data');
    }
  }
}
