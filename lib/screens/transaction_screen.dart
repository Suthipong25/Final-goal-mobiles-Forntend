import 'package:flutter/material.dart';
import '../models/transaction_model.dart';  // นำเข้าโมเดลข้อมูลธุรกรรม
import '../services/transaction_service.dart';  // นำเข้าบริการสำหรับดึงข้อมูลธุรกรรม
import 'package:intl/intl.dart';  // นำเข้า intl สำหรับการจัดรูปแบบวันที่

class TransactionScreen extends StatefulWidget {
  final String goalId;  // รับรหัสเป้าหมายที่เกี่ยวข้องกับธุรกรรม

  const TransactionScreen({super.key, required this.goalId});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<TransactionModel> transactions = [];  // รายการธุรกรรม
  bool isLoading = true;  // ตัวแปรสำหรับแสดงสถานะการโหลดข้อมูล

  @override
  void initState() {
    super.initState();
    _loadTransactions();  // เรียกฟังก์ชันโหลดข้อมูลธุรกรรมเมื่อเริ่มต้น
  }

  // ฟังก์ชันสำหรับโหลดข้อมูลธุรกรรมจากบริการ
  Future<void> _loadTransactions() async {
    try {
      final fetched = await TransactionService.fetchTransactions(widget.goalId);  // ดึงข้อมูลธุรกรรมจาก API
      setState(() {
        transactions = fetched;  // อัปเดตสถานะของธุรกรรม
      });
    } catch (e) {
      // หากเกิดข้อผิดพลาดในการโหลดข้อมูล จะแสดงข้อความใน SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โหลดธุรกรรมไม่สำเร็จ')),
      );
    } finally {
      setState(() {
        isLoading = false;  // เปลี่ยนสถานะการโหลดเป็น false หลังจากโหลดข้อมูลเสร็จ
      });
    }
  }

  // ฟังก์ชันสำหรับจัดรูปแบบวันที่ให้เป็นรูปแบบ 'dd/MM/yyyy'
  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);  // ใช้ธีมจาก context
    return Scaffold(
      backgroundColor: Colors.white,  // ตั้งค่าพื้นหลังหน้าจอเป็นสีขาว
      appBar: AppBar(
        title: const Text('ประวัติธุรกรรม'),  // ชื่อหัวข้อของหน้าจอ
        backgroundColor: theme.primaryColor,  // ใช้สีหลักจากธีม
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())  // แสดงวงกลมหมุนระหว่างที่กำลังโหลดข้อมูล
          : transactions.isEmpty
              ? const Center(child: Text('ยังไม่มีธุรกรรม'))  // หากไม่มีธุรกรรมจะแสดงข้อความนี้
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),  // ระยะห่างของรายการ
                  itemCount: transactions.length,  // จำนวนรายการธุรกรรมที่จะแสดง
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final isDeposit = tx.type == 'deposit';  // เช็คว่าธุรกรรมเป็นการฝากหรือถอน
                    return Card(
                      color: Colors.white,
                      elevation: 4,  // ความสูงของการ์ด
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),  // มุมโค้งของการ์ด
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),  // การเว้นระยะของเนื้อหาภายใน ListTile
                        leading: CircleAvatar(
                          radius: 24,  // ขนาดของวงกลม
                          backgroundColor: isDeposit ? Colors.green : Colors.red,  // สีพื้นหลังของวงกลมตามประเภทของธุรกรรม
                          child: Icon(
                            isDeposit
                                ? Icons.arrow_downward  // ไอคอนสำหรับการฝาก
                                : Icons.arrow_upward,  // ไอคอนสำหรับการถอน
                            color: Colors.white,
                            size: 28,  // ขนาดของไอคอน
                          ),
                        ),
                        title: Text(
                          '${isDeposit ? 'ฝาก' : 'ถอน'} ${tx.amount.toStringAsFixed(2)} บาท',  // แสดงประเภทธุรกรรมและจำนวนเงิน
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),  // ระยะห่างจากข้อความหลัก
                          child: Chip(
                            label: Text(
                              formatDate(tx.date),  // แสดงวันที่ธุรกรรมในรูปแบบที่จัดไว้
                              style: theme.textTheme.bodyMedium!
                                  .copyWith(fontSize: 12),  // เปลี่ยนขนาดฟอนต์
                            ),
                            backgroundColor: theme.primaryColor.withOpacity(0.1),  // สีพื้นหลังของ Chip
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
