// lib/screens/abono_form_screen.dart
import 'package:flutter/material.dart';
import '../../../models/venta/abono.dart';
import '../../../services/api_service.dart';

class AbonoFormScreen extends StatefulWidget {
  final int idPedido;
  final Abono? abono; // Null for new abono, provided for editing

  const AbonoFormScreen({
    super.key,
    required this.idPedido,
    this.abono,
  });

  @override
  State<AbonoFormScreen> createState() => _AbonoFormScreenState();
}

class _AbonoFormScreenState extends State<AbonoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _metodoPagoController;
  late TextEditingController _cantidadPagarController;
  late TextEditingController _idImagenController; // For demonstration, later can be image picker

  @override
  void initState() {
    super.initState();
    _metodoPagoController = TextEditingController(text: widget.abono?.metodoPago ?? '');
    _cantidadPagarController = TextEditingController(text: widget.abono?.cantidadPagar?.toString() ?? '');
    _idImagenController = TextEditingController(text: widget.abono?.idImagen?.toString() ?? '');
  }

  @override
  void dispose() {
    _metodoPagoController.dispose();
    _cantidadPagarController.dispose();
    _idImagenController.dispose();
    super.dispose();
  }

  void _saveAbono() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newAbono = Abono(
        idAbono: widget.abono?.idAbono, // Keep existing ID for update
        idPedido: widget.idPedido,
        metodoPago: _metodoPagoController.text,
        cantidadPagar: double.tryParse(_cantidadPagarController.text),
        idImagen: int.tryParse(_idImagenController.text),
      );

      try {
        if (widget.abono == null) {
          // Creating a new abono
          await ApiService.createAbono(newAbono);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abono creado exitosamente!')),
          );
        } else {
          // Updating an existing abono
          await ApiService.updateAbono(newAbono.idAbono!, newAbono);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abono actualizado exitosamente!')),
          );
        }
        Navigator.of(context).pop(true); // Indicate success and close
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar abono: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.abono == null ? 'Crear Abono' : 'Editar Abono'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _metodoPagoController,
                decoration: const InputDecoration(labelText: 'Método de Pago'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el método de pago';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cantidadPagarController,
                decoration: const InputDecoration(labelText: 'Cantidad a Pagar'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la cantidad a pagar';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingrese un número válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _idImagenController,
                decoration: const InputDecoration(labelText: 'ID de Imagen (Opcional)'),
                keyboardType: TextInputType.number,
                // No validator here as it's optional, but you might want to validate if it's an integer
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Indicate cancel and close
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveAbono,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}