import 'package:flutter/material.dart';
import 'package:trash_map/bin/bin_fetch.dart';

class BinDetailsBottomSheet extends StatelessWidget {
  final Bin bin;
  final VoidCallback? onUpdated;

  const BinDetailsBottomSheet({
    super.key,
    required this.bin,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = bin.fillLevel == 'Empty'
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bin.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: #${bin.id}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  bin.fillLevel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLocationInfoTile('Latitude', bin.latitude.toStringAsFixed(6)),
              Container(height: 24, width: 1, color: const Color(0xFFE2E8F0)),
              _buildLocationInfoTile(
                'Longitude',
                bin.longitude.toStringAsFixed(6),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Update Fill Level',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildStatusActionButton(context, 'Empty', const Color(0xFF059669)),
              const SizedBox(width: 8),
              _buildStatusActionButton(context, 'Half-Filled', Colors.amber),
              const SizedBox(width: 8),
              _buildStatusActionButton(context, 'Full', Colors.red),
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
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusActionButton(
    BuildContext context,
    String status,
    Color color,
  ) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _changeBinStatus(context, status),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: color,
            width: bin.fillLevel == status ? 2 : 1,
          ),
          backgroundColor: bin.fillLevel == status
              ? color.withOpacity(0.08)
              : Colors.transparent,
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
    try {
      await updateBinFillLevel(bin.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bin status updated to $newStatus'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        onUpdated?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating bin: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
