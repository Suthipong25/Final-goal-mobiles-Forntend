import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/goal_card.dart';
import '../services/goal_service.dart';
import '../models/goal_model.dart';
import 'add_transaction_screen.dart';
import 'add_edit_goal_screen.dart';
import 'transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;  // ชื่อผู้ใช้ที่เก็บจาก SharedPreferences
  List<Goal> goals = [];  // รายการเป้าหมายทั้งหมด
  bool isLoading = true;  // ตัวแปรเพื่อแสดงสถานะการโหลดข้อมูล

  @override
  void initState() {
    super.initState();
    _loadUserInfo();  // โหลดข้อมูลผู้ใช้เมื่อเริ่มต้น
    _loadGoals();  // โหลดข้อมูลเป้าหมายเมื่อเริ่มต้น
  }

  // ฟังก์ชันเพื่อโหลดข้อมูลผู้ใช้จาก SharedPreferences
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');  // เก็บชื่อผู้ใช้จาก SharedPreferences
    });
  }

  // ฟังก์ชันเพื่อโหลดข้อมูลเป้าหมายจาก API
  Future<void> _loadGoals() async {
    setState(() => isLoading = true);  // ตั้งค่าสถานะให้กำลังโหลด
    try {
      final fetchedGoals = await GoalService.fetchGoals();  // ดึงข้อมูลเป้าหมาย
      setState(() {
        goals = fetchedGoals;  // อัปเดตรายการเป้าหมาย
      });
    } catch (e) {
      print('Error fetching goals: $e');  // แสดงข้อผิดพลาดในกรณีดึงข้อมูลไม่สำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการดึงข้อมูลเป้าหมาย')),
      );
    } finally {
      setState(() => isLoading = false);  // ตั้งค่าสถานะให้โหลดเสร็จแล้ว
    }
  }

  // ฟังก์ชันเพื่อเปลี่ยนหน้าไปยังหน้าจอเพิ่มธุรกรรม
  Future<void> _navigateToAddTransaction(String goalId) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddTransactionScreen(goalId: goalId)),
    );
    if (result == true) {
      _loadGoals();  // โหลดข้อมูลเป้าหมายใหม่หลังจากเพิ่มธุรกรรม
    }
  }

  // ฟังก์ชันเพื่อเปลี่ยนหน้าไปยังหน้าจอเพิ่มเป้าหมาย
  Future<void> _navigateToAddGoal({Goal? goalToEdit}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddGoalScreen(goalToEdit: goalToEdit),  // ส่งข้อมูล goalToEdit หากมี
      ),
    );
    if (result == true) {
      _loadGoals();  // โหลดข้อมูลเป้าหมายใหม่หลังจากเพิ่มหรือแก้ไข
    }
  }

  // ฟังก์ชันเพื่อลบเป้าหมาย
  Future<void> _deleteGoal(String goalId) async {
    final confirm = await showDialog<bool>(  // แสดงการยืนยันการลบ
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบเป้าหมายนี้หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;  // หากยกเลิกให้ไม่ทำอะไร

    setState(() => isLoading = true);  // ตั้งค่าสถานะการโหลด
    try {
      final success = await GoalService.deleteGoal(goalId);  // ลบเป้าหมายจาก API
      if (success) {
        setState(() {
          goals.removeWhere((g) => g.id == goalId);  // ลบเป้าหมายจากรายการ
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ลบเป้าหมายสำเร็จ')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ลบไม่สำเร็จ กรุณาลองใหม่')));
      }
    } catch (e) {
      print('Error deleting goal: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เกิดข้อผิดพลาดในการลบเป้าหมาย')));
    } finally {
      setState(() => isLoading = false);  // ตั้งค่าสถานะให้โหลดเสร็จ
    }
  }

  // ฟังก์ชันเพื่อไปยังหน้าจอแสดงประวัติธุรกรรมของเป้าหมาย
  void _navigateToTransactionScreen(String goalId) {
    if (goalId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TransactionScreen(goalId: goalId)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ยังไม่มีเป้าหมายให้ดูประวัติธุรกรรม')));
    }
  }

  // ฟังก์ชันเพื่อทำการล็อกเอ้า
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();  // เคลียร์ข้อมูลใน SharedPreferences
    Navigator.pushReplacementNamed(context, '/login');  // เปลี่ยนหน้าไปที่หน้า login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),  // พื้นหลังสีขาว
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 119, 255),  // สีพื้นหลังของ AppBar
        title: const Text('My Financial Goals'),  // ชื่อแอป
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),  // ปุ่มล็อกเอ้า
            onPressed: _logout,  // เมื่อคลิกจะออกจากระบบ
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())  // แสดงโลดดิ้งหากข้อมูลกำลังโหลด
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (username != null) ...[
                    Text(
                      'สวัสดี, $username 👋',  // แสดงชื่อผู้ใช้
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: goals.isEmpty
                        ? const Center(child: Text("ยังไม่มีเป้าหมาย"))  // หากไม่มีเป้าหมายให้แสดงข้อความ
                        : ListView.builder(
                            itemCount: goals.length,
                            itemBuilder: (context, index) => Card(
                              color: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: GoalCard(
                                goal: goals[index],  // ส่งเป้าหมายแต่ละตัวไปยัง GoalCard
                                onEdit: () => _navigateToAddGoal(goalToEdit: goals[index]),  // แก้ไขเป้าหมาย
                                onDelete: () {
                                  if (goals[index].id != null && goals[index].id!.isNotEmpty) {
                                    _deleteGoal(goals[index].id!);  // ลบเป้าหมาย
                                  }
                                },
                                onViewTransaction: () {
                                  if (goals[index].id != null && goals[index].id!.isNotEmpty) {
                                    _navigateToTransactionScreen(goals[index].id!);  // ดูประวัติธุรกรรม
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('ยังไม่มีเป้าหมายเพื่อดูประวัติธุรกรรม')));
                                  }
                                },
                              ),
                            ),
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'add_transaction_fab',
            onPressed: () {
              if (goals.isNotEmpty && goals[0].id != null && goals[0].id!.isNotEmpty) {
                _navigateToAddTransaction(goals[0].id!);  // เพิ่มธุรกรรม
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ยังไม่มีเป้าหมายเพื่อเพิ่มธุรกรรม')));  
              }
            },
            icon: const Icon(Icons.attach_money),
            label: const Text('เพิ่มธุรกรรม'),
            backgroundColor: Colors.blue,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add_goal_fab',
            onPressed: () => _navigateToAddGoal(),  // เพิ่มเป้าหมาย
            icon: const Icon(Icons.flag),
            label: const Text('เพิ่มเป้าหมาย'),
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}
