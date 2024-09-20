import 'package:flutter/material.dart';

class AppTextfield extends StatelessWidget {
  const AppTextfield({
    super.key,
    required this.controller,
    this.labelText,
    this.validator,
    this.keyBoardType,
    this.onTap,
  });

  final TextEditingController controller;
  final String? labelText;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextInputType? keyBoardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      keyboardType: keyBoardType,
      validator: validator,
    );
  }
}
