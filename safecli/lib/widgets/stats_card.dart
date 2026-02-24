import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  final String scannedCount;
  final String maliciousCount;
  final String blockedCount;

  const StatsCard({
    super.key,
    required this.scannedCount,
    required this.maliciousCount,
    required this.blockedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الإحصائيات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.link,
                  label: 'تم الفحص',
                  value: scannedCount,
                  color: Colors.blue,
                ),
                _buildStatItem(
                  icon: Icons.warning,
                  label: 'ضار',
                  value: maliciousCount,
                  color: Colors.red,
                ),
                _buildStatItem(
                  icon: Icons.block,
                  label: 'تم الحظر',
                  value: blockedCount,
                  color: Colors.orange,
                ),
              ],
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
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
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