import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsContent extends StatelessWidget {
  final Map<String, dynamic> data;

  const AnalyticsContent({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Text(
            "Waste Bin Analytics",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 16),
          
          // Summary Section
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Bins: ${data['total_bins']}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const Divider(),
                  _buildDataRow("Empty Bins", data['empty_bins'], data['empty_bins_percentage']),
                  _buildDataRow("Half-Filled Bins", data['half_filled_bins'], data['half_filled_bins_percentage']),
                  _buildDataRow("Full Bins", data['full_bins'], data['full_bins_percentage']),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Chart Section
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Bin Status Distribution",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: [
                            _buildPieChartSection(
                              data['empty_bins_percentage'].toDouble(),
                              'Empty',
                              Colors.blue,
                            ),
                            _buildPieChartSection(
                              data['half_filled_bins_percentage'].toDouble(),
                              'Half-Filled',
                              Colors.orange,
                            ),
                            _buildPieChartSection(
                              data['full_bins_percentage'].toDouble(),
                              'Full',
                              Colors.red,
                            ),
                          ],
                          sectionsSpace: 4,
                          centerSpaceRadius: 50,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, int count, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            "$count (${percentage.toStringAsFixed(1)}%)",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieChartSection(double value, String title, Color color) {
    return PieChartSectionData(
      value: value,
      title: '${value.toStringAsFixed(1)}%',
      color: color,
      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }
}
