import 'package:flutter/material.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class AppCheckboxTile extends StatefulWidget {
  AppCheckboxTile({
    super.key,
    required this.value,
    required this.title,
    this.onChanged,
  });
  bool? value;
  final String title;
  final Function(bool?)? onChanged;

  @override
  State<AppCheckboxTile> createState() => _AppCheckboxTileState();
}

class _AppCheckboxTileState extends State<AppCheckboxTile> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 3),
      activeColor: AppColors.blue,
      value: widget.value,
      title: Text(widget.title),
      onChanged: widget.onChanged,
    );
  }
}
