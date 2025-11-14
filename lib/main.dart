import 'package:flutter/material.dart';
import 'package:mech_pos/screens/login_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  // For desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Example',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LoginPage(),
    );
  }
}