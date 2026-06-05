import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // <-- Sudah ditambahkan di bagian atas
import 'package:flutter_application_1/database/database_helper.dart'; // <-- Jalur absolut
import 'package:flutter_application_1/models/insulin_log.dart';     // <-- Jalur absolut

class InsulinProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  List<InsulinLog> _logs = [];
  List<Map<String, dynamic>> _alarms = [];
  Timer? _alarmTimer;

  // Getter agar UI bisa membaca data log dan alarm
  List<InsulinLog> get logs => _logs;
  List<Map<String, dynamic>> get alarms => _alarms;

  // --- LOGIKA JURNAL INSULIN ---

  // Fungsi mengambil semua log dari database
  Future<void> muatSemuaLog() async {
    _logs = await _dbHelper.getAllLogs();
    notifyListeners(); // Memberitahu UI untuk update tampilan secara real-time
  }

  // Fungsi menambah log baru
  Future<void> tambahLogBaru(InsulinLog log) async {
    await _dbHelper.insertLog(log);
    await muatSemuaLog(); // Refresh list setelah ditambah
  }


  // --- LOGIKA ALARM PENGINGAT (PENDEKATAN WEB) ---

  // Fungsi mengambil daftar alarm dari Hive Box
  Future<void> muatSemuaAlarm() async {
    final box = Hive.box('alarms_box');
    final List<Map<String, dynamic>> tempAlarms = [];
    
    for (var key in box.keys) {
      final Map<dynamic, dynamic> rawMap = box.get(key);
      tempAlarms.add(Map<String, dynamic>.from(rawMap));
    }
    _alarms = tempAlarms;
    notifyListeners();
  }

  // Fungsi menambah jam alarm baru ke Hive
  Future<void> tambahAlarmBaru(String jam) async {
    final box = Hive.box('alarms_box');
    await box.add({'jam': jam, 'is_aktif': 1});
    await muatSemuaAlarm();
    mulaiSistemAlarmChecker(); // Jalankan ulang pemantau waktu otomatis
  }

  // Fungsi background checker yang berjalan setiap 30 detik di browser
  void mulaiSistemAlarmChecker() {
    _alarmTimer?.cancel(); // Reset timer lama jika ada
    
    _alarmTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      // Ambil waktu saat ini di komputer/browser
      final sekarang = DateTime.now();
      final String jamMenitSekarang = 
          "${sekarang.hour.toString().padLeft(2, '0')}:${sekarang.minute.toString().padLeft(2, '0')}";

      // Cek apakah ada alarm aktif yang cocok dengan jam sekarang
      for (var alarm in _alarms) {
        if (alarm['jam'] == jamMenitSekarang && alarm['is_aktif'] == 1) {
          _pemicuNotifikasiAlarm(jamMenitSekarang);
        }
      }
    });
  }

  // Aksi yang dilakukan saat alarm berbunyi
  void _pemicuNotifikasiAlarm(String jam) {
    print("ALARM AKTIF: Waktunya suntik insulin! Jam: $jam");
    // Catatan: Di bagian UI (home_screen.dart), logika ini otomatis terhubung untuk memantau waktu
  }

  @override
  void dispose() {
    _alarmTimer?.cancel();
    super.dispose();
  }
}