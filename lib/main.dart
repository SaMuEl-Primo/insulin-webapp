import 'package:flutter_application_1/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/insulin_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menyalakan database lokal Hive
  final DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.initHive();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => InsulinProvider()
            ..muatSemuaLog()
            ..muatSemuaAlarm()
            ..mulaiSistemAlarmChecker(),
        ),
      ],
      child: MaterialApp(
        title: 'Insulin Health Care App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const HomeScreen(), // Langsung mengarah ke UI Jurnal & Alarm Anda
      ),
    );
  }
}