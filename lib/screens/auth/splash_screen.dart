import 'package:flutter/material.dart';
import 'package:galaxy_mini/app.dart';
import 'package:galaxy_mini/auth/login.dart';
import 'package:galaxy_mini/theme/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLogin = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1)).then(
      (value) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            // TODO: Update this after Login API thing is implemented
            return !isLogin ? const App() : const LoginScreen();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          AppLogos.galaxyMiniLogo,
          height: 200,
        ),
      ),
    );
  }
}
