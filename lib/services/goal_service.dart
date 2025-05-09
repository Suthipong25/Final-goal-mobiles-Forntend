  import 'dart:convert';
  import 'package:http/browser_client.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../models/goal_model.dart';

  class GoalService {
    static const String baseUrl = 'http://localhost:5000/api/goals'; // URL สำหรับติดต่อกับ API
    static final BrowserClient client = BrowserClient()..withCredentials = true; // Client สำหรับทำ HTTP requests

    // ดึง Goal ตาม userId
    static Future<List<Goal>> fetchGoals() async {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId'); // ดึง userId จาก SharedPreferences
      if (userId == null) {
        throw Exception('User not logged in'); // หากไม่มี userId ใน SharedPreferences แสดงว่าไม่ได้ล็อกอิน
      }

      final response = await client.get(
        Uri.parse('$baseUrl/$userId'), // ใช้ URL ที่มี userId
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode != 200) {
        print('Error ${response.statusCode}: ${response.body}');
        throw Exception('Failed to load goals'); // หาก API ไม่ตอบกลับสถานะ 200 จะเกิดข้อผิดพลาด
      }

      // ตรวจสอบว่าข้อมูลที่ได้รับเป็น List หรือไม่
      try {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse is List) {
          return decodedResponse
              .map((item) => Goal.fromJson(item as Map<String, dynamic>)) // แปลงข้อมูล JSON เป็น Goal Model
              .toList();
        } else {
          throw Exception('Expected a list of goals'); // ถ้าไม่เป็น List จะเกิดข้อผิดพลาด
        }
      } catch (e) {
        print('Error decoding response: $e');
        throw Exception('Error loading goals'); // หากเกิดข้อผิดพลาดในการแปลงข้อมูล
      }
    }

    // เพิ่ม Goal ใหม่
    static Future<bool> addGoal(Goal goal) async {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId'); // ดึง userId จาก SharedPreferences
      if (userId == null) {
        throw Exception('User not logged in'); // ถ้าไม่ได้ล็อกอินจะไม่สามารถเพิ่ม Goal ได้
      }

      final response = await client.post(
        Uri.parse('$baseUrl/$userId'), // ส่ง POST request ไปยัง API เพื่อเพิ่ม Goal
        headers: {"Content-Type": "application/json"},
        body: json.encode(goal.toJson()), // แปลง Goal เป็น JSON
      );

      return response.statusCode == 201; // หากสถานะการตอบกลับเป็น 201 แสดงว่าการเพิ่ม Goal สำเร็จ
    }

    // ลบ Goal
    static Future<bool> deleteGoal(String goalId) async {
      final response = await client.delete(
        Uri.parse('$baseUrl/$goalId'), // ส่ง DELETE request ไปยัง API เพื่อการลบ Goal
        headers: {"Content-Type": "application/json"},
      );
      return response.statusCode == 200; // หากสถานะการตอบกลับเป็น 200 แสดงว่าการลบ Goal สำเร็จ
    }

    // แก้ไข Goal
    static Future<bool> updateGoal(Goal goal) async {
      if (goal.id == null) {
        throw Exception("Goal ID is required for update"); // ต้องมี Goal ID เพื่อทำการอัปเดต
      }

      final response = await client.put(
        Uri.parse('$baseUrl/${goal.id}'), // ส่ง PUT request ไปยัง API เพื่ออัปเดต Goal
        headers: {"Content-Type": "application/json"},
        body: json.encode(goal.toJson()), // แปลง Goal เป็น JSON
      );

      return response.statusCode == 200; // หากสถานะการตอบกลับเป็น 200 แสดงว่าการอัปเดต Goal สำเร็จ
    }
  }
