import 'package:flutter/material.dart';
import 'package:galaxy_mini/components/app_button.dart';
import 'package:galaxy_mini/components/app_textfield.dart';
import 'package:galaxy_mini/components/main_appbar.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class AddLoginUser extends StatefulWidget {
  const AddLoginUser({super.key, this.isEdit = false});

  final bool isEdit;

  @override
  State<AddLoginUser> createState() => _AddLoginUserState();
}

class _AddLoginUserState extends State<AddLoginUser> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _passObscureText = true;
  bool _confirmPassObscureText = true;

  String _userType = 'Manager';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
          title: widget.isEdit ? "Edit Login User" : "Add Login User"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: ['Manager', 'Cashier'].map((type) {
                  return Expanded(
                    child: RadioListTile<String>(
                      activeColor: AppColors.blue,
                      contentPadding: EdgeInsets.zero,
                      hoverColor: Colors.transparent,
                      title: Text(type),
                      value: type,
                      groupValue: _userType,
                      onChanged: (value) {
                        setState(() {
                          _userType = value!;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              AppTextfield(
                controller: _nameController,
                labelText: "Name",
              ),
              AppTextfield(
                controller: _passwordController,
                labelText: "Password",
                isSuffixIcon: true,
                obscureText: _passObscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    _passObscureText ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _passObscureText = !_passObscureText;
                    });
                  },
                ),
              ),
              AppTextfield(
                controller: _confirmPasswordController,
                labelText: "Confirm Password",
                isSuffixIcon: true,
                obscureText: _confirmPassObscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    _confirmPassObscureText
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _confirmPassObscureText = !_confirmPassObscureText;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: AppButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      buttonText: 'Cancel',
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: AppButton(
                      onTap: () {},
                      buttonText: 'Save',
                    ),
                  ),
                ],
              ),
            ]
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: e,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
