import 'dart:developer';
import 'package:flutter/material.dart';
import '../../app.dart';

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
  void initState(){
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    log(DateTime.now().toIso8601String());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 80.0),

              // Logo
              Image.asset(
                'assets/logo1.PNG', // Add your logo asset here
                height: 130.0,
              ),

              // Welcome Text
              const Column(
                children: [
                  SizedBox(height: 20.0),
                  Text(
                    "Welcome back",
                    style: TextStyle(
                      color: Color(0xFFC41E3A),
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Sign in to continue to Galaxy",
                    style: TextStyle(
                      color: Color(0xFFC41E3A),
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50.0),

              // Hover Box with Username, Password, and Login Button
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
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // Username TextField
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Password TextField with visibility toggle
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.black),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30.0),

                      // Login Button (stretched end-to-end)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
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
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            backgroundColor: const Color(0xFFC41E3A),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child:
                          // loginProvider.isLoading
                          //     ? CircularProgressIndicator(
                          //   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          // )
                              const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
