import 'dart:convert';
import 'package:http/browser_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// คลาส ApiService ใช้สำหรับการติดต่อกับ API
class ApiService {
  // กำหนด URL พื้นฐานของ API
  static const String baseUrl = "http://localhost:5000/api";
  // สร้าง client สำหรับการติดต่อกับ API โดยสามารถส่ง cookies และ headers ได้
  static final BrowserClient client = BrowserClient()..withCredentials = true;

  // ฟังก์ชันเพื่อดึง userId จาก SharedPreferences ซึ่งใช้สำหรับการยืนยันตัวตน
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // ฟังก์ชันสำหรับส่งคำขอ GET ไปยัง API
  static Future<dynamic> get(String endpoint) async {
    // ดึง userId จาก SharedPreferences
    final userId = await getUserId();
    
    // ตรวจสอบว่า userId มีค่า ถ้าไม่มีจะโยนข้อผิดพลาด
    if (userId == null) {
      print('Error: User is not authenticated');
      throw Exception('User is not authenticated');
    }

    // ส่งคำขอ GET ไปยัง API
    final response = await client.get(Uri.parse("$baseUrl$endpoint"));
    
    // ตรวจสอบสถานะของการตอบกลับ (200-299 หมายถึงสำเร็จ)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // แปลงข้อมูลที่ได้รับเป็น JSON และส่งคืน
      return json.decode(response.body);
    }
    // ถ้าตอบกลับไม่สำเร็จ โยนข้อผิดพลาด
    throw Exception('GET $endpoint failed: ${response.statusCode}');
  }

  // ฟังก์ชันสำหรับส่งคำขอ POST ไปยัง API
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    // ดึง userId จาก SharedPreferences
    final userId = await getUserId();
    
    // ตรวจสอบว่า userId มีค่า ถ้าไม่มีจะโยนข้อผิดพลาด
    if (userId == null) {
      print('Error: User is not authenticated');
      throw Exception('User is not authenticated');
    }

    // เพิ่ม userId ลงใน body ของ request
    body['userId'] = userId;

    // ส่งคำขอ POST ไปยัง API
    final response = await client.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body), // แปลงข้อมูล body เป็น JSON
    );

    // ตรวจสอบสถานะของการตอบกลับ (200-299 หมายถึงสำเร็จ)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // แปลงข้อมูลที่ได้รับเป็น JSON และส่งคืน
      return json.decode(response.body);
    }
    // ถ้าตอบกลับไม่สำเร็จ โยนข้อผิดพลาด
    throw Exception('POST $endpoint failed: ${response.statusCode}');
  }
}
