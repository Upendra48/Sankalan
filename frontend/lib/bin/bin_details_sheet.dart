import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:trash_map/bin/bin_fetch.dart';
import 'package:trash_map/main.dart';
import 'package:http/http.dart' as http;

class BinDetailsBottomSheet extends StatelessWidget {
  final Bin bin;

  const BinDetailsBottomSheet({super.key, required this.bin});

  @override
  Widget build(BuildContext context) {
    Color statusColor = bin.fillLevel == 'Empty'
        ? const Color(0xFF059669)
        : bin.fillLevel == 'Half-Filled'
            ? Colors.amber
            : Colors.red;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bin.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID: #${bin.id}",
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  bin.fillLevel,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          
          // Location Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLocationInfoTile("Latitude", bin.latitude.toStringAsFixed(6)),
              Container(height: 24, width: 1, color: const Color(0xFFE2E8F0)),
              _buildLocationInfoTile("Longitude", bin.longitude.toStringAsFixed(6)),
            ],
          ),
          const SizedBox(height: 24),

          // Status Action Buttons
          const Text(
            "Change Fill Level Status",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusActionButton(context, 'Empty', const Color(0xFF059669)),
              const SizedBox(width: 8),
              _buildStatusActionButton(context, 'Half-Filled', Colors.amber),
              const SizedBox(width: 8),
              _buildStatusActionButton(context, 'Full', Colors.red),
            ],
          ),
          const SizedBox(height: 20),

          // Utility Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reportFull(context),
                  icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
                  label: const Text("Report Full", style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _decommissionBin(context),
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  label: const Text("Decommission Bin"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfoTile(String label, String val) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _buildStatusActionButton(BuildContext context, String status, Color color) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _changeBinStatus(context, status),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: bin.fillLevel == status ? 2 : 1),
          backgroundColor: bin.fillLevel == status ? color.withOpacity(0.08) : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _changeBinStatus(BuildContext context, String newStatus) async {
    if (!AuthManager.isVerified) {
      _showAdminRequiredDialog(context);
      return;
    }
    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/wastebins/${bin.id}/change_fill_level/');
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"fill_level": newStatus}),
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Bin status updated to: \$newStatus"),
              backgroundColor: Color(0xFF059669),
            ),
          );
        }
      } else {
        throw Exception("Failed to update status.");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating bin: $e"), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (context.mounted) {
        Navigator.pop(context); // Close sheet
      }
    }
  }

  Future<void> _reportFull(BuildContext context) async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/wastebins/${bin.id}/report_full/');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Bin reported as full! Admin alert triggered."),
              backgroundColor: Color(0xFF059669),
            ),
          );
        }
      } else {
        // If server says it's not full, let's inform the user
        final body = json.decode(response.body);
        throw Exception(body['status'] ?? "Failed to report.");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Alert failed: $e"), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _decommissionBin(BuildContext context) async {
    if (!AuthManager.isVerified) {
      _showAdminRequiredDialog(context);
      return;
    }
    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/wastebins/${bin.id}/');
      final response = await http.delete(url);

      if (response.statusCode == 204) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Waste bin successfully decommissioned."),
              backgroundColor: Color(0xFF64748B),
            ),
          );
        }
      } else {
        throw Exception("Delete request failed.");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _showAdminRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.gpp_maybe_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text(
              "Access Denied",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Admin privileges are required to modify waste bin configurations. Please log in with an approved administrator account under the 'Admin' console tab.",
          style: TextStyle(color: Color(0xFF475569), fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Dismiss",
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
