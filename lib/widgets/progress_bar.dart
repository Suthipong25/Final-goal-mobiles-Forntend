import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  // รับค่า progress ซึ่งเป็นเปอร์เซ็นต์ของความคืบหน้า
  final double progress;

  // Constructor ที่รับ progress
  ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // ให้แนวตั้งของเนื้อหาชิดซ้าย
      children: [
        // ข้อความที่แสดงเปอร์เซ็นต์ความคืบหน้า
        Text('${progress.toStringAsFixed(2)}% Complete'),
        SizedBox(height: 5), // ช่องว่างระหว่างข้อความและ progress bar
        // LinearProgressIndicator ที่แสดงความคืบหน้า
        LinearProgressIndicator(
          value: progress / 100, // ค่า progress ที่แบ่งด้วย 100 เพื่อให้เป็นสเกล 0.0 - 1.0
          backgroundColor: const Color.fromARGB(255, 255, 255, 255), // กำหนดสีพื้นหลังของ Progress Bar
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // กำหนดสีของ Progress ที่เต็มไป
        ),
      ],
    );
  }
}
