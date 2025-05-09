// class User ใช้สำหรับเก็บข้อมูลของผู้ใช้
class User {
  final String id;             // ID ของผู้ใช้ (จาก MongoDB)
  final String email;          // อีเมลของผู้ใช้
  final String username;       // ชื่อผู้ใช้

  // คอนสตรัคเตอร์สำหรับสร้าง User ใหม่
  User({
    required this.id,
    required this.email,
    required this.username,
  });

  // ฟังก์ชัน factory สำหรับแปลงข้อมูล JSON ให้เป็น User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',        // ถ้า _id เป็น null ให้ใช้ค่าว่าง
      email: json['email'] ?? '',    // ถ้า email เป็น null ให้ใช้ค่าว่าง
      username: json['username'] ?? '',  // ถ้า username เป็น null ให้ใช้ค่าว่าง
    );
  }
}
