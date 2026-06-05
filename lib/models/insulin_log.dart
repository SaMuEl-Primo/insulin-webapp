class InsulinLog {
  final int? id;
  final double dosis;
  final String kategori;     // Contoh: "Sebelum Makan", "Sebelum Tidur"
  final String tipeInsulin;   // Contoh: "Rapid-acting", "Long-acting"
  final String waktu;         // Format standar: YYYY-MM-DD HH:MM
  final String catatan;

  InsulinLog({
    this.id,
    required this.dosis,
    required this.kategori,
    required this.tipeInsulin,
    required this.waktu,
    required this.catatan,
  });

  // Mengubah data Object Dart menjadi Map (agar bisa disimpan ke SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dosis': dosis,
      'kategori': kategori,
      'tipe_insulin': tipeInsulin,
      'waktu': waktu,
      'catatan': catatan,
    };
  }

  // Mengubah data Map dari SQLite kembali menjadi Object Dart
  factory InsulinLog.fromMap(Map<String, dynamic> map) {
    return InsulinLog(
      id: map['id'],
      dosis: map['dosis'],
      kategori: map['kategori'],
      tipeInsulin: map['tipe_insulin'],
      waktu: map['waktu'],
      catatan: map['catatan'],
    );
  }
}