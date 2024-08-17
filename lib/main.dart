import 'package:flutter/material.dart';
import 'package:mz_reservations/screens/layout_editor_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Supabase.initialize(
  //   url: 'YOUR_SUPABASE_URL',
  //   anonKey: 'YOUR_SUPABASE_ANON_KEY',
  // );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '매장 관리 시스템',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CustomStoreLayoutEditor(),
    );
  }
}
