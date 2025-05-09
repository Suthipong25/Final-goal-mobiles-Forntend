import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';  // สำหรับการตรวจสอบการเข้าสู่ระบบ
import 'home_screen.dart';  // หน้าหลักหลังจากเข้าสู่ระบบสำเร็จ
import 'register_screen.dart';  // หน้าสมัครสมาชิกใหม่

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();  // ตัวควบคุมสำหรับ Email
  final _passwordController = TextEditingController();  // ตัวควบคุมสำหรับ Password
  bool _isLoading = false;  // สถานะการโหลดข้อมูลขณะเข้าสู่ระบบ

  // ฟังก์ชันสำหรับการเข้าสู่ระบบ
  void _login() async {
    // ตรวจสอบข้อมูลที่ผู้ใช้กรอก
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    // ตั้งค่าสถานะการโหลด
    setState(() => _isLoading = true);

    // เรียกฟังก์ชันจาก AuthService เพื่อเข้าสู่ระบบ
    final user = await AuthService.login(_emailController.text, _passwordController.text);

    if (user != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.id);  // บันทึกข้อมูลผู้ใช้ใน SharedPreferences
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));  // ไปยังหน้าหลัก
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการบันทึกข้อมูลผู้ใช้')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เข้าสู่ระบบล้มเหลว')),
      );
    }

    setState(() => _isLoading = false);  // ตั้งค่าสถานะการโหลดเป็น false เมื่อเสร็จสิ้น
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('เข้าสู่ระบบ')),  // ชื่อแอปใน AppBar
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Image.asset(
              'assets/images/finalciallogo.png',  // รูปโลโก้
              height: 150,  // ปรับขนาดรูปให้ใหญ่ขึ้น
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,  // การควบคุมการกรอกอีเมล
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,  // การควบคุมการกรอกรหัสผ่าน
              obscureText: true,  // ซ่อนรหัสผ่าน
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? CircularProgressIndicator()  // หากกำลังโหลดจะแสดง CircleProgressIndicator
                : ElevatedButton(
                    onPressed: _login,  // เรียกฟังก์ชัน _login เมื่อกดปุ่ม
                    child: Text('Login'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),  // ปรับขนาดปุ่มให้ใหญ่ขึ้น
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(fontSize: 18),  // ปรับขนาดตัวอักษร
                    ),
                  ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => RegisterScreen()),  // ไปยังหน้าสมัครสมาชิก
              ),
              child: Text('ยังไม่มีบัญชี? สมัครเลย'),
            ),
          ],
        ),
      ),
    );
  }
}
