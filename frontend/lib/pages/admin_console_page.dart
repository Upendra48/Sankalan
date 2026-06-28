import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trash_map/api.dart';

class AdminConsolePage extends StatefulWidget {
  final Function(double lat, double lng) onLocateBin;

  const AdminConsolePage({super.key, required this.onLocateBin});

  @override
  State<AdminConsolePage> createState() => _AdminConsolePageState();
}

class _AdminConsolePageState extends State<AdminConsolePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _requests = [];
  List<dynamic> _reports = [];
  List<dynamic> _alerts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final reqResponse = await http.get(apiUri('requests/'));
      final repResponse = await http.get(apiUri('report-waste/'));
      final alertResponse = await http.get(apiUri('admin-notifications/'));

      if (mounted) {
        setState(() {
          if (reqResponse.statusCode == 200)
            _requests = json.decode(reqResponse.body);
          if (repResponse.statusCode == 200)
            _reports = json.decode(repResponse.body);
          if (alertResponse.statusCode == 200)
            _alerts = json.decode(alertResponse.body);
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _approveRequest(Map<String, dynamic> request) async {
    try {
      // 1. Create a new Waste Bin at request location
      final binResponse = await http.post(
        apiUri('wastebins/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': 'Bin_${request['user_name']}',
          'latitude': request['latitude'],
          'longitude': request['longitude'],
          'fill_level': 'Empty',
          'status': true,
        }),
      );

      // 2. Remove the request
      if (binResponse.statusCode == 201) {
        await http.delete(apiUri('requests/${request['id']}/'));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Request approved! New bin created successfully."),
              backgroundColor: Color(0xFF059669),
            ),
          );
        }
        _fetchData();
      } else {
        throw Exception("Failed to create waste bin from request.");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _rejectRequest(int id) async {
    try {
      final response = await http.delete(apiUri('requests/$id/'));
      if (response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Request rejected and deleted."),
              backgroundColor: Colors.orange.shade700,
            ),
          );
        }
        _fetchData();
      }
    } catch (e) {
      debugPrint("Error rejecting request: $e");
    }
  }

  Future<void> _resolveReport(int id) async {
    try {
      final response = await http.delete(apiUri('report-waste/$id/'));
      if (response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Waste incident resolved!"),
              backgroundColor: Color(0xFF059669),
            ),
          );
        }
        _fetchData();
      }
    } catch (e) {
      debugPrint("Error resolving incident: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Admin Console",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF059669),
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: const Color(0xFF059669),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_location_alt_outlined),
                  const SizedBox(width: 8),
                  Text("Requests (${_requests.length})"),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.report_problem_outlined),
                  const SizedBox(width: 8),
                  Text("Reports (${_reports.length})"),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_active_outlined),
                  const SizedBox(width: 8),
                  Text("Alerts (${_alerts.length})"),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsList(),
                _buildReportsList(),
                _buildAlertsList(),
              ],
            ),
    );
  }

  Widget _buildRequestsList() {
    if (_requests.isEmpty) {
      return _buildEmptyState(
        Icons.add_location_outlined,
        "No Pending Bin Requests",
        "Requests submitted by users for new waste bins will appear here.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Request by: ${request['user_name']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Text(
                        request['status'] ?? "Pending",
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Reason: ${request['reason']}",
                  style: const TextStyle(color: Color(0xFF475569)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Lat: ${request['latitude']}, Lng: ${request['longitude']}",
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _rejectRequest(request['id']),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Reject"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _approveRequest(request),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Approve & Create Bin"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportsList() {
    if (_reports.isEmpty) {
      return _buildEmptyState(
        Icons.report_off_outlined,
        "No Community Reports",
        "Incidents reported by citizens will be listed here for collection scheduling.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Reported by: ${report['user_name']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade700,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Description: ${report['description']}",
                  style: const TextStyle(color: Color(0xFF475569)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Lat: ${report['latitude']}, Lng: ${report['longitude']}",
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => widget.onLocateBin(
                        double.parse(report['latitude'].toString()),
                        double.parse(report['longitude'].toString()),
                      ),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text("Locate"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _resolveReport(report['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Mark as Cleaned / Resolved"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertsList() {
    if (_alerts.isEmpty) {
      return _buildEmptyState(
        Icons.notifications_off_outlined,
        "No System Alerts",
        "Automated notifications generated when bins exceed fill limits will appear here.",
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        final binId = alert['waste_bin'];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.red.shade50.withOpacity(0.5),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade200, width: 0.5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade100,
              child: Icon(Icons.delete_sweep, color: Colors.red.shade800),
            ),
            title: Text(
              "Bin #$binId status: ${alert['status']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Reported on: ${alert['date_reported'] != null ? alert['date_reported'].substring(0, 10) : ''}",
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "CRITICAL",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
