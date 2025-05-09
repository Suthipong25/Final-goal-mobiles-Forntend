import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import '../services/goal_service.dart';
import '../models/goal_model.dart';

// หน้าจอสำหรับเพิ่มธุรกรรม
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key, required String goalId}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController amountController = TextEditingController();
  Goal? selectedGoal;  // เป้าหมายที่ผู้ใช้เลือก
  bool isLoading = false;  // สถานะการโหลดข้อมูล
  bool isDeposit = true;  // ค่าตัวแปรที่เก็บประเภทธุรกรรม (ฝากหรือถอน)

  List<Goal> goals = [];  // รายการของเป้าหมายทั้งหมด
  bool isGoalLoading = true;  // สถานะการโหลดเป้าหมาย

  @override
  void initState() {
    super.initState();
    _loadGoals();  // โหลดเป้าหมายทั้งหมด
  }

  // ฟังก์ชันโหลดเป้าหมายทั้งหมด
  Future<void> _loadGoals() async {
    try {
      final fetchedGoals = await GoalService.fetchGoals();
      setState(() {
        goals = fetchedGoals;
        isGoalLoading = false;  // เปลี่ยนสถานะการโหลด
      });
    } catch (e) {
      setState(() => isGoalLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดเป้าหมาย: $e')),
      );
    }
  }

  // ฟังก์ชันเพิ่มธุรกรรม
  Future<void> _addTransaction() async {
    final text = amountController.text.trim();
    // ตรวจสอบว่าผู้ใช้ได้เลือกเป้าหมายและกรอกจำนวนเงิน
    if (text.isEmpty || selectedGoal?.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกเป้าหมายและกรอกจำนวนเงิน')),
      );
      return;
    }

    final amount = double.tryParse(text) ?? -1;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกจำนวนเงินที่ถูกต้อง')),
      );
      return;
    }

    setState(() => isLoading = true);  // ตั้งค่าสถานะกำลังโหลด
    final success = await TransactionService.addTransaction(
      selectedGoal!.id!,  // ใช้ goalId ที่เลือก
      isDeposit ? 'deposit' : 'withdraw',  // ระบุประเภทธุรกรรม (ฝาก/ถอน)
      amount,
    );
    setState(() => isLoading = false);  // ตั้งค่าสถานะโหลดเสร็จแล้ว

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เพิ่มธุรกรรมสำเร็จ')),
      );
      Navigator.pop(context, true);  // กลับไปยังหน้าก่อนหน้า
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เพิ่มธุรกรรมไม่สำเร็จ')),
      );
    }
  }

  // ฟังก์ชันสำหรับสร้างรูปแบบ InputDecoration ที่มีพื้นหลังสีขาว
  InputDecoration _whiteFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: Colors.white,
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มธุรกรรม'),  // ชื่อหัวข้อบน AppBar
        backgroundColor: Colors.blue[800],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('เลือกเป้าหมาย', style: TextStyle(fontSize: 16)),  // ข้อความแสดงหัวข้อ
                const SizedBox(height: 8),
                isGoalLoading
                    ? const Center(child: CircularProgressIndicator())  // กำลังโหลดเป้าหมาย
                    : goals.isEmpty
                        ? const Text('ยังไม่มีเป้าหมาย กรุณาสร้างก่อนเพิ่มธุรกรรม')  // ไม่มีเป้าหมาย
                        : DropdownButtonFormField<Goal>(
                            value: selectedGoal,  // ค่าเป้าหมายที่เลือก
                            decoration: _whiteFieldDecoration('เลือกเป้าหมาย'),  // รูปแบบการแสดงผล
                            isExpanded: true,
                            style: const TextStyle(color: Colors.black),
                            dropdownColor: Colors.white,
                            iconEnabledColor: Colors.black,
                            items: goals
                                .map((g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(g.title),  // แสดงชื่อเป้าหมาย
                                    ))
                                .toList(),
                            onChanged: (g) => setState(() => selectedGoal = g),  // เปลี่ยนเป้าหมายที่เลือก
                          ),
                const SizedBox(height: 16),
                const Text('จำนวนเงิน', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),  // กรอกจำนวนเงินที่สามารถใส่จุดทศนิยมได้
                  decoration: _whiteFieldDecoration('กรอกจำนวนเงิน'),  // รูปแบบการแสดงผล
                ),
                const SizedBox(height: 16),
                const Text('ประเภทธุรกรรม', style: TextStyle(fontSize: 16)),  // หัวข้อเลือกประเภทธุรกรรม
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        value: true,
                        groupValue: isDeposit,  // ค่ากลุ่มตัวแปรฝาก/ถอน
                        title: const Text('ฝาก'),
                        onChanged: (v) => setState(() => isDeposit = v!),  // เลือกฝาก
                        activeColor: Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        value: false,
                        groupValue: isDeposit,
                        title: const Text('ถอน'),
                        onChanged: (v) => setState(() => isDeposit = v!),  // เลือกถอน
                        activeColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _addTransaction,  // เมื่อกำลังโหลดจะไม่สามารถคลิกได้
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)  // หากกำลังโหลดจะแสดงวงกลมหมุน
                      : const Text('ยืนยัน', style: TextStyle(fontSize: 18)),  // ข้อความในปุ่ม
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
