import 'package:flutter/material.dart';

class AppTextfield extends StatelessWidget {
  const AppTextfield({
    super.key,
     this.controller,
    this.labelText,
    this.validator,
    this.keyBoardType,
    this.onTap,
    this.isSuffixIcon = false,
    this.suffixIcon,
    this.obscureText = false,
  });

  final TextEditingController? controller;
  final String? labelText;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextInputType? keyBoardType;
  final bool isSuffixIcon;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: isSuffixIcon ? suffixIcon : null,
      ),
      keyboardType: keyBoardType,
      validator: validator,
    );
  }
}
