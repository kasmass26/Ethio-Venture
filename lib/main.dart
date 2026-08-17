import 'package:ethioventure/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final config = AppConfig.fromEnvironment();
  await Supabase.initialize(
    url: config.supabaseUrl,
    publishableKey: config.supabasePublishableKey,
  );

  runApp(EthioVentureApp(environment: config.environment));
}

class EthioVentureApp extends StatelessWidget {
  const EthioVentureApp({super.key, required this.environment});

  final String environment;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ethio Venture',
      debugShowCheckedModeBanner: environment != 'production',
      home: const Scaffold(
        body: Center(child: Text('Ethio Venture')),
      ),
    );
  }
}
