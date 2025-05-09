// lib/models/transaction_model.dart

class TransactionModel {
  final String id;              // ID ของธุรกรรม (จาก MongoDB)
  final String goalId;          // ID ของ Goal ที่เกี่ยวข้อง
  final String userId;          // ID ของผู้ใช้ (เจ้าของธุรกรรม)
  final double amount;          // จำนวนเงินในธุรกรรม (ฝาก/ถอน)
  final String type;            // ประเภทของธุรกรรม (deposit หรือ withdraw)
  final String durationType;    // ประเภทของระยะเวลา (days หรือ months)
  final int duration;           // ระยะเวลา (จำนวนวันหรือเดือน)
  final DateTime date;          // วันที่และเวลาของธุรกรรม

  // คอนสตรัคเตอร์สำหรับสร้าง TransactionModel ใหม่
  TransactionModel({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.amount,
    required this.type,
    required this.durationType,
    required this.duration,
    required this.date,
  });

  // ฟังก์ชัน factory สำหรับแปลงข้อมูล JSON ให้เป็น TransactionModel
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] as String,  // แปลง _id จาก MongoDB เป็น String
      goalId: json['goal'] as String,  // Goal ID ที่เกี่ยวข้องกับธุรกรรมนี้
      userId: json['user'] as String,  // User ID ของเจ้าของธุรกรรม
      amount: (json['amount'] as num).toDouble(),  // จำนวนเงิน (แปลงเป็น double)
      type: json['type'] as String,  // ประเภทของธุรกรรม (deposit หรือ withdraw)
      durationType: json['durationType'] as String,  // ประเภทของระยะเวลา (days หรือ months)
      duration: (json['duration'] as num).toInt(),  // ระยะเวลา (แปลงเป็น int)
      date: DateTime.parse(json['date'] as String),  // แปลงวันที่จาก String เป็น DateTime
    );
  }
}
