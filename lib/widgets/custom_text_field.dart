import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final double width;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.hintText,
    required this.prefixIcon,
    super.key,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.width = double.infinity,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
          errorMaxLines: 2,
        ),
      ),
    );
  }
}
