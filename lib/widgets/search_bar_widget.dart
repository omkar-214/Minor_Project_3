import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final String hintText;
  final Color textColor;
  final Color borderColor;
  final Color errorBorderColor;
  final Color fillColor;
  final double radius;
  final FontWeight fontWeight;
  final double fontSize;
  final String? errorText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.hintText = 'Enter city name',
    this.textColor = Colors.white,
    this.borderColor = Colors.white,
    this.errorBorderColor = Colors.redAccent,
    this.fillColor = const Color(0x26FFFFFF),
    this.radius = 30,
    this.fontWeight = FontWeight.w400,
    this.fontSize = 16,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: textColor,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmitted(),
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: textColor.withValues(alpha: 0.7),
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        errorText: errorText,
        errorStyle: TextStyle(color: errorBorderColor),
        filled: true,
        fillColor: fillColor,
        prefixIcon: Icon(Icons.search, color: textColor),
        suffixIcon: IconButton(
          icon: Icon(Icons.arrow_forward_rounded, color: textColor),
          onPressed: onSubmitted,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 1.5),
          borderRadius: BorderRadius.circular(radius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(radius),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: errorBorderColor, width: 1.5),
          borderRadius: BorderRadius.circular(radius),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: errorBorderColor, width: 1.5),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}