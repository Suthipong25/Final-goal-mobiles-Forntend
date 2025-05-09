class Goal {
  final String? id;           // MongoDB ObjectId ของ Goal
  final String userId;        // ObjectId ของเจ้าของ (user)
  final String title;         // ชื่อของเป้าหมาย
  final double targetAmount;  // จำนวนเงินที่ต้องการบรรลุ
  final double currentAmount; // จำนวนเงินปัจจุบันที่สะสมได้
  final DateTime dueDate;     // วันกำหนดครบกำหนดเป้าหมาย
  final int duration;         // ระยะเวลาในการตั้งเป้าหมาย (เช่น วัน หรือ เดือน)
  final String durationType;  // ประเภทของระยะเวลา ("days" หรือ "months")

  // คอนสตรัคเตอร์ที่ใช้สำหรับสร้าง Goal ใหม่
  Goal({
    this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.dueDate,
    required this.duration,
    required this.durationType,
  });

  // ฟังก์ชัน factory สำหรับแปลงข้อมูล JSON จาก MongoDB ให้เป็น Goal object
  factory Goal.fromJson(Map<String, dynamic> json) {
    // แปลง _id จาก MongoDB
    final rawId = json['_id'];
    final id = rawId is Map
        ? rawId[r'$oid'] as String? // เช็คว่า _id เป็นรูปแบบ Map หรือไม่
        : rawId as String?;

    // แปลง user (เจ้าของ)
    final rawUser = json['user'];
    final userId = rawUser is Map
        ? rawUser[r'$oid'] as String // แปลงเป็น userId
        : rawUser as String;

    // แปลง dueDate จาก Map เป็น DateTime
    final rawDate = json['dueDate'];
    final dueDate = rawDate is Map && rawDate.containsKey(r'$date')
        ? DateTime.parse(rawDate[r'$date']) // ถ้าเป็นรูปแบบ Date ให้แปลง
        : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(); // ถ้าไม่ใช่ให้ใช้ค่าปัจจุบัน

    // คืนค่า Goal object ที่สร้างจาก JSON
    return Goal(
      id: id,
      userId: userId,
      title: json['title'] as String? ?? '', // กรณี title ไม่มี ให้เป็นค่าว่าง
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0, // แปลงเป็น double
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0, // แปลงเป็น double
      dueDate: dueDate,
      duration: (json['duration'] as num?)?.toInt() ?? 0, // แปลงเป็น int
      durationType: json['durationType'] as String? ?? 'days', // ถ้าไม่มีให้ใช้ 'days' เป็น default
    );
  }

  // ฟังก์ชัน toJson ใช้สำหรับแปลง Goal เป็น JSON สำหรับส่งไปยังเซิร์ฟเวอร์
  Map<String, dynamic> toJson() {
    // ส่งเฉพาะฟิลด์ที่จำเป็น
    return {
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'dueDate': dueDate.toIso8601String(), // แปลงวันที่เป็น ISO 8601 format
      'duration': duration,
      'durationType': durationType,
      // userId ไม่จำเป็นต้องส่งในกรณี POST-goals/:userId
    };
  }
}
