import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/report_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/report_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  int? _selectedSeverity = 3;
  late AnimationController _animationController;

  final List<String> _categories = [
    'رابط تصيد احتيالي (Phishing)',
    'رابط ضار (Malware)',
    'رابط احتيال مالي',
    'محتوى غير لائق',
    'بريد عشوائي (Spam)',
    'انتهاك خصوصية',
    'أخرى',
  ];

  final List<Map<String, dynamic>> _severityLevels = [
    {'value': 1, 'label': 'منخفض', 'color': Colors.green},
    {'value': 2, 'label': 'متوسط', 'color': Colors.blue},
    {'value': 3, 'label': 'عالي', 'color': Colors.orange},
    {'value': 4, 'label': 'خطير', 'color': Colors.red},
    {'value': 5, 'label': 'حرج', 'color': Colors.deepOrange},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _linkController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reportController = context.watch<ReportController>();
    final authController = context.watch<AuthController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    Colors.orange.shade50,
                    Colors.white,
                  ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(isDarkMode),
              const SizedBox(height: 20),
              _buildForm(reportController, authController, isDarkMode),
              const SizedBox(height: 20),
              _buildGuidelines(isDarkMode),
              const SizedBox(height: 20),
              if (reportController.lastError != null) 
                _buildErrorWidget(reportController, isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.orange.shade900.withOpacity(0.8)
            : Colors.orange.shade700,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.orange.shade900 : Colors.orange.shade700).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ساعد في حماية المجتمع',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الإبلاغ عن الروابط الضارة يساعد في حماية الآخرين',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(ReportController reportController, AuthController authController, bool isDarkMode) {
    return Card(
      elevation: 4,
      color: isDarkMode ? const Color(0xFF2A2A3A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل البلاغ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.orange.shade300 : const Color(0xFF0A4779),
              ),
            ),
            const SizedBox(height: 20),
            _buildLinkField(isDarkMode),
            const SizedBox(height: 20),
            _buildCategoryField(isDarkMode),
            const SizedBox(height: 20),
            _buildSeverityField(),
            const SizedBox(height: 20),
            _buildDescriptionField(isDarkMode),
            // const SizedBox(height: 20),
            // _buildAnonymousOption(isDarkMode),
            const SizedBox(height: 30),
            _buildSubmitButton(reportController, authController),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الرابط المشبوه *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _linkController,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'https://example.com',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
            prefixIcon: Icon(Icons.link, color: isDarkMode ? Colors.orange.shade300 : Colors.orange),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
              onPressed: () => _linkController.clear(),
            ),
          ),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }

  Widget _buildCategoryField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع التهديد *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              hint: Text(
                'اختر نوع التهديد',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.orange.shade300 : Colors.orange),
              dropdownColor: isDarkMode ? const Color(0xFF2A2A3A) : Colors.white,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeverityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'درجة الخطورة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: _severityLevels.map((level) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSeverity = level['value'];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedSeverity == level['value']
                        ? level['color']
                        : level['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedSeverity == level['value']
                          ? level['color']
                          : level['color'].withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        level['value'].toString(),
                        style: TextStyle(
                          color: _selectedSeverity == level['value']
                              ? Colors.white
                              : level['color'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        level['label'],
                        style: TextStyle(
                          fontSize: 10,
                          color: _selectedSeverity == level['value']
                              ? Colors.white
                              : level['color'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'وصف إضافي (اختياري)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 500,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'أضف أي تفاصيل إضافية عن الرابط...',
            hintStyle: TextStyle(
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  // Widget _buildAnonymousOption(bool isDarkMode) {
  //   return Row(
  //     children: [
  //       Checkbox(
  //         value: false,
  //         onChanged: (value) {},
  //         fillColor: WidgetStateProperty.resolveWith<Color>((states) {
  //           if (states.contains(WidgetState.selected)) {
  //             return isDarkMode ? Colors.orange.shade300 : Colors.orange;
  //           }
  //           return isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400;
  //         }),
  //       ),
  //       Text(
  //         'الإبلاغ بشكل مجهول',
  //         style: TextStyle(
  //           color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSubmitButton(ReportController reportController, AuthController authController) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: reportController.isReporting
            ? null
            : () => _submitReport(reportController, authController),
        icon: const Icon(Icons.send),
        label: reportController.isReporting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'إرسال البلاغ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),
    );
  }

  Widget _buildGuidelines(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.blue.shade900.withOpacity(0.2)
            : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.blue.shade700.withOpacity(0.3) : Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'إرشادات الإبلاغ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildGuidelineItem('تأكد من صحة الرابط قبل الإبلاغ', isDarkMode),
          _buildGuidelineItem('الإبلاغ الكاذب قد يعرضك للمساءلة', isDarkMode),
          _buildGuidelineItem('سيتم مراجعة البلاغ خلال 24 ساعة', isDarkMode),
          _buildGuidelineItem('يمكنك متابعة حالة البلاغ عبر رقم التتبع', isDarkMode),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ReportController reportController, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.red.shade900.withOpacity(0.3) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.red.shade700.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: isDarkMode ? Colors.red.shade300 : Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reportController.lastError!,
              style: TextStyle(
                color: isDarkMode ? Colors.red.shade300 : Colors.red,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 20,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            onPressed: reportController.clearError,
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport(ReportController reportController, AuthController authController) async {
    if (_linkController.text.trim().isEmpty) {
      _showSnackBar('يرجى إدخال الرابط المشبوه', Colors.red);
      return;
    }

    if (_selectedCategory == null) {
      _showSnackBar('يرجى اختيار نوع التهديد', Colors.red);
      return;
    }

    // التحقق من صحة الرابط
    if (!_isValidUrl(_linkController.text)) {
      _showSnackBar('الرابط غير صحيح', Colors.red);
      return;
    }

    final report = ReportModel(
      id: '',
      link: _linkController.text.trim(),
      category: _selectedCategory!,
      description: _descriptionController.text.trim(),
      reporterId: authController.currentUser?.id ?? 'anonymous',
      reporterName: authController.currentUser?.name ?? 'مستخدم مجهول',
      reportDate: DateTime.now(),
      severity: _selectedSeverity,
    );

    final success = await reportController.submitReport(report);

    if (success && mounted) {
      _showSuccessDialog(reportController, report);
      _clearForm();
    }
  }

  bool _isValidUrl(String url) {
    final urlPattern = r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$';
    final regex = RegExp(urlPattern, caseSensitive: false);
    return regex.hasMatch(url);
  }

  void _clearForm() {
    _linkController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedSeverity = 3;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog(ReportController reportController, ReportModel report) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final trackingNumber = reportController.reports.first.trackingNumber ?? 'غير متوفر';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A3A) : Colors.white,
        title: Text(
          'تم استلام البلاغ',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'شكراً لك على المساهمة في حماية المجتمع',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'رقم تتبع البلاغ:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    trackingNumber,
                    style: TextStyle(
                      fontSize: 18,
                      color: isDarkMode ? Colors.orange.shade300 : const Color(0xFF0A4779),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إغلاق',
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('مشاركة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkMode ? Colors.orange.shade700 : const Color(0xFF0A4779),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showReportsHistory(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة سجل البلاغات قريباً'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF2A2A3A) : Colors.white,
        title: Text(
          'معلومات الإبلاغ',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'الإبلاغ عن الروابط الضارة يساعد في حماية المجتمع الرقمي. يتم مراجعة جميع البلاغات من قبل فريق متخصص. يمكنك متابعة حالة بلاغك باستخدام رقم التتبع.',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade300 : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: TextStyle(
                color: isDarkMode ? Colors.orange.shade300 : const Color(0xFF0A4779),
              ),
            ),
          ),
        ],
      ),
    );
  }
}