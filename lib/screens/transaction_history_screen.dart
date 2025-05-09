import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';  // นำเข้าโมเดลข้อมูลธุรกรรม
import '../services/transaction_service.dart';  // นำเข้า TransactionService สำหรับดึงข้อมูลธุรกรรม
import 'add_transaction_screen.dart';  // หน้าจอสำหรับเพิ่มธุรกรรมใหม่

class TransactionHistoryScreen extends StatefulWidget {
  final String goalId;  // รหัสเป้าหมายที่เกี่ยวข้องกับธุรกรรม

  const TransactionHistoryScreen({Key? key, required this.goalId}) : super(key: key);

  @override
  _TransactionHistoryScreenState createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติธุรกรรม'),  // ชื่อหัวข้อของหน้าจอ
        backgroundColor: Color.fromARGB(255, 0, 119, 255),  // สีของแถบหัวเรื่อง
      ),
      body: StreamBuilder<List<TransactionModel>>(
        // ใช้ StreamBuilder เพื่อฟังข้อมูลธุรกรรมจาก API หรือฐานข้อมูล
        stream: TransactionService.getTransactionsStream(widget.goalId),
        builder: (context, snapshot) {
          // ตรวจสอบสถานะการเชื่อมต่อ
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());  // แสดงวงกลมหมุนระหว่างที่รอข้อมูล
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));  // หากเกิดข้อผิดพลาดในการดึงข้อมูล
          }
          final transactions = snapshot.data;
          if (transactions == null || transactions.isEmpty) {
            return const Center(child: Text('ไม่มีธุรกรรม'));  // ถ้าไม่มีธุรกรรมให้แสดงข้อความนี้
          }
          return ListView.builder(
            itemCount: transactions.length,  // จำนวนรายการธุรกรรมที่แสดง
            itemBuilder: (context, index) {
              final tx = transactions[index];
              // แปลงวันที่ธุรกรรมให้อยู่ในรูปแบบที่ต้องการ
              final formattedDate = DateFormat('dd MMM yyyy HH:mm', 'th_TH').format(tx.date);
              return ListTile(
                title: Text(
                  '${tx.type == 'deposit' ? 'ฝาก' : 'ถอน'} - ${tx.amount.toStringAsFixed(2)} บาท',
                  style: TextStyle(
                    // กำหนดสีของข้อความให้แตกต่างกันตามประเภทธุรกรรม
                    color: tx.type == 'deposit' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('วันที่: $formattedDate'),  // แสดงวันที่ของธุรกรรม
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),  // ปุ่มลอยสำหรับเพิ่มธุรกรรม
        onPressed: () async {
          // เมื่อกดปุ่มลอย จะนำไปยังหน้าจอเพิ่มธุรกรรม
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionScreen(goalId: widget.goalId),  // ส่ง goalId ไปยังหน้าจอเพิ่มธุรกรรม
            ),
          );
          // หากการเพิ่มธุรกรรมเสร็จสิ้นและได้รับผลลัพธ์เป็น true
          if (result == true) {
            setState(() {});  // รีเฟรชหน้าจอเพื่อดึงข้อมูลธุรกรรมใหม่
          }
        },
      ),
    );
  }
}
