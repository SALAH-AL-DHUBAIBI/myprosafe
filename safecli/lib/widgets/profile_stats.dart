import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int scannedLinks;
  final int detectedThreats;
  final double accuracyRate;

  const ProfileStats({
    super.key,
    required this.scannedLinks,
    required this.detectedThreats,
    required this.accuracyRate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.link,
                  label: 'تم الفحص',
                  value: scannedLinks.toString(),
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.warning,
                  label: 'تهديدات',
                  value: detectedThreats.toString(),
                  color: Colors.red,
                ),
                _buildStatItem(
                  icon: Icons.analytics,
                  label: 'الدقة',
                  value: '${accuracyRate.toStringAsFixed(1)}%',
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: accuracyRate / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            const Text(
              'معدل الدقة في الكشف',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}