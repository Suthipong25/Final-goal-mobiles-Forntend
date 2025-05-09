import 'package:intl/intl.dart';

class Formatter {
  // ฟังก์ชั่นที่ใช้ในการแสดงผลจำนวนเงินในรูปแบบสกุลเงิน
  static String formatCurrency(double amount) {
    // สร้างตัวแปรที่ใช้ในการจัดรูปแบบจำนวนเงินโดยใช้สกุลเงินบาท (฿)
    final formatCurrency = NumberFormat.currency(locale: 'th_TH', symbol: '฿');
    return formatCurrency.format(amount); // แสดงผลจำนวนเงินตามรูปแบบที่กำหนด
  }

  // ฟังก์ชั่นที่ใช้ในการแสดงผลวันที่ในรูปแบบไทย
  static String formatDate(DateTime date) {
    // สร้างตัวแปรที่ใช้ในการจัดรูปแบบวันที่
    final formatDate = DateFormat.yMMMMd('th_TH'); // เช่น 16 เมษายน 2025
    return formatDate.format(date); // แสดงผลวันที่ตามรูปแบบที่กำหนด
  }
}
