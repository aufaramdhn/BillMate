import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(const BillMateApp());
}

class BillMateApp extends StatelessWidget {
  const BillMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BillMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B6AF0)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(AppConfig.appName),
        ),
      ),
    );
  }
}
