import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/scan_result.dart';

class ResultScreen extends StatelessWidget {
  final ScanResult scanResult;

  const ResultScreen({super.key, required this.scanResult});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نتيجة الفحص'),
          centerTitle: true,
          backgroundColor: scanResult.safetyColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareResult(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildResultHeader(),
              const SizedBox(height: 20),
              _buildLinkCard(),
              const SizedBox(height: 20),
              _buildScoreCard(),
              const SizedBox(height: 20),
              _buildDetailsCard(),
              const SizedBox(height: 20),
              _buildTechnicalInfo(),
              const SizedBox(height: 30),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader() {
    IconData icon;
    String statusText;
    Color color = scanResult.safetyColor;

    if (scanResult.safe == true) {
      icon = Icons.check_circle_outline;
      statusText = 'الرابط آمن';
    } else if (scanResult.safe == false) {
      icon = Icons.dangerous_outlined;
      statusText = 'الرابط خطير';
    } else {
      icon = Icons.warning_amber_outlined;
      statusText = 'الرابط مشبوه';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  scanResult.message,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, color: Color(0xFF0A4779), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'الرابط المفحوص',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SelectableText(
                scanResult.link,
                style: const TextStyle(fontSize: 14, color: Color(0xFF0A4779)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تاريخ الفحص: ${_formatDate(scanResult.timestamp)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ID: ${scanResult.id.substring(0, 8)}...',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'مستوى الأمان',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${scanResult.score}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: scanResult.safetyColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: scanResult.score / 100,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scanResult.safetyColor.withOpacity(0.7),
                          scanResult.safetyColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScoreIndicator('آمن', scanResult.safe == true),
                _buildScoreIndicator('مشبوه', scanResult.safe == null),
                _buildScoreIndicator('خطير', scanResult.safe == false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(String label, bool isActive) {
    Color color = label == 'آمن' ? Colors.green : 
                  label == 'خطير' ? Colors.red : Colors.orange;
    
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? color : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? color : Colors.grey,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF0A4779)),
                const SizedBox(width: 8),
                const Text(
                  'تفاصيل الفحص',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...scanResult.details.map((detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        detail.startsWith('✓') ? Icons.check_circle : 
                        detail.startsWith('⚠') ? Icons.warning : Icons.circle,
                        size: 16,
                        color: detail.startsWith('✓') ? Colors.green :
                               detail.startsWith('⚠') ? Colors.orange : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          detail,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalInfo() {
    if (scanResult.ipAddress == null && scanResult.domain == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dns, color: Color(0xFF0A4779)),
                const SizedBox(width: 8),
                const Text(
                  'معلومات تقنية',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (scanResult.domain != null)
              _buildInfoRow('النطاق:', scanResult.domain!),
            if (scanResult.ipAddress != null)
              _buildInfoRow('عنوان IP:', scanResult.ipAddress!),
            if (scanResult.responseTime > 0)
              _buildInfoRow('زمن الاستجابة:', '${scanResult.responseTime.toStringAsFixed(2)} ثانية'),
            if (scanResult.threatsCount != null)
              _buildInfoRow('عدد التهديدات:', scanResult.threatsCount.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _launchUrl(context),
            icon: const Icon(Icons.open_in_browser),
            label: const Text('فتح الرابط'),
            style: ElevatedButton.styleFrom(
              backgroundColor: scanResult.safetyColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('رجوع'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.parse(scanResult.link);
    
    if (scanResult.safe == false) {
      final shouldProceed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تحذير!'),
          content: const Text('هذا الرابط قد يكون خطيراً. هل أنت متأكد من فتحه؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('فتح على مسؤوليتي'),
            ),
          ],
        ),
      );

      if (!shouldProceed) return;
    }

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن فتح هذا الرابط'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareResult(BuildContext context) {
    String message = '''
نتيجة فحص الرابط:
${scanResult.link}

الحالة: ${scanResult.safetyStatus}
نسبة الأمان: ${scanResult.score}%
التفاصيل: ${scanResult.details.join('\n')}
تاريخ الفحص: ${_formatDate(scanResult.timestamp)}
    ''';

    // يمكن إضافة مكتبة مشاركة هنا
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة ميزة المشاركة قريباً'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}