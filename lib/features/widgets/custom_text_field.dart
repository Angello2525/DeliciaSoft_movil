import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function()? onTap;
  final bool readOnly;
  final Widget? suffixIcon;
  final int? maxLength; // ✅ NUEVO

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    this.maxLength, // ✅ NUEVO
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onTap: onTap,
      readOnly: readOnly,
      maxLength: maxLength, // ✅ NUEVO
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
        counterText: '', // ✅ Oculta el contador (opcional)
      ),
    );
  }
}
