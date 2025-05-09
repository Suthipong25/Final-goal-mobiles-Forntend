import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';  // นำเข้า AuthService สำหรับการเรียกใช้งาน API
import 'login_screen.dart';  // ใช้สำหรับนำทางไปยัง LoginScreen หลังจากการสมัคร

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();  // ใช้ key สำหรับการตรวจสอบข้อมูลในฟอร์ม

  // ตัวควบคุมสำหรับช่องกรอกข้อมูล
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;  // ใช้แสดงสถานะการโหลดเมื่อกำลังสมัครสมาชิก

  // ฟังก์ชันสำหรับสมัครสมาชิก
  void _register() async {
    setState(() => _isLoading = true);  // ตั้งค่าสถานะให้เป็นกำลังโหลด

    // เรียกใช้ API สำหรับการสมัครสมาชิก
    final user = await AuthService.register(
      _usernameController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (user != null && user.id.isNotEmpty) {
      // ถ้าการสมัครสำเร็จ ให้บันทึก userId ใน SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userId', user.id);

      // นำทางไปยังหน้าล็อกอินหลังจากสมัครสำเร็จ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      // ถ้าการสมัครล้มเหลว ให้แสดงข้อความผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('สมัครล้มเหลว')),  // ข้อความแสดงเมื่อสมัครไม่สำเร็จ
      );
    }

    setState(() => _isLoading = false);  // ตั้งค่าสถานะให้เป็นไม่กำลังโหลด
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('สมัครสมาชิก')),  // ชื่อของหน้าจอ
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),  // การตั้งค่าระยะห่างภายในหน้าจอ
        child: Card(
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),  // ทำให้มุมของการ์ดมีความโค้ง
          child: Padding(
            padding: EdgeInsets.all(16.0),  // การตั้งค่าระยะห่างภายในการ์ด
            child: Form(
              key: _formKey,  // กำหนด key ให้กับฟอร์ม
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    'assets/images/finalciallogo.png',  // โลโก้ของแอป
                    height: 120,  // ขนาดของโลโก้
                  ),
                  const SizedBox(height: 24),
                  // ช่องกรอกข้อมูลสำหรับ Username พร้อมการตรวจสอบ
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(labelText: 'Username'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'กรุณากรอกชื่อผู้ใช้' : null,
                  ),
                  const SizedBox(height: 16),
                  // ช่องกรอกข้อมูลสำหรับ Email พร้อมการตรวจสอบ
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกอีเมล';  // ข้อความเมื่อไม่ได้กรอกอีเมล
                      }
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');  // ตรวจสอบรูปแบบอีเมล
                      if (!emailRegex.hasMatch(value)) {
                        return 'รูปแบบอีเมลไม่ถูกต้อง';  // ข้อความหากรูปแบบอีเมลไม่ถูกต้อง
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // ช่องกรอกข้อมูลสำหรับ Password พร้อมการตรวจสอบ
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,  // ซ่อนตัวอักษรในช่องกรอกรหัสผ่าน
                    decoration: InputDecoration(labelText: 'Password'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'กรุณากรอกรหัสผ่าน' : null,
                  ),
                  const SizedBox(height: 24),
                  // ถ้ากำลังโหลด จะแสดงวงกลมหมุน
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            // ตรวจสอบข้อมูลในฟอร์มก่อนทำการสมัคร
                            if (_formKey.currentState!.validate()) {
                              _register();
                            }
                          },
                          child: Text('Register'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 48),  // ขนาดของปุ่ม
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                  const SizedBox(height: 16),
                  // นำทางไปยังหน้าล็อกอินถ้ามีบัญชีอยู่แล้ว
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    ),
                    child: Text('มีบัญชีแล้ว? เข้าสู่ระบบ'),  // ข้อความสำหรับคนที่มีบัญชีแล้ว
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
