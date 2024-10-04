import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_textfield.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool obscureTextOld = true;
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
                controller: oldPasswordController,
                labelText: "Old Password",
                isSuffixIcon: true,
                obscureText: obscureTextOld,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureTextOld ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureTextOld = !obscureTextOld;
                    });
                  },
                ),
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
