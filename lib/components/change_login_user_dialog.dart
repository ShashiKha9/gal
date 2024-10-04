import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_textfield.dart';

class ChangeLoginUserDialog extends StatefulWidget {
  const ChangeLoginUserDialog({super.key});

  @override
  _ChangeLoginUserDialogState createState() => _ChangeLoginUserDialogState();
}

class _ChangeLoginUserDialogState extends State<ChangeLoginUserDialog> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool obscureTextNew = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Change Password"),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextfield(
                controller: usernameController,
                labelText: "Username",
              ),
              const SizedBox(height: 15),
              AppTextfield(
                controller: newPasswordController,
                labelText: "New Password",
                isSuffixIcon: true,
                obscureText: obscureTextNew,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureTextNew ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureTextNew = !obscureTextNew;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            // String oldPassword = oldPasswordController.text;
            // String newPassword = newPasswordController.text;

            Navigator.of(context).pop();
          },
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
