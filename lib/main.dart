import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart'; // อย่าลืม import HomeScreen ด้วย

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th_TH', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Financial Goals',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4A90E2),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF333333)),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A90E2),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE1E1E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4A90E2)),
          ),
        ),
      ),
      initialRoute: '/', // กำหนดหน้าจอเริ่มต้น
      routes: {
        '/': (context) => LoginScreen(), // กำหนด route สำหรับหน้า Login
        '/login': (context) => LoginScreen(), // กำหนด route ซ้ำอีกครั้งก็ได้
        '/home': (context) => HomeScreen(), // เพิ่ม route สำหรับหน้า HomeScreen (ถ้ายังไม่มี)
        // เพิ่ม routes อื่นๆ ของแอปพลิเคชันของคุณที่นี่
      },
    );
  }
}