import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // Function untuk menyimpan sesi
  static Future<void> saveSession(Map<String, dynamic> responseData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('user_id', responseData['user']['id']);
    await prefs.setString('user_email', responseData['user']['email']);
    // ... tambahkan data lain yang ingin disimpan di session
  }

  // Fungsi untuk menghapus sesi
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    // ... hapus data lain yang ingin di hapus dari session
  }

  // Fungsi untuk mengecek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // Fungsi untuk mendapatkan user ID
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Fungsi untuk mendapatkan user Email
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }
}
