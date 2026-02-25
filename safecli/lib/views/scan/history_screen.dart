import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/scan_controller.dart';
import '../../models/scan_result.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : const Text('بحث'),
        centerTitle: true,
        actions: [
          Consumer<ScanController>(
            builder: (context, scanController, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildAppBarActions(scanController),
              );
            },
          ),
        ],
        bottom: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.onPrimary,        
        unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7), 
        indicatorColor: Theme.of(context).colorScheme.onPrimary,     
        indicatorWeight: 3,              
        tabs: const [
        Tab(text: 'الكل'),
        Tab(text: 'آمن'),
        Tab(text: 'خطير'),
      ],
),
      ),
      body: Consumer<ScanController>(
        builder: (context, scanController, child) {
          return scanController.isScanning
              ? const Center(child: CircularProgressIndicator())
              : scanController.scanHistory.isEmpty
                  ? _buildEmptyState()
                  : _buildHistoryList(scanController);
        },
      ),
    );
  }

  List<Widget> _buildAppBarActions(ScanController scanController) {
    return [
      if (!_isSearching)
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      if (scanController.scanHistory.isNotEmpty && !_isSearching)
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'clear') {
              _showClearHistoryDialog(context, scanController);
            } else if (value == 'export') {
              _exportHistory();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  const Text('مسح السجل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('تصدير السجل'),
                ],
              ),
            ),
          ],
        ),
      if (_isSearching)
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
            });
          },
        ),
    ];
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'بحث في السجل...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7)),
        prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onPrimary),
      ),
      style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_toggle_off,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا توجد فحوصات سابقة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'ابدأ بفحص أول رابط الآن',
            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // العودة للصفحة الرئيسية
            },
            icon: const Icon(Icons.add),
            label: const Text('فحص رابط جديد'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(ScanController scanController) {
    List<ScanResult> filteredList = _getFilteredList(scanController);

    if (filteredList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 10),
            Text(
              'لا توجد نتائج للبحث',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'نتائج البحث: ${filteredList.length}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final item = filteredList[index];
              return _buildHistoryItem(context, item);
            },
          ),
        ),
      ],
    );
  }

  List<ScanResult> _getFilteredList(ScanController scanController) {
    List<ScanResult> list = scanController.scanHistory;

    // تصفية حسب التبويب
    switch (_tabController.index) {
      case 1:
        list = list.where((item) => item.safe == true).toList();
        break;
      case 2:
        list = list.where((item) => item.safe == false).toList();
        break;
    }

    // تصفية حسب البحث
    if (_searchQuery.isNotEmpty) {
      list = list.where((item) =>
        item.link.toLowerCase().contains(_searchQuery) ||
        item.safetyStatus.contains(_searchQuery)
      ).toList();
    }

    return list;
  }

  Widget _buildHistoryItem(BuildContext context, ScanResult item) {
    Color itemColor = item.safe == true ? Theme.of(context).colorScheme.tertiary : item.safe == false ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(scanResult: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: itemColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.safe == true
                      ? Icons.check_circle
                      : item.safe == false
                          ? Icons.cancel
                          : Icons.warning,
                  color: itemColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.link,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(item.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: itemColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.score}%',
                      style: TextStyle(
                        color: itemColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.safetyStatus,
                    style: TextStyle(
                      color: itemColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, ScanController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح السجل'),
        content: const Text(
          'هل أنت متأكد من مسح جميع سجلات الفحوصات؟ لا يمكن التراجع عن هذا الإجراء.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.clearHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم مسح السجل بنجاح'),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _exportHistory() {
    // يمكن إضافة وظيفة تصدير السجل
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة ميزة تصدير السجل قريباً'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) {
      return 'اليوم ${DateFormat('HH:mm').format(date)}';
    } else if (dateDay == yesterday) {
      return 'أمس ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }
}
