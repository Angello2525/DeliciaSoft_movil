// abono_form_screen.dart
import 'package:flutter/material.dart';
import '../../../models/venta/abono.dart';
import '../../../services/api_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/Venta/imagene.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class AbonoFormScreen extends StatefulWidget {
  final int idPedido;
  final Abono? abono;
  final double totalPedido; // Add totalPedido here

  const AbonoFormScreen({
    super.key,
    required this.idPedido,
    this.abono,
    required this.totalPedido, // Update constructor
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

  double _currentAbonosSum = 0.0; // To store the sum of existing abonos for this pedido

  // Define color palette
  static const Color _primaryRose = Color.fromRGBO(228, 48, 84, 1);
  static const Color _darkGrey = Color(0xFF333333);
  static const Color _textGrey = Color(0xFF6B7A8C); // For general text, softer than black
  static const Color _accentGreen = Color(0xFF6EC67F); // Softer green for positive
  static const Color _accentRed = Color(0xFFE57373); // Softer red for warnings/cancel

  @override
  void initState() {
    super.initState();
    _cantidadPagarController = TextEditingController(text: widget.abono?.cantidadPagar?.toString() ?? '');
    _selectedMetodoPago = widget.abono?.metodoPago;

    if (widget.abono?.idImagen != null && widget.abono?.urlImagen != null && _selectedMetodoPago == 'Transferencia') {
      _uploadedImage = Imagene(idImagen: widget.abono!.idImagen, urlImg: widget.abono!.urlImagen);
    }
    _fetchCurrentAbonosSum(); // Fetch current abonos sum
  }

  @override
  void dispose() {
    _cantidadPagarController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentAbonosSum() async {
    try {
      final abonos = await ApiService.getAbonosByPedidoId(widget.idPedido);
      double sum = 0.0;
      for (var abono in abonos) {
        // Exclude the current abono being edited from the sum for validation
        if (widget.abono != null && abono.idAbono == widget.abono!.idAbono) {
          continue;
        }
        sum += abono.cantidadPagar ?? 0.0;
      }
      setState(() {
        _currentAbonosSum = sum;
      });
    } catch (e) {
      print('Error fetching current abonos sum: $e');
      // Optionally show an error dialog
    }
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Imagen cargada exitosamente!', style: TextStyle(color: Colors.white)), backgroundColor: _accentGreen),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al subir imagen: $e', style: const TextStyle(color: Colors.white)), backgroundColor: _accentRed),
            );
            return; // Stop the process if image upload fails
          }
        } else if (widget.abono?.idImagen != null) {
          finalIdImagen = widget.abono!.idImagen;
          finalImageUrl = widget.abono!.urlImagen;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, seleccione un comprobante para Transferencia.', style: TextStyle(color: Colors.white)), backgroundColor: _accentRed),
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

      try {
        if (widget.abono == null) {
          // Creating a new abono
          await ApiService.createAbono(newAbono);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abono creado exitosamente!', style: TextStyle(color: Colors.white)), backgroundColor: _accentGreen),
          );
        } else {
          // Updating an existing abono
          await ApiService.updateAbono(newAbono.idAbono!, newAbono);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abono actualizado exitosamente!', style: TextStyle(color: Colors.white)), backgroundColor: _accentGreen),
          );
        }
        Navigator.of(context).pop(true); // Indicate success and close
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar abono: $e', style: const TextStyle(color: Colors.white)), backgroundColor: _accentRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate remaining balance dynamically
    final double currentAbonoValueForValidation = widget.abono?.cantidadPagar ?? 0.0;
    final double remainingBalance = widget.totalPedido - _currentAbonosSum - currentAbonoValueForValidation;

    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.pink,
        ).copyWith(
          primary: _primaryRose,
          secondary: _primaryRose.withOpacity(0.7),
          onSurface: _darkGrey,
          error: _accentRed,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: _primaryRose,
          selectionHandleColor: _primaryRose,
          selectionColor: _primaryRose.withOpacity(0.2),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: _textGrey),
          floatingLabelStyle: TextStyle(color: _primaryRose),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: _primaryRose.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: _primaryRose, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: _textGrey.withOpacity(0.4)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: _accentRed, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: _accentRed, width: 2.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryRose,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            elevation: 3,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _textGrey,
          ),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: TextStyle(color: _darkGrey),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(color: _textGrey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: _primaryRose.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(color: _primaryRose, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: _textGrey.withOpacity(0.4)),
            ),
          ),
        ),
      ),
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.abono == null ? 'Crear Abono' : 'Editar Abono',
              style: const TextStyle(color: _darkGrey, fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total Pedido: \$${widget.totalPedido.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 15, color: _textGrey),
                  ),
                  Text(
                    'Saldo Pendiente: \$${remainingBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: remainingBalance < 0.01 ? _accentGreen : _accentRed,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _cantidadPagarController,
                  decoration: const InputDecoration(labelText: 'Cantidad a Pagar'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese la cantidad a pagar';
                    }
                    final enteredAmount = double.tryParse(value);
                    if (enteredAmount == null) {
                      return 'Por favor ingrese un número válido';
                    }

                    final double allowedMax = widget.totalPedido - _currentAbonosSum;

                    if (enteredAmount <= 0) {
                      return 'La cantidad a pagar debe ser mayor que cero.';
                    }
                    if (enteredAmount > allowedMax + currentAbonoValueForValidation + 0.01) { // Adding a small tolerance for floating point
                      return 'La cantidad no puede exceder el saldo pendiente (\$${(allowedMax + currentAbonoValueForValidation).toStringAsFixed(2)})';
                    }
                    return null;
                  },
                ),
                if (_selectedMetodoPago == 'Transferencia')
                  Column(
                    children: [
                      const SizedBox(height: 20.0),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Seleccionar Comprobante'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent.shade400, // Different color for pick image
                        ),
                      ),
                      if (_selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Archivo seleccionado: ${_selectedImage!.name}',
                            style: const TextStyle(color: _textGrey, fontSize: 13),
                          ),
                        )
                      else if (_uploadedImage?.urlImg != null && _uploadedImage!.urlImg!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Comprobante actual: ${_uploadedImage!.urlImg!.split('/').last}',
                            style: const TextStyle(color: _textGrey, fontSize: 13),
                          ),
                        ),
                      if (_selectedImage != null)
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color.fromARGB(255, 114, 115, 114)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: kIsWeb
                                ? Image.network(
                                    _selectedImage!.path,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60, color: _textGrey),
                                  )
                                : Image.file(
                                    File(_selectedImage!.path),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60, color: _textGrey),
                                  ),
                          ),
                        )
                      else if (_uploadedImage?.urlImg != null && _uploadedImage!.urlImg!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color.fromARGB(255, 109, 110, 109)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _uploadedImage!.urlImg!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 60, color: _textGrey),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancelar'),
            style: TextButton.styleFrom(foregroundColor: _textGrey),
          ),
          ElevatedButton(
            onPressed: _saveAbono,
            child: const Text('Guardar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryRose,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}