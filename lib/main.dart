import 'package:flutter/material.dart';
import 'package:galaxy_mini/provider/park_provider.dart';
import 'package:galaxy_mini/provider/sync_provider.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'auth/login.dart';
import 'provider/auth_provider.dart';
import 'services/dataprovider.dart'; // Import your data provider


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),// Add your DataProvider here
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(create: (_) => ParkedOrderProvider()),// Add your DataProvider here
      ],
      child: const MaterialApp(
        home: LoginScreen(), // Use the separated login page
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
