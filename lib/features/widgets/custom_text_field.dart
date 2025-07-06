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
  final IconData? prefixIcon; // ¡NUEVO! Parámetro para el icono prefijo
  final int? maxLength;

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
    this.prefixIcon, // ¡NUEVO! Añadido al constructor
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    // Define el color principal de tu aplicación para usarlo en el foco
    final Color primaryColor = Theme.of(context).primaryColor; // O define tu color principal aquí, por ejemplo: const Color(0xFFE91E63);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onTap: onTap,
      readOnly: readOnly,
      maxLength: maxLength, // Limita la longitud del texto
      cursorColor: primaryColor, // Color del cursor
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[800],
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 16,
        ),
        // Estilo del borde por defecto
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        // Estilo del borde cuando el campo está habilitado (no enfocado)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
        ),
        // Estilo del borde cuando el campo está enfocado
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2.0),
        ),
        // Estilo del borde cuando hay un error
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!, width: 1.5),
        ),
        // Estilo del borde cuando el campo tiene un error y está enfocado
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[600]!, width: 2.0),
        ),
        // Relleno del campo de texto
        filled: true,
        fillColor: Colors.grey[50], // Un color de fondo suave
        // Icono prefijo (izquierda)
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                child: Icon(
                  prefixIcon,
                  color: Colors.grey[500],
                  size: 24,
                ),
              )
            : null,
        // Icono sufijo (derecha)
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: suffixIcon,
              )
            : null,
        // Elimina el contador de caracteres por defecto
        counterText: '',
        // Padding interno del contenido del texto
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}