import 'dart:convert';
import 'package:http/browser_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionService {
  // เส้นทาง API สำหรับธุรกรรม
  static const String _baseUrl = 'http://localhost:5000/api/transactions';
  static final BrowserClient _client = BrowserClient()..withCredentials = true;

  /// โหลดรายการธุรกรรมทั้งหมดของ goalId นั้น ๆ
  static Future<List<TransactionModel>> fetchTransactions(String goalId) async {
    final uri = Uri.parse('$_baseUrl/$goalId'); // สร้าง URL สำหรับการดึงข้อมูลธุรกรรมตาม goalId
    final response = await _client.get(uri, headers: {
      'Content-Type': 'application/json', // ส่งค่า header สำหรับประเภทของข้อมูล
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>; // แปลงข้อมูล JSON ที่ได้รับจาก API
      final list = data['transactions'] as List<dynamic>?; // ตรวจสอบว่ามีข้อมูลธุรกรรมหรือไม่
      if (list == null) {
        throw Exception('ไม่พบข้อมูลธุรกรรมในเซิร์ฟเวอร์');
      }
      // แปลงรายการธุรกรรมเป็นแบบ Model
      return list
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: กรุณาเข้าสู่ระบบก่อน');
    } else {
      throw Exception('โหลดธุรกรรมไม่สำเร็จ (${response.statusCode})');
    }
  }

  /// เพิ่มธุรกรรม (deposit หรือ withdraw)
  static Future<bool> addTransaction(
    String goalId,
    String transactionType,
    double amount,
  ) async {
    // ดึง userId จาก SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      throw Exception('กรุณาล็อกอินก่อนที่จะทำธุรกรรม');
    }

    // ตรวจสอบข้อมูลก่อนส่ง
    if (goalId.isEmpty ||
        (transactionType != 'deposit' && transactionType != 'withdraw') ||
        amount <= 0) {
      throw Exception('ข้อมูลธุรกรรมไม่ถูกต้อง');
    }

    final uri = Uri.parse(_baseUrl);
    final body = json.encode({
      'goalId': goalId,
      'transactionType': transactionType,
      'amount': amount,
      'userId': userId,
    });

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 201) {
      return true; // ถ้าส่งข้อมูลสำเร็จ
    } else if (response.statusCode == 400) {
      final err = json.decode(response.body);
      print('Error adding transaction: ${response.statusCode} $err');
      return false; // ถ้าเกิดข้อผิดพลาดที่ฝั่งเซิร์ฟเวอร์
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: กรุณาเข้าสู่ระบบก่อน');
    } else {
      print('Error adding transaction: ${response.statusCode} ${response.body}');
      return false; // ถ้าเกิดข้อผิดพลาดอื่นๆ
    }
  }

  /// สตรีมอัปเดตธุรกรรมแบบเรียลไทม์ทุก 5 วินาที
  static Stream<List<TransactionModel>> getTransactionsStream(String goalId) {
    return Stream.periodic(const Duration(seconds: 5)) // สตรีมทุก 5 วินาที
        .asyncMap((_) => fetchTransactions(goalId)); // ดึงข้อมูลธุรกรรมใหม่ๆ ทุกครั้ง
  }
}
