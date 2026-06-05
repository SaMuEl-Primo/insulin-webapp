import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_1/models/insulin_log.dart';

class DatabaseHelper {
  // Menginisialisasi Hive Box (Sama seperti membuat Tabel di SQL)
  Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox('insulin_logs_box');
    await Hive.openBox('alarms_box');
  }

  // --- FUNGSI CRUD JURNAL INSULIN ---
  
  Future<void> insertLog(InsulinLog log) async {
    final box = Hive.box('insulin_logs_box');
    await box.add(log.toMap()); // Menyimpan data sebagai Map lokal
  }

  Future<List<InsulinLog>> getAllLogs() async {
    final box = Hive.box('insulin_logs_box');
    final List<InsulinLog> logs = [];
    
    // Ambil data dan konversi kembali dari Map ke bentuk Object
    for (var key in box.keys) {
      final Map<dynamic, dynamic> rawMap = box.get(key);
      final Map<String, dynamic> convertedMap = Map<String, dynamic>.from(rawMap);
      logs.add(InsulinLog.fromMap(convertedMap));
    }
    return logs.reversed.toList(); // Urutkan dari data terbaru
  }
}