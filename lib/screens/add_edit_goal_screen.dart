  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import '../services/goal_service.dart';
  import '../models/goal_model.dart';

  // หน้าจอสำหรับเพิ่ม/แก้ไขเป้าหมาย
  class AddGoalScreen extends StatefulWidget {
    final Goal? goalToEdit;  // ข้อมูลเป้าหมายที่ต้องการแก้ไข (ถ้ามี)

    const AddGoalScreen({Key? key, this.goalToEdit}) : super(key: key);

    @override
    _AddGoalScreenState createState() => _AddGoalScreenState();
  }

  class _AddGoalScreenState extends State<AddGoalScreen> {
    // คอนโทรลเลอร์สำหรับการกรอกข้อมูล
    final TextEditingController titleController = TextEditingController();
    final TextEditingController targetAmountController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    
    // ตัวแปรในการจัดการระยะเวลา
    String durationType = "days";
    bool isLoading = false; // ตัวแปรสำหรับแสดงสถานะกำลังโหลด
    late bool isEditing;    // ตัวแปรตรวจสอบว่าอยู่ในโหมดแก้ไขหรือไม่
    String? _userId;        // เก็บ userId ของผู้ใช้งาน

    @override
    void initState() {
      super.initState();
      // ตรวจสอบว่าเป็นการแก้ไขหรือไม่
      isEditing = widget.goalToEdit != null;
      _loadUserId();
      if (isEditing) {
        // ถ้าเป็นการแก้ไข กรอกข้อมูลจาก goal ที่รับมา
        titleController.text = widget.goalToEdit!.title;
        targetAmountController.text = widget.goalToEdit!.targetAmount.toString();
        durationController.text = widget.goalToEdit!.duration.toString();
        durationType = widget.goalToEdit!.durationType;
      }
    }

    // ฟังก์ชันโหลด userId จาก SharedPreferences
    Future<void> _loadUserId() async {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = prefs.getString('userId');
      });
    }

    // ฟังก์ชันสำหรับบันทึกข้อมูล goal
    Future<void> _saveGoal() async {
      final title = titleController.text.trim();
      final targetText = targetAmountController.text.trim();
      final durationText = durationController.text.trim();

      // ตรวจสอบข้อมูลที่กรอกเข้ามา
      if (title.isEmpty || targetText.isEmpty || durationText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
        );
        return;
      }

      final targetAmount = double.tryParse(targetText) ?? 0;
      final duration = int.tryParse(durationText) ?? 0;

      if (targetAmount <= 0 || duration <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ยอดเป้าหมายและระยะเวลาต้องมากกว่า 0')),
        );
        return;
      }

      // ถ้าไม่ได้เข้าสู่ระบบ จะไม่สามารถบันทึกได้
      if (!isEditing && (_userId == null || _userId!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้ กรุณาล็อกอินก่อน')),
        );
        return;
      }

      setState(() => isLoading = true);

      try {
        // คำนวณวันที่ครบกำหนด (dueDate) ตามระยะเวลา
        DateTime calculatedDueDate;
        if (durationType == 'days') {
          calculatedDueDate = DateTime.now().add(Duration(days: duration));
        } 
        else {
          calculatedDueDate = DateTime(
            DateTime.now().year,
            DateTime.now().month + duration,
            DateTime.now().day,
          );
        }

        // ตรวจสอบวันที่ครบกำหนด (ห้ามก่อนวันนี้)
        if (calculatedDueDate.isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ระยะเวลาที่เลือกไม่ถูกต้อง')),
          );
          setState(() => isLoading = false);
          return;
        }

        bool success;
        // ถ้าเป็นการแก้ไข จะเรียกใช้ฟังก์ชัน updateGoal
        if (isEditing) {
          final updatedGoal = Goal(
            id: widget.goalToEdit!.id,
            userId: widget.goalToEdit!.userId,
            title: title,
            targetAmount: targetAmount,
            currentAmount: widget.goalToEdit!.currentAmount,
            dueDate: calculatedDueDate,
            duration: duration,
            durationType: durationType,
          );
          success = await GoalService.updateGoal(updatedGoal);
        } else {
          // ถ้าเป็นการเพิ่ม จะสร้าง goal ใหม่
          final newGoal = Goal(
            userId: _userId!,
            title: title,
            targetAmount: targetAmount,
            currentAmount: 0,
            dueDate: calculatedDueDate,
            duration: duration,
            durationType: durationType,
          );
          success = await GoalService.addGoal(newGoal);
        }

        setState(() => isLoading = false);

        // แสดงผลลัพธ์
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEditing ? 'แก้ไขเป้าหมายสำเร็จ' : 'เพิ่มเป้าหมายสำเร็จ')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(isEditing ? 'แก้ไขเป้าหมายไม่สำเร็จ' : 'เพิ่มเป้าหมายไม่สำเร็จ')),
          );
        }
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(isEditing ? 'แก้ไขเป้าหมาย' : 'เพิ่มเป้าหมาย'),
          backgroundColor: Colors.blue[800],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('ชื่อเป้าหมาย', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    decoration: _whiteFieldDecoration('กรอกชื่อเป้าหมาย'),
                  ),
                  const SizedBox(height: 16),
                  const Text('ยอดเป้าหมาย', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: targetAmountController,
                    keyboardType: TextInputType.number,
                    decoration: _whiteFieldDecoration('กรอกยอดเป้าหมาย'),
                  ),
                  const SizedBox(height: 16),
                  const Text('ระยะเวลา (จำนวน)', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: _whiteFieldDecoration('กรอกระยะเวลา (จำนวนวันหรือเดือน)'),
                  ),
                  const SizedBox(height: 16),
                  const Text('ประเภทระยะเวลา', style: TextStyle(fontSize: 16)),
                  DropdownButtonFormField<String>(
                    value: durationType,
                    decoration: _whiteFieldDecoration('เลือกประเภทระยะเวลา'),
                    style: const TextStyle(color: Colors.black),
                    dropdownColor: Colors.white,
                    iconEnabledColor: Colors.black,
                    items: ['days', 'months']
                        .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v == 'days' ? 'วัน' : 'เดือน'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => durationType = v!),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isEditing ? 'บันทึกการแก้ไข' : 'เพิ่มเป้าหมาย',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
