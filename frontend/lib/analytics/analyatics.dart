import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnalyticsContent extends StatelessWidget {
  final Map<String, dynamic> data;

  const AnalyticsContent({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> weeklyActivity = data['weekly_activity'] ?? [];
    
    // Find the maximum count to scale the BarChart nicely
    double maxVal = 5.0;
    for (var item in weeklyActivity) {
      double count = double.tryParse(item['count'].toString()) ?? 0.0;
      if (count > maxVal) {
        maxVal = count + 2; // add padding
      }
    }

    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ListView(
        children: [
          // Section Title
          const Text(
            "Operational Analytics Console",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Granular historical performance and system metrics.",
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Enriched SaaS Metric Cards Row
          GridView.count(
            crossAxisCount: isDesktop ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            childAspectRatio: isDesktop ? 1.6 : 1.3,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildMetricCard(
                "24h Alerts",
                "${data['filled_last_24h'] ?? 0} Bins",
                "Full alerts generated",
                Icons.notification_important_outlined,
                Colors.red,
              ),
              _buildMetricCard(
                "24h Incidents",
                "${data['reports_last_24h'] ?? 0} Reports",
                "Community submittals",
                Icons.feedback_outlined,
                Colors.orange,
              ),
              _buildMetricCard(
                "Efficiency",
                "${data['efficiency_rate'] ?? 100.0}%",
                "Collection success rate",
                Icons.check_circle_outline_rounded,
                const Color(0xFF059669),
              ),
              _buildMetricCard(
                "Fill Density",
                "${data['full_bins_percentage'] != null ? data['full_bins_percentage'].toStringAsFixed(1) : '0'}%",
                "Active full bins ratio",
                Icons.bar_chart_rounded,
                Colors.teal,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Charts Section
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildPieChartCard()),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: _buildBarChartCard(weeklyActivity, maxVal)),
              ],
            )
          else
            Column(
              children: [
                _buildPieChartCard(),
                const SizedBox(height: 24),
                _buildBarChartCard(weeklyActivity, maxVal),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String val, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                ),
                Icon(icon, color: color, size: 22),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  val,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Current Status Distribution",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sections: [
                    _buildPieChartSection(
                      double.tryParse(data['empty_bins_percentage'].toString()) ?? 0.0,
                      'Empty',
                      const Color(0xFF059669),
                    ),
                    _buildPieChartSection(
                      double.tryParse(data['half_filled_bins_percentage'].toString()) ?? 0.0,
                      'Half-Filled',
                      Colors.amber,
                    ),
                    _buildPieChartSection(
                      double.tryParse(data['full_bins_percentage'].toString()) ?? 0.0,
                      'Full',
                      Colors.red,
                    ),
                  ],
                  sectionsSpace: 4,
                  centerSpaceRadius: 40,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLegendRow("Empty Bins", const Color(0xFF059669), data['empty_bins'] ?? 0),
            _buildLegendRow("Half-Filled Bins", Colors.amber, data['half_filled_bins'] ?? 0),
            _buildLegendRow("Full Bins", Colors.red, data['full_bins'] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard(List<dynamic> weeklyActivity, double maxVal) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weekly Waste Accumulation Activity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              "Frequency of bins reaching critical 'Full' status per day.",
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 220,
              child: weeklyActivity.isEmpty
                  ? const Center(child: Text("No weekly activity data available"))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxVal,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => const Color(0xFF1E293B),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                "${rod.toY.toInt()} Bins",
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < weeklyActivity.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      weeklyActivity[index]['day'],
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(weeklyActivity.length, (index) {
                          final val = double.tryParse(weeklyActivity[index]['count'].toString()) ?? 0.0;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: val,
                                color: const Color(0xFF059669),
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _buildPieChartSection(double value, String title, Color color) {
    return PieChartSectionData(
      value: value,
      title: '${value.toStringAsFixed(0)}%',
      color: color,
      radius: 50,
      titleStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildLegendRow(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
            ],
          ),
          Text(
            "$count Bins",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }
}
