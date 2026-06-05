import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/insulin_provider.dart';
import '../models/insulin_log.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dosisController = TextEditingController();
  String _kategoriTerpilih = 'Sebelum Makan';
  String _tipeTerpilih = 'Rapid-acting';
  final _catatanController = TextEditingController();

  final List<String> _kategoriList = ['Sebelum Makan', 'Setelah Makan', 'Sebelum Tidur', 'Kondisi Khusus'];
  final List<String> _tipeList = ['Rapid-acting', 'Short-acting', 'Intermediate-acting', 'Long-acting'];

  @override
  Widget build(BuildContext context) {
    final insulinProvider = Provider.of<InsulinProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insulin Health Tracker (Offline Web)'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // KIRI: Form Input Jurnal & Alarm
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Catat Jurnal Insulin', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _dosisController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Dosis Insulin (Unit)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _kategoriTerpilih,
                    decoration: const InputDecoration(labelText: 'Kategorisasi Waktu', border: OutlineInputBorder()),
                    items: _kategoriList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                    onChanged: (val) => setState(() => _kategoriTerpilih = val!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _tipeTerpilih,
                    decoration: const InputDecoration(labelText: 'Tipe Insulin', border: OutlineInputBorder()),
                    items: _tipeList.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _tipeTerpilih = val!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _catatanController,
                    decoration: const InputDecoration(labelText: 'Catatan Tambahan', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
                    onPressed: () {
                      if (_dosisController.text.isNotEmpty) {
                        final baru = InsulinLog(
                          dosis: double.parse(_dosisController.text),
                          kategori: _kategoriTerpilih,
                          tipeInsulin: _tipeTerpilih,
                          waktu: DateFormat('yyyy-MM-DD HH:mm').format(DateTime.now()),
                          catatan: _catatanController.text,
                        );
                        insulinProvider.tambahLogBaru(baru);
                        _dosisController.clear();
                        _catatanController.clear();
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan ke Database Offline'),
                  ),
                  const Divider(height: 40),
                  
                  // FITUR ALARM QUICK SET
                  const Text('Set Alarm Pengingat Otomatis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (picked != null) {
                            final String jamFormatted = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                            insulinProvider.tambahAlarmBaru(jamFormatted);
                          }
                        },
                        icon: const Icon(Icons.alarm_add),
                        label: const Text('Pilih Jam Alarm'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const VerticalDivider(width: 1),

          // KANAN: Daftar Riwayat Jurnal & Alarm Terpasang
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Alarms Aktif', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 80,
                    child: insulinProvider.alarms.isEmpty
                        ? const Center(child: Text('Belum ada alarm aktif'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: insulinProvider.alarms.length,
                            itemBuilder: (context, idx) {
                              final alarm = insulinProvider.alarms[idx];
                              return Card(
                                color: Colors.teal[50],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Center(child: Text(alarm['jam'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Riwayat Jurnal Insulin (SQLite)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: insulinProvider.logs.isEmpty
                        ? const Center(child: Text('Belum ada riwayat log medis.'))
                        : ListView.builder(
                            itemCount: insulinProvider.logs.length,
                            itemBuilder: (context, idx) {
                              final log = insulinProvider.logs[idx];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: const Icon(Icons.bloodtype, color: Colors.red),
                                  title: Text('${log.dosis} Unit - ${log.tipeInsulin}'),
                                  subtitle: Text('${log.kategori} | ${log.waktu}\nCatatan: ${log.catatan}'),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
