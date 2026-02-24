import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../models/user_model.dart';
import '../services/scan_service.dart';
import '../services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanController extends ChangeNotifier {
  List<ScanResult> _scanHistory = [];
  bool _isScanning = false;
  String? _lastError;
  int _dangerousScans = 0;
  
  final ScanService _scanService = ScanService();
  final LocalStorageService _storageService = LocalStorageService();

  List<ScanResult> get scanHistory => List.unmodifiable(_scanHistory);
  bool get isScanning => _isScanning;
  String? get lastError => _lastError;
  int get dangerousScans => _dangerousScans;

  ScanController() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _storageService.getScanHistory();
      _scanHistory = history;
      _calculateDangerousScans();
      notifyListeners();
    } catch (e) {
      _lastError = 'خطأ في تحميل السجل';
    }
  }

  void _calculateDangerousScans() {
    _dangerousScans = _scanHistory.where((scan) => scan.safe == false).length;
  }

  Future<ScanResult?> scanLink(String link) async {
    try {
      _isScanning = true;
      _lastError = null;
      notifyListeners();

      // التحقق من صحة الرابط
      if (!_isValidUrl(link)) {
        throw Exception('الرابط غير صحيح');
      }

      // فحص الرابط
      final result = await _scanService.scanUrl(link);

      // حفظ النتيجة في السجل
      if (result != null) {
        _scanHistory.insert(0, result);
        
        // حفظ السجل
        final prefs = await SharedPreferences.getInstance();
        final historyJson = _scanHistory.map((e) => jsonEncode(e.toJson())).toList();
        await prefs.setStringList('scanHistory', historyJson);
        
        _calculateDangerousScans();
      }

      return result;
    } catch (e) {
      _lastError = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  bool _isValidUrl(String url) {
    final urlPattern = r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$';
    final regex = RegExp(urlPattern, caseSensitive: false);
    return regex.hasMatch(url);
  }

  Future<void> clearHistory() async {
    try {
      _scanHistory.clear();
      _dangerousScans = 0;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('scanHistory');
      
      notifyListeners();
    } catch (e) {
      _lastError = 'خطأ في مسح السجل';
    }
  }

  Future<void> deleteScanResult(String id) async {
    try {
      _scanHistory.removeWhere((scan) => scan.id == id);
      _calculateDangerousScans();
      
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _scanHistory.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList('scanHistory', historyJson);
      
      notifyListeners();
    } catch (e) {
      _lastError = 'خطأ في حذف الفحص';
    }
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  ScanResult? getScanById(String id) {
    try {
      return _scanHistory.firstWhere((scan) => scan.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ScanResult> getScansByDate(DateTime date) {
    return _scanHistory.where((scan) {
      return scan.timestamp.year == date.year &&
             scan.timestamp.month == date.month &&
             scan.timestamp.day == date.day;
    }).toList();
  }

  Map<String, int> getStats() {
    int safe = _scanHistory.where((scan) => scan.safe == true).length;
    int dangerous = _scanHistory.where((scan) => scan.safe == false).length;
    int suspicious = _scanHistory.where((scan) => scan.safe == null).length;

    return {
      'total': _scanHistory.length,
      'safe': safe,
      'dangerous': dangerous,
      'suspicious': suspicious,
    };
  }
}