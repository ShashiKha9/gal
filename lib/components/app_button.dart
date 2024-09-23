import 'package:flutter/material.dart';
import 'package:galaxy_mini/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.margin,
    this.backgroundColor,
    this.style,
    this.padding,
    this.radius = 25,
    this.min = false,
  });
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final String buttonText;
  final VoidCallback onTap;
  final TextStyle? style;
  final double radius;
  final bool min;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ??
          const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 15,
          ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        onPressed: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisSize: min ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                buttonText,
                style: style ??
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
