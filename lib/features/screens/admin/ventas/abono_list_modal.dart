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
      _showErrorDialog('Error al cargar abonos: $e');
      return [];
    }
  }

  void _reloadAbonos() {
    setState(() {
      _abonosFuture = _fetchAbonos();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _addAbono() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AbonoFormScreen(idPedido: widget.idPedido),
    );
    if (result == true) {
      _reloadAbonos(); // Reload abonos if a new one was added successfully
    }
  }

  void _editAbono(Abono abono) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AbonoFormScreen(idPedido: widget.idPedido, abono: abono),
    );
    if (result == true) {
      _reloadAbonos(); // Reload abonos if an abono was updated successfully
    }
  }

  void _deleteAbono(int idAbono) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Está seguro que desea eliminar este abono (ID: $idAbono)?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog first
                try {
                  await ApiService.deleteAbono(idAbono);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abono eliminado exitosamente!')),
                  );
                  _reloadAbonos(); // Reload abonos after deletion
                } catch (e) {
                  // Print the full error to the debug console for detailed diagnosis
                  print('Error during Abono deletion: $e');
                  _showErrorDialog('Error al eliminar abono: $e');
                }
              },
              child: const Text('Sí'),
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
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
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
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<Abono>>(
                future: _abonosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay abonos para este pedido.'));
                  } else {
                    final abonos = snapshot.data!;
                    return ListView.builder(
                      itemCount: abonos.length,
                      itemBuilder: (context, index) {
                        final abono = abonos[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            leading: abono.urlImagen != null && abono.urlImagen!.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(abono.urlImagen!),
                                    radius: 20,
                                  )
                                : const CircleAvatar(
                                    child: Icon(Icons.payment),
                                    radius: 20,
                                  ),
                            title: Text('Método: ${abono.metodoPago ?? 'N/A'}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cantidad: \$${abono.cantidadPagar?.toStringAsFixed(2) ?? '0.00'}'),
                                if (abono.idImagen != null) Text('ID Imagen: ${abono.idImagen}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editAbono(abono),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
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
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}