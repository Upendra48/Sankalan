import 'package:flutter/material.dart';
import 'package:trash_map/analytics/analyatics.dart';
import 'package:trash_map/analytics/fetch.dart';


class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late Future<Map<String, dynamic>> analyticsData;

  @override
  void initState() {
    super.initState();
    analyticsData = ApiService().fetchAnalyticsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics Dashboard'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: analyticsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data!;
            return AnalyticsContent(data: data);
          }
        },
      ),
    );
  }
}
