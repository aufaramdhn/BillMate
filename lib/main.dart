import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'config/app_config.dart';
import 'data/repositories/in_memory_bills_repository.dart';
import 'data/services/notification_service.dart';
import 'data/services/offline_bills_cache_service.dart';
import 'data/services/supabase_service.dart';
import 'presentation/blocs/bills/bills_bloc.dart';
import 'presentation/screens/bills/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await OfflineBillsCacheService.initialize();
  await NotificationService.initialize();
  await SupabaseService.initialize();

  final repository = InMemoryBillsRepository();
  final billsBloc = BillsBloc(repository);

  runApp(BillMateApp(billsBloc: billsBloc));
}

class BillMateApp extends StatelessWidget {
  const BillMateApp({
    required this.billsBloc,
    super.key,
  });

  final BillsBloc billsBloc;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BillMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B6AF0)),
        useMaterial3: true,
      ),
      home: DashboardScreen(
        bloc: billsBloc,
        userId: AppConfig.demoUserId,
      ),
    );
  }
}
