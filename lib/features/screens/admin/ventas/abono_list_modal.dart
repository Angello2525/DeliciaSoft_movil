// abono_list_modal.dart
import 'package:flutter/material.dart';
import '../../../models/venta/abono.dart';
import '../../../services/api_service.dart';
import 'abono_form_screen.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class AbonoListModal extends StatefulWidget {
  final int idPedido;
  final double totalPedido; // Add totalPedido here

  const AbonoListModal({super.key, required this.idPedido, required this.totalPedido}); // Update constructor

  @override
  State<AbonoListModal> createState() => _AbonoListModalState();
}

class _AbonoListModalState extends State<AbonoListModal> {
  late Future<List<Abono>> _abonosFuture;
  late Future<double> _totalAbonadoFuture;

  // Define your refined color palette for a relaxing feel
  static const Color _primaryRose = Color.fromRGBO(228, 48, 84, 1);
  static const Color _darkGrey = Color(0xFF333333);
  static const Color _lightGrey = Color(0xFFF0F2F5); // Softer, light background
  static const Color _textGrey = Color(0xFF6B7A8C); // For general text, softer than black
  static const Color _accentGreen = Color(0xFF6EC67F); // Softer green for positive
  static const Color _accentRed = Color(0xFFE57373); // Softer red for warnings/cancel

  @override
  void initState() {
    super.initState();
    _abonosFuture = _fetchAbonos();
    _totalAbonadoFuture = _calculateTotalAbonado();
  }

  Future<List<Abono>> _fetchAbonos() async {
    try {
      return await ApiService.getAbonosByPedidoId(widget.idPedido);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al cargar abonos: $e');
      }
      return [];
    }
  }

  Future<double> _calculateTotalAbonado() async {
    try {
      final abonos = await ApiService.getAbonosByPedidoId(widget.idPedido);
      double sum = 0.0;
      for (var abono in abonos) {
        sum += abono.cantidadPagar ?? 0.0;
      }
      return sum;
    } catch (e) {
      print('Error calculating total abonos: $e');
      return 0.0;
    }
  }

  void _reloadAbonos() {
    if (mounted) {
      setState(() {
        _abonosFuture = _fetchAbonos();
        _totalAbonadoFuture = _calculateTotalAbonado(); // Recalculate sum
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error', style: TextStyle(color: _darkGrey)),
          content: Text(message, style: const TextStyle(color: _textGrey)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK', style: TextStyle(color: _primaryRose)),
            ),
          ],
        );
      },
    );
  }

  void _addAbono() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AbonoFormScreen(
          idPedido: widget.idPedido,
          totalPedido: widget.totalPedido,
        );
      },
    ).then((result) {
      if (result == true) {
        _reloadAbonos();
      }
    });
  }

  void _editAbono(Abono abono) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AbonoFormScreen(
          idPedido: widget.idPedido,
          abono: abono,
          totalPedido: widget.totalPedido,
        );
      },
    ).then((result) {
      if (result == true) {
        _reloadAbonos();
      }
    });
  }

  void _deleteAbono(int idAbono) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación', style: TextStyle(color: _darkGrey)),
          content: const Text('¿Está seguro que desea eliminar este abono?', style: TextStyle(color: _textGrey)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No', style: TextStyle(color: _textGrey)),
              style: TextButton.styleFrom(foregroundColor: _primaryRose),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.deleteAbono(idAbono);
                  if (mounted) {
                    Navigator.of(context).pop();
                    _reloadAbonos();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Abono eliminado correctamente', style: TextStyle(color: Colors.white)), backgroundColor: _accentGreen),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    _showErrorDialog('Error al eliminar abono: $e');
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: _accentRed),
              child: const Text('Sí', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: _lightGrey,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Column(
            children: [
              AppBar(
                title: Text('Abonos del Pedido ${widget.idPedido}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                backgroundColor: _primaryRose,
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                elevation: 0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pedido: \$${widget.totalPedido.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, color: _darkGrey, fontWeight: FontWeight.w600),
                    ),
                    FutureBuilder<double>(
                      future: _totalAbonadoFuture,
                      builder: (context, snapshot) {
                        double totalAbonado = snapshot.data ?? 0.0;
                        double saldoPendiente = widget.totalPedido - totalAbonado;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Abonado: \$${totalAbonado.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _accentGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Saldo: \$${saldoPendiente.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: saldoPendiente > 0.01 ? _accentRed : _accentGreen,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Abono>>(
                  future: _abonosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: _primaryRose));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: _accentRed)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No hay abonos para este pedido.', style: TextStyle(color: _textGrey)));
                    } else {
                      final abonos = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(12.0),
                        itemCount: abonos.length,
                        itemBuilder: (context, index) {
                          final abono = abonos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cantidad: \$${abono.cantidadPagar?.toStringAsFixed(2) ?? 'N/A'}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: _darkGrey),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Método de Pago: ${abono.metodoPago ?? 'N/A'}',
                                          style: const TextStyle(fontSize: 15, color: _textGrey),
                                        ),
                                        
                                        if (abono.urlImagen != null && abono.urlImagen!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                abono.urlImagen!,
                                                height: 80,
                                                width: 80,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: _textGrey),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                        onPressed: () => _editAbono(abono),
                                        tooltip: 'Editar Abono',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: _accentRed),
                                        onPressed: () => _deleteAbono(abono.idAbono!),
                                        tooltip: 'Eliminar Abono',
                                      ),
                                    ],
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: ElevatedButton.icon(
                  onPressed: _addAbono,
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                  label: const Text('Agregar Nuevo Abono', style: TextStyle(color: Colors.white, fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryRose,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}