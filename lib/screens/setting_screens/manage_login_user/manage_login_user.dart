import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/screens/setting_screens/manage_login_user/add_login_user.dart';

class ManageLoginUser extends StatefulWidget {
  const ManageLoginUser({super.key});

  @override
  State<ManageLoginUser> createState() => _ManageLoginUserState();
}

class _ManageLoginUserState extends State<ManageLoginUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: "App User"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLoginUser()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
