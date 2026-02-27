import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/scan_result.dart';

class VirusTotalService {
  static const String _baseUrl = 'https://www.virustotal.com/api/v3';
  final String _apiKey;
  bool _isValidKey = false;
  bool _isInitialized = false;

  // Getter للتحقق من صحة المفتاح
  bool get isValid => _isValidKey && _isInitialized;

  VirusTotalService(this._apiKey) {
    _validateApiKey();
  }

  // التحقق من صحة مفتاح API
  Future<void> _validateApiKey() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ip_addresses/8.8.8.8'),
        headers: {'x-apikey': _apiKey},
      ).timeout(const Duration(seconds: 5));
      
      _isValidKey = response.statusCode == 200;
      print('✅ مفتاح API صالح: $_isValidKey');
    } catch (e) {
      _isValidKey = false;
      print('❌ خطأ في التحقق من مفتاح API: $e');
    } finally {
      _isInitialized = true;
    }
  }

  // دالة للتحقق من صحة المفتاح (للإستخدام الخارجي)
  Future<bool> validateApiKey() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/ip_addresses/8.8.8.8'),
        headers: {'x-apikey': _apiKey},
      ).timeout(const Duration(seconds: 5));
      
      _isValidKey = response.statusCode == 200;
      return _isValidKey;
    } catch (e) {
      _isValidKey = false;
      return false;
    } finally {
      _isInitialized = true;
    }
  }

  // دالة لفحص الرابط
  Future<ScanResult?> scanUrl(String url) async {
    try {
      print('🔍 بدء فحص الرابط: $url');
      
      // التحقق من صحة الرابط أولاً
      if (!isValidUrl(url)) {
        return _createErrorResult(url, 'الرابط غير صحيح');
      }

      // 1. أولاً: إرسال الرابط للفحص
      final scanResponse = await http.post(
        Uri.parse('$_baseUrl/urls'),
        headers: {
          'x-apikey': _apiKey,
          'accept': 'application/json',
        },
        body: {'url': url},
      ).timeout(const Duration(seconds: 10));

      if (scanResponse.statusCode != 200) {
        print('❌ فشل إرسال الرابط: ${scanResponse.statusCode} - ${scanResponse.body}');
        if (scanResponse.statusCode == 401) {
          return _createErrorResult(url, 'مفتاح API غير صالح');
        }
        return _createErrorResult(url, 'فشل الاتصال بخدمة الفحص');
      }

      final scanData = jsonDecode(scanResponse.body);
      final analysisId = scanData['data']['id'];
      print('✅ تم إرسال الرابط، معرف التحليل: $analysisId');

      // 2. انتظار قليل لبدء التحليل
      await Future.delayed(const Duration(seconds: 3));

      // 3. جلب نتيجة الفحص
      final reportResponse = await http.get(
        Uri.parse('$_baseUrl/analyses/$analysisId'),
        headers: {'x-apikey': _apiKey},
      ).timeout(const Duration(seconds: 10));

      if (reportResponse.statusCode == 200) {
        final reportData = jsonDecode(reportResponse.body);
        print('✅ تم استلام نتيجة الفحص بنجاح');
        return _parseVirusTotalResponse(url, reportData);
      } else {
        print('❌ فشل جلب نتيجة الفحص: ${reportResponse.statusCode}');
        return _createErrorResult(url, 'فشل جلب نتيجة الفحص');
      }
    } catch (e) {
      print('❌ خطأ في الاتصال بـ VirusTotal: $e');
      return _createErrorResult(url, 'حدث خطأ في الاتصال: ${e.toString()}');
    }
  }

  // دالة لتحليل نتيجة VirusTotal
  ScanResult _parseVirusTotalResponse(String url, Map<String, dynamic> data) {
    try {
      final stats = data['data']['attributes']['stats'];
      
      int malicious = stats['malicious'] ?? 0;
      int suspicious = stats['suspicious'] ?? 0;
      int harmless = stats['harmless'] ?? 0;
      int undetected = stats['undetected'] ?? 0;
      int timeout = stats['timeout'] ?? 0;
      
      int total = malicious + suspicious + harmless + undetected + timeout;
      double score = total > 0 ? ((harmless) / total * 100) : 0;
      
      bool isSafe = malicious == 0;

      List<String> details = [];
      
      if (malicious > 0) {
        details.add('⚠️ تم اكتشاف $malicious محرك أمان يصنف الرابط كضار');
      }
      if (suspicious > 0) {
        details.add('⚠️ $suspicious محرك أمان يشتبه في الرابط');
      }
      if (harmless > 0) {
        details.add('✅ $harmless محرك أمان يعتبر الرابط آمناً');
      }
      if (undetected > 0) {
        details.add('ℹ️ $undetected محرك لم يتمكن من التحليل');
      }
      if (timeout > 0) {
        details.add('⏱️ $timeout محرك انتهت مهلة تحليله');
      }
      
      if (total > 0) {
        details.add('📊 تم الفحص باستخدام $total محرك أمان');
      }

      // إضافة تفاصيل إضافية عن الرابط
      try {
        final uri = Uri.parse(url);
        details.add('🌐 النطاق: ${uri.host}');
      } catch (e) {}

      // رسالة مناسبة حسب النتيجة
      String message;
      if (malicious == 0) {
        message = 'الرابط آمن - لم يتم اكتشاف أي تهديدات';
      } else if (malicious < 3) {
        message = 'تحذير: تم اكتشاف بعض التهديدات';
      } else {
        message = 'خطر! تم اكتشاف عدة تهديدات';
      }

      return ScanResult(
        id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
        link: url,
        safe: isSafe,
        score: score.toInt(),
        message: message,
        details: details,
        timestamp: DateTime.now(),
        rawData: data,
        threatsCount: malicious,
      );
    } catch (e) {
      print('❌ خطأ في تحليل النتائج: $e');
      return _createErrorResult(url, 'خطأ في تحليل النتائج');
    }
  }

  // دالة لإنشاء نتيجة خطأ
  ScanResult _createErrorResult(String url, String errorMessage) {
    return ScanResult(
      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
      link: url,
      safe: null,
      score: 0,
      message: 'تعذر الفحص',
      details: [
        '⚠️ $errorMessage',
        'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى'
      ],
      timestamp: DateTime.now(),
    );
  }

  // دالة للتحقق من صحة الرابط
  bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    // تنظيف الرابط
    url = url.trim();
    
    // التحقق الأساسي
    if (!url.contains('.')) return false;
    if (url.contains(' ')) return false;
    
    return true;
  }

  // دالة لتنسيق الرابط (إضافة https:// إذا لزم الأمر)
  String formatUrl(String url) {
    url = url.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return 'https://$url';
  }
}