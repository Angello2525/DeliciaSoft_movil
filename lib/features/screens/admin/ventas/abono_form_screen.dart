import 'package:flutter/material.dart';
import '../../../models/venta/abono.dart';
import '../../../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/Venta/imagene.dart'; 
import 'dart:io';
class AbonoFormScreen extends StatefulWidget {
  final int idPedido;
  final Abono? abono;  
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
  late TextEditingController _cantidadPagarController;
  String? _selectedMetodoPago; 

  XFile? _selectedImage; 
  Imagene? _uploadedImage; 

  @override
  void initState() {
    super.initState();
    _cantidadPagarController = TextEditingController(text: widget.abono?.cantidadPagar?.toString() ?? '');
    _selectedMetodoPago = widget.abono?.metodoPago;  

    if (widget.abono?.idImagen != null && widget.abono?.urlImagen != null && _selectedMetodoPago == 'Transferencia') {
      _uploadedImage = Imagene(idImagen: widget.abono!.idImagen, urlImg: widget.abono!.urlImagen);
    }
  }

  @override
  void dispose() {
    _cantidadPagarController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);  
    setState(() {
      _selectedImage = image;
      _uploadedImage = null;  
    });
  }

  void _saveAbono() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      int? finalIdImagen;
      String? finalImageUrl;  

      if (_selectedMetodoPago == 'Transferencia') {
        if (_selectedImage != null) {
          try {
            final uploadedImg = await ApiService.uploadImage(_selectedImage!);
            finalIdImagen = uploadedImg.idImagen;
            finalImageUrl = uploadedImg.urlImg; 
            Imagene? _uploadedImage;   
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Imagen cargada exitosamente!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al subir imagen: $e')),
            );
            return; // Stop the process if image upload fails
          }
        } else if (widget.abono?.idImagen != null) {
          finalIdImagen = widget.abono!.idImagen;
          finalImageUrl = widget.abono!.urlImagen;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, seleccione un comprobante para Transferencia.')),
          );
          return;
        }
      } else {
        finalIdImagen = null;
        finalImageUrl = null;
      }

      final newAbono = Abono(
        idAbono: widget.abono?.idAbono, // Keep existing ID for update
        idPedido: widget.idPedido,
        metodoPago: _selectedMetodoPago, // Use the selected value
        cantidadPagar: double.tryParse(_cantidadPagarController.text),
        idImagen: finalIdImagen, // Use the ID from the uploaded image or existing
        urlImagen: finalImageUrl, // Assign the URL here
      );

      // Add print statements for debugging the Abono object before sending
      print('Abono being sent:'); //
      print('  idPedido: ${newAbono.idPedido}'); //
      print('  metodoPago: ${newAbono.metodoPago}'); //
      print('  cantidadPagar: ${newAbono.cantidadPagar}'); //
      print('  idImagen: ${newAbono.idImagen}'); //
      print('  urlImagen: ${newAbono.urlImagen}'); //


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
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.pink, // Primary color for the app bar, etc.
        ).copyWith(
          secondary: Colors.pinkAccent, // Accent color for buttons, etc.
          onSurface: Colors.black87, // Default text color
          error: Colors.red.shade700, // Error text color
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.pink.shade700, // Cursor color for text fields
          selectionHandleColor: Colors.pink.shade700,
          selectionColor: Colors.pink.shade100,
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.pink.shade700, width: 2.0),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade700, width: 2.0),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade700, width: 2.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink, // Button background color
            foregroundColor: Colors.white, // Button text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.pink.shade700, // Text button color
          ),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          textStyle: TextStyle(color: Colors.black87),
        ),
      ),
      child: AlertDialog(
        title: Text(
          widget.abono == null ? 'Crear Abono' : 'Editar Abono',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedMetodoPago,
                  decoration: const InputDecoration(
                    labelText: 'Método de Pago',
                  ),
                  items: <String>['Efectivo', 'Transferencia']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMetodoPago = newValue;
                      // Clear selected image and uploaded image data if method changes from Transferencia
                      if (newValue != 'Transferencia') {
                        _selectedImage = null;
                        _uploadedImage = null;
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione el método de pago';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
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
                if (_selectedMetodoPago == 'Transferencia')
                  Column(
                    children: [
                      const SizedBox(height: 16.0),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Seleccionar Comprobante'),
                      ),
                      if (_selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Archivo seleccionado: ${_selectedImage!.name}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        )
                      else if (_uploadedImage?.urlImg != null && _uploadedImage!.urlImg!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Comprobante actual: ${_uploadedImage!.urlImg!.split('/').last}', // Show file name from uploaded URL
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                      if (_selectedImage != null)
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          height: 100,
                          child: Image.file(
                            File(_selectedImage!.path), // Display local file
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                          ),
                        )
                      else if (_uploadedImage?.urlImg != null && _uploadedImage!.urlImg!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          height: 100,
                          child: Image.network(
                            _uploadedImage!.urlImg!, // Display uploaded image from URL
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                          ),
                        ),
                    ],
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
      ),
    );
  }
  
}