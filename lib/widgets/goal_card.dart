import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../utils/formatter.dart';
import '../screens/transaction_screen.dart';

class GoalCard extends StatefulWidget {
  // รับข้อมูลเป้าหมาย (Goal), ฟังก์ชั่นสำหรับลบและแก้ไข
  final Goal goal;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const GoalCard({
    required this.goal,
    required this.onDelete,
    required this.onEdit,
    Key? key, required Null Function() onViewTransaction,
  }) : super(key: key);

  @override
  _GoalCardState createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  @override
  Widget build(BuildContext context) {
    // คำนวณเปอร์เซ็นต์ความคืบหน้าของเป้าหมาย
    double progress = widget.goal.currentAmount / widget.goal.targetAmount;
    // คำนวณเวลาที่เหลือจนถึงกำหนด
    String remainingTime = _calculateRemainingTime(widget.goal.dueDate);

    return Card(
      margin: EdgeInsets.all(10), // ระยะห่างจากขอบ
      color: const Color.fromARGB(255, 255, 255, 255), // สีพื้นหลังของการ์ด
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // มุมของการ์ดที่มน
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // จัดแนวข้อความทางซ้าย
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.goal.title, // แสดงชื่อเป้าหมาย
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // สีข้อความ
                    ),
                  ),
                ),
                // ปุ่มสำหรับแก้ไขเป้าหมาย
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: widget.onEdit,
                ),
                // ปุ่มสำหรับลบเป้าหมาย
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            SizedBox(height: 8),
            // แถบโปรเกรสที่แสดงความคืบหน้าของเป้าหมาย
            LinearProgressIndicator(
              value: progress.clamp(0, 1), // ค่าที่ใช้แสดงความคืบหน้า
              minHeight: 10, // ความสูงของแถบโปรเกรส
              backgroundColor: const Color.fromARGB(255, 255, 255, 255), // สีพื้นหลัง
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green), // สีแถบที่เติม
            ),
            SizedBox(height: 8),
            // แสดงจำนวนเงินเป้าหมาย
            Text(
              'เป้าหมาย: ${Formatter.formatCurrency(widget.goal.targetAmount)}',
              style: TextStyle(color: Colors.black), // สีข้อความ
            ),
            // แสดงจำนวนเงินที่สะสมได้
            Text(
              'สะสมแล้ว: ${Formatter.formatCurrency(widget.goal.currentAmount)}',
              style: TextStyle(color: Colors.black), // สีข้อความ
            ),
            // แสดงวันที่ครบกำหนด
            Text(
              'ครบกำหนด: ${Formatter.formatDate(widget.goal.dueDate)}',
              style: TextStyle(color: Colors.black), // สีข้อความ
            ),
            // แสดงระยะเวลาที่เหลือจนถึงกำหนด
            Text(
              'ระยะเวลาที่เหลือ: $remainingTime',
              style: TextStyle(color: Colors.black), // สีข้อความ
            ),
            SizedBox(height: 10),
            // ปุ่มสำหรับดูประวัติธุรกรรม
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: Icon(Icons.history, color: Colors.blue),
                label: Text(
                  'ดูประวัติธุรกรรม',
                  style: TextStyle(color: Colors.blue), // สีข้อความ
                ),
                onPressed: () {
                  // ถ้า goal.id ไม่เป็น null ให้ไปหน้าประวัติธุรกรรม
                  if (widget.goal.id != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionScreen(goalId: widget.goal.id!),
                      ),
                    );
                  } else {
                    // ถ้า goal.id เป็น null แสดงข้อความเตือน
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ไม่พบ ID ของเป้าหมายนี้')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชั่นคำนวณเวลาที่เหลือจนถึงวันครบกำหนด
  String _calculateRemainingTime(DateTime dueDate) {
    final now = DateTime.now(); // วันที่ปัจจุบัน
    final difference = dueDate.difference(now); // คำนวณความต่างระหว่างวันที่ครบกำหนดกับปัจจุบัน

    if (difference.isNegative) {
      return 'ครบกำหนดแล้ว'; // ถ้าเวลาผ่านไปแล้ว
    } else {
      return '${difference.inDays} วัน'; // แสดงจำนวนวันที่เหลือ
    }
  }
}
