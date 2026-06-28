import 'package:trash_map/api.dart';

class ApiService {
  Future<Map<String, dynamic>> fetchAnalyticsData() async {
    final response = await apiGet('waste-bin-analytics/');
    ApiClient.ensureSuccess(response);
    return unwrapMap(response);
  }
}
