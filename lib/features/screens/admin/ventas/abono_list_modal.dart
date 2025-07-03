// lib/screens/abono_list_modal.dart
import 'package:flutter/material.dart';
import '../../../models/venta/abono.dart';
import '../../../services/api_service.dart';
import 'abono_form_screen.dart'; // Import the new form screen

class AbonoListModal extends StatefulWidget {
  final int idPedido;

  const AbonoListModal({super.key, required this.idPedido});

  @override
  State<AbonoListModal> createState() => _AbonoListModalState();
}

class _AbonoListModalState extends State<AbonoListModal> {
  late Future<List<Abono>> _abonosFuture;

  @override
  void initState() {
    super.initState();
    _abonosFuture = _fetchAbonos();
  }

  Future<List<Abono>> _fetchAbonos() async {
    try {
      return await ApiService.getAbonosByPedidoId(widget.idPedido);
    } catch (e) {
      // Ensure the context is still valid before showing dialog
      if (mounted) {
        _showErrorDialog('Error al cargar abonos: $e');
      }
      return [];
    }
  }

  void _reloadAbonos() {
    // Only reload if the widget is still mounted
    if (mounted) {
      setState(() {
        _abonosFuture = _fetchAbonos();
      });
    }
  }

  void _showErrorDialog(String message) {
    // Only show dialog if the context is still valid
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error', style: TextStyle(color: Colors.black)),
            content: Text(message, style: const TextStyle(color: Colors.black)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK', style: TextStyle(color: Colors.pink)),
              ),
            ],
          );
        },
      );
    }
  }

  void _addAbono() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AbonoFormScreen(idPedido: widget.idPedido),
    );
    // Ensure the context is still valid before reloading
    if (mounted && result == true) {
      _reloadAbonos(); // Reload abonos if a new one was added successfully
    }
  }

  void _editAbono(Abono abono) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AbonoFormScreen(idPedido: widget.idPedido, abono: abono),
    );
    // Ensure the context is still valid before reloading
    if (mounted && result == true) {
      _reloadAbonos(); // Reload abonos if an abono was updated successfully
    }
  }

  void _deleteAbono(int idAbono) async {
    // Store context reference before the async gap in case the dialog pops
    final currentContext = context; 

    showDialog(
      context: currentContext, // Use the stored context
      builder: (BuildContext dialogContext) { // Use dialogContext for actions within this dialog
        return AlertDialog(
          title: const Text('Confirmar Eliminación', style: TextStyle(color: Colors.black)),
          content: Text('¿Está seguro que desea eliminar este abono (ID: $idAbono)?', style: const TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Use dialogContext to pop this dialog
              },
              child: const Text('No', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close confirmation dialog FIRST using dialogContext
                
                try {
                  await ApiService.deleteAbono(idAbono);
                  // Check if the main widget is still mounted before showing SnackBar or reloading
                  if (mounted) {
                    // Use the context of the Scaffold directly inside the Dialog
                    ScaffoldMessenger.of(currentContext).showSnackBar( 
                      const SnackBar(
                        content: Text('Abono eliminado exitosamente!', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.pink, // Pink success snackbar
                      ),
                    );
                    _reloadAbonos(); // Reload abonos after successful deletion
                  }
                } catch (e) {
                  print('Error during Abono deletion: $e'); // For debugging
                  // Check if the main widget is still mounted before showing error dialog
                  if (mounted) {
                    _showErrorDialog('Error al eliminar abono: $e'); // Use existing error dialog
                  }
                }
              },
              child: const Text('Sí', style: TextStyle(color: Colors.pink)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Scaffold( // <<<--- ADDED SCAFFOLD HERE
        backgroundColor: Colors.transparent, // Make Scaffold background transparent
        body: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white, // Keep white background for content
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Abonos para Pedido Nro: ${widget.idPedido}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              const Divider(color: Colors.pink), // Pink divider
              Expanded(
                child: FutureBuilder<List<Abono>>(
                  future: _abonosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pink))); // Pink loading indicator
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.black)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No hay abonos para este pedido.', style: TextStyle(color: Colors.black)));
                    } else {
                      final abonos = snapshot.data!;
                      return ListView.builder(
                        itemCount: abonos.length,
                        itemBuilder: (context, index) {
                          final abono = abonos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            elevation: 2.0, // Added subtle elevation to cards
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)), // Rounded corners for cards
                            child: ListTile(
                              leading: abono.urlImagen != null && abono.urlImagen!.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(abono.urlImagen!),
                                      radius: 20,
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.pink.shade50, // Light pink background
                                      child: const Icon(Icons.payment, color: Colors.pink), // Pink icon
                                      radius: 20,
                                    ),
                              title: Text('Método: ${abono.metodoPago ?? 'N/A'}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cantidad: \$${abono.cantidadPagar?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(color: Colors.black87)),
                                  if (abono.idImagen != null) Text('ID Imagen: ${abono.idImagen}', style: const TextStyle(color: Colors.black54)),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.black), // Black edit icon
                                    onPressed: () => _editAbono(abono),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.black), // Black delete icon
                                    onPressed: () => _deleteAbono(abono.idAbono!),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _addAbono,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Abono'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink, // Pink button
                  foregroundColor: Colors.white, // White text and icon
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Larger padding
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Rounded corners
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}