import 'package:flutter/material.dart';
import 'package:galaxy_mini/app.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/app_textfield.dart';
import 'package:galaxy_mini/theme/app_assets.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  // Future<void> _login() async {
  //   final String username = _usernameController.text;
  //   final String password = _passwordController.text;
  //
  //   final loginProvider = Provider.of<LoginProvider>(context, listen: false);
  //
  //   await loginProvider.login(username, password);
  //
  //   if (loginProvider.errorMessage == null) {
  //     // Navigate to the next screen on successful login
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => App(title: '')),
  //     );
  //   } else {
  //     // _showErrorDialog(loginProvider.errorMessage!);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              AppLogos.galaxyMiniLogo,
              height: 130,
            ),
            const Column(
              children: [
                Text(
                  "Welcome back",
                  style: TextStyle(
                    color: AppColors.blue,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Sign in to continue to Galaxy",
                  style: TextStyle(
                    color: AppColors.blue,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 30),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    AppTextfield(
                      controller: _usernameController,
                      labelText: "Username",
                    ),
                    const SizedBox(height: 20),
                    AppTextfield(
                      controller: _passwordController,
                      labelText: "Password",
                      isSuffixIcon: true,
                      obscureText: _obscureText,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        buttonText: "Login",
                        margin: const EdgeInsets.all(0),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const App(),
                            ),
                          );
                          // if (_formKey.currentState!.validate()) {
                          //   showDialog(
                          //     context: context,
                          //     builder: (context) => const Center(
                          //       child: CircularProgressIndicator(),
                          //     ),
                          //   );
                          //   _authProvider
                          //       .userLogin(
                          //     username: _usernameController.text,
                          //     password: _passwordController.text,
                          //   )
                          //       .then((value) {
                          //     if (!context.mounted) return;
                          //     log(context.mounted.toString(),
                          //         name: "successMounted");
                          //     Navigator.pop(context);
                          //     if (value) {
                          //       // authProvider.userConfig().then((value) =>
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (context) => App(title: ''),
                          //         ),
                          //       );
                          //
                          //       // );
                          //     }
                          //   });
                          // }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
