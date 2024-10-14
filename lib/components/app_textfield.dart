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
    this.enabled = false,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? labelText;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final TextInputType? keyBoardType;
  final bool isSuffixIcon;
  final bool obscureText;
  final bool enabled;
  final Widget? suffixIcon;
  final ValueChanged? onChanged;

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
        enabled: enabled,
      ),
      onChanged: onChanged,
      keyboardType: keyBoardType,
      validator: validator,
    );
  }
}
