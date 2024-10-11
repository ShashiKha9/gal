import 'package:flutter/material.dart';
import 'package:galaxy_mini/app.dart';
import 'package:galaxy_mini/screens/auth/login.dart';
import 'package:galaxy_mini/theme/app_assets.dart';
import 'package:galaxy_mini/utils/shared_preferences.dart';

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
    Future.delayed(const Duration(seconds: 2)).then((value) => redirect());
  }

  Future<void> redirect() async {
    await MySharedPreferences.instance.getStringValue("access_token").then(
      (value) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  value == null ? const LoginScreen() : const App(),
            ),
            (route) => false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          AppLogos.galaxyMiniLogo,
          height: 200,
        ),
      ),
    );
  }
}
