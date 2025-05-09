import 'dart:convert';
import 'package:http/browser_client.dart';
import '../models/user_model.dart';

class AuthService {
  static const _baseUrl = 'http://localhost:5000/api'; // URL ของ API สำหรับการจัดการการเข้าสู่ระบบและสมัครสมาชิก

  /// สร้าง client เดียวไว้ใช้ส่ง cookie ได้ในทุก request
  static final BrowserClient client = BrowserClient()..withCredentials = true; // Client ที่ใช้ในทุกคำขอ

  /// Login
  static Future<User?> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/login'), // ส่งคำขอ POST ไปยัง /login API
      headers: {'Content-Type': 'application/json'}, // ตั้งค่า header เป็น application/json
      body: jsonEncode({'email': email, 'password': password}), // ส่ง email และ password ในรูปแบบ JSON
    );

    // Debugging: แสดงสถานะการตอบกลับและเนื้อหาของการตอบกลับ
    print("Login Response Status: ${response.statusCode}");
    print("Login Response Body: ${response.body}");

    if (response.statusCode == 200) { // ถ้าสถานะการตอบกลับเป็น 200 (สำเร็จ)
      final data = jsonDecode(response.body); // แปลงเนื้อหาการตอบกลับจาก JSON
      if (data['user'] != null) { // ถ้าข้อมูลผู้ใช้มีอยู่ในการตอบกลับ
        return User.fromJson(data['user']); // แปลงข้อมูลผู้ใช้เป็นอ็อบเจ็กต์ User และส่งคืน
      } else {
        print("Login failed: ${data['message']}"); // หากไม่มีข้อมูลผู้ใช้
      }
    } else {
      print("Login failed with status: ${response.statusCode}"); // หากไม่ใช่สถานะ 200
    }
    return null; // คืนค่า null หากการเข้าสู่ระบบล้มเหลว
  }

  /// Register
  static Future<User?> register(String username, String email, String password) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/register'), // ส่งคำขอ POST ไปยัง /register API
      headers: {'Content-Type': 'application/json'}, // ตั้งค่า header เป็น application/json
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }), // ส่งข้อมูลการสมัครในรูปแบบ JSON
    );

    // Debugging: แสดงสถานะการตอบกลับและเนื้อหาของการตอบกลับ
    print("Register Response Status: ${response.statusCode}");
    print("Register Response Body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) { // หากสถานะการตอบกลับเป็น 200 หรือ 201 (สำเร็จ)
      final data = jsonDecode(response.body); // แปลงเนื้อหาการตอบกลับจาก JSON
      if (data['user'] != null) { // ถ้ามีข้อมูลผู้ใช้ในการตอบกลับ
        return User.fromJson(data['user']); // แปลงข้อมูลผู้ใช้เป็นอ็อบเจ็กต์ User และส่งคืน
      } else {
        print("Registration failed: ${data['message']}"); // หากไม่มีข้อมูลผู้ใช้
      }
    } else {
      print("Registration failed with status: ${response.statusCode}"); // หากไม่ใช่สถานะ 200 หรือ 201
    }
    return null; // คืนค่า null หากการสมัครสมาชิกล้มเหลว
  }
}
