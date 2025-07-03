import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/venta/pedido.dart';
import '../../../models/venta/detalle_venta.dart';
import '../../../models/venta/producto_general.dart';
import '../../../models/venta/venta.dart';
import '../../../models/cliente.dart';
import '../../../models/venta/sede.dart';
import '../../../models/venta/detalle_adicione.dart';
import '../../../services/api_service.dart';
import '../../../models/venta/catalogo_adicione.dart';
import '../../../models/venta/catalogo_sabor.dart';
import '../../../models/venta/catalogo_relleno.dart';
import 'abono_list_modal.dart'; // Import the new AbonoListModal

class PedidoListScreen extends StatefulWidget {
  const PedidoListScreen({super.key});

  @override
  State<PedidoListScreen> createState() => _PedidoListScreenState();
}

class _PedidoListScreenState extends State<PedidoListScreen> {
  late Future<List<Map<String, dynamic>>> _pedidosWithClientFuture;
  int? _expandedPedidoId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<int> _canceledPedidoIds = {};

  // Define your refined color palette
  static const Color _primaryRose = Color.fromRGBO(228, 48, 84, 1);
  static const Color _darkGrey = Color(0xFF333333);
  static const Color _lightGrey = Color(0xFFF5F5F5); // For main background
  static const Color _mediumGrey = Color(0xFFE0E0E0); // For borders and dividers
  static const Color _textGrey = Color(0xFF555555); // For general text
  static const Color _accentYellow = Colors.amber; // Minimal yellow, can be adjusted further if needed

  @override
  void initState() {
    super.initState();
    _pedidosWithClientFuture = _fetchPedidosWithClientNames();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _expandedPedidoId = null; // Collapse any expanded tiles when searching
    });
  }

  Future<List<Map<String, dynamic>>> _fetchPedidosWithClientNames() async {
    try {
      final List<Pedido> pedidos = await ApiService.getPedidos();
      List<Map<String, dynamic>> pedidosWithClient = [];

      for (var pedido in pedidos) {
        String clientName = 'N/A';
        if (pedido.idVenta != null) {
          try {
            final Venta venta = await ApiService.getVentaById(pedido.idVenta!);
            if (venta.idCliente != null) {
              final Cliente cliente = await ApiService.getClienteById(venta.idCliente!);
              clientName = cliente.nombre ?? 'N/A';
            }
          } catch (e) {
            print('Error fetching client for pedido ${pedido.idPedido}: $e');
          }
        }
        pedidosWithClient.add({
          'pedido': pedido,
          'clientName': clientName,
        });
      }
      return pedidosWithClient;
    } catch (e) {
      _showErrorDialog('Error al cargar pedidos y nombres de cliente: $e');
      return [];
    }
  }

  void _reloadPedidos() {
    setState(() {
      _pedidosWithClientFuture = _fetchPedidosWithClientNames();
      _expandedPedidoId = null;
      _searchController.clear();
      _searchQuery = '';
      _canceledPedidoIds.clear(); // Clear canceled orders when reloading
    });
  }

  // Method to handle canceling a pedido
  void _cancelPedido(int pedidoId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Anulación', style: TextStyle(color: _darkGrey)),
          content: Text('¿Está seguro que desea anular el pedido Nro $pedidoId?', style: const TextStyle(color: _textGrey)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: const Text('No', style: TextStyle(color: _primaryRose)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _canceledPedidoIds.add(pedidoId); // Add to canceled set
                });
                Navigator.of(context).pop(); // Dismiss dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pedido Nro $pedidoId anulado.', style: const TextStyle(color: Colors.white))),
                );
              },
              child: const Text('Sí', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // New method to show Abonos modal
  void _showAbonosModal(int idPedido) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AbonoListModal(idPedido: idPedido);
      },
    );
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

  Widget _buildExpandableDetails(Pedido pedido) {
    if (pedido.idVenta == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Este pedido no tiene una venta asociada.', style: TextStyle(color: _textGrey)),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchFullPedidoDetails(pedido.idVenta!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator(color: _primaryRose)),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error al cargar detalles adicionales: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
          );
        } else if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No se encontraron detalles adicionales.', style: TextStyle(color: _textGrey)),
          );
        } else {
          final Venta venta = snapshot.data!['venta'];
          final List<DetalleVenta> detallesVenta = snapshot.data!['detallesVenta'];
          final Cliente? cliente = snapshot.data!['cliente'];
          final Sede? sede = snapshot.data!['sede'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Cliente', cliente?.nombre ?? 'N/A'),
                _buildInfoRow('Fecha de Venta', DateFormat('dd/MM/yyyy HH:mm').format(venta.fechaVenta)),
                _buildInfoRow('Sede', sede?.nombre ?? 'N/A'),
                _buildInfoRow('Método de Pago', venta.metodoPago),
                _buildInfoRow('Tipo de Venta', venta.tipoVenta),
                _buildInfoRow('Estado de Venta', venta.estadoVenta ? 'Completada' : 'Pendiente'),
                const Divider(height: 30, thickness: 1, color: _mediumGrey),
                const Text(
                  'Detalles de Venta:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primaryRose, // Use the new primary rose
                  ),
                ),
                const SizedBox(height: 10),
                if (detallesVenta.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 4.0),
                    child: Text('No hay detalles de venta para esta venta.', style: TextStyle(color: _textGrey)),
                  ),
                ...detallesVenta.map((detalle) => _buildDetalleVentaExpansionTile(detalle)),
                const Divider(height: 30, thickness: 1, color: _mediumGrey),
                _buildInfoRow('Observaciones del Pedido', pedido.observaciones.isEmpty ? 'N/A' : pedido.observaciones),
                _buildInfoRow('Mensaje Personalizado', pedido.mensajePersonalizado.isEmpty ? 'N/A' : pedido.mensajePersonalizado),
                _buildInfoRow('Fecha de Entrega del Pedido', DateFormat('dd/MM/yyyy HH:mm').format(pedido.fechaEntrega)),
                const SizedBox(height: 20),
                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Abonos Button
                    if (pedido.idPedido != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: ElevatedButton.icon(
                          onPressed: () => _showAbonosModal(pedido.idPedido!),
                          icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                          label: const Text('Abonos', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Abonos button color
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    // "Anular Pedido" button
                    if (!_canceledPedidoIds.contains(pedido.idPedido))
                      ElevatedButton.icon(
                        onPressed: () => _cancelPedido(pedido.idPedido!),
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        label: const Text('Anular Pedido', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Button color
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                  ],
                ),
                if (_canceledPedidoIds.contains(pedido.idPedido))
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Text(
                        'Pedido Anulado',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildDetalleVentaExpansionTile(DetalleVenta detalle) {
    return FutureBuilder<ProductoGeneral?>(
      future: detalle.idProductoGeneral != null
          ? ApiService.getProductoGeneralById(detalle.idProductoGeneral!)
          : Future.value(null),
      builder: (context, productSnapshot) {
        if (productSnapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Cargando producto...', style: TextStyle(color: _textGrey)),
            leading: CircularProgressIndicator(color: _primaryRose, strokeWidth: 2),
          );
        } else if (productSnapshot.hasError) {
          return ListTile(title: Text('Error al cargar producto: ${productSnapshot.error}', style: const TextStyle(color: Colors.red)));
        } else {
          final productoGeneral = productSnapshot.data;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            color: _lightGrey, // Slightly darker grey for inner cards
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              title: Text(
                'Producto: ${productoGeneral?.nombreProducto ?? 'N/A'}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _darkGrey),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Cantidad', detalle.cantidad?.toString() ?? 'N/A'),
                      _buildInfoRow('Subtotal', '\$${detalle.subtotal?.toStringAsFixed(2) ?? 'N/A'}'),
                      _buildInfoRow('IVA', '\$${detalle.iva?.toStringAsFixed(2) ?? 'N/A'}'),
                      _buildInfoRow('Total', '\$${detalle.total?.toStringAsFixed(2) ?? 'N/A'}'),
                      const SizedBox(height: 15.0),
                      if (detalle.idDetalleVenta != null)
                        FutureBuilder<List<DetalleAdicione>>(
                          future: ApiService.getDetalleAdicionesByDetalleVentaId(detalle.idDetalleVenta!),
                          builder: (context, adicionesSnapshot) {
                            if (adicionesSnapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.only(left: 8.0, top: 4.0),
                                child: Text('Cargando adiciones...', style: TextStyle(color: _textGrey)),
                              );
                            } else if (adicionesSnapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                child: Text('  Error al cargar adiciones: ${adicionesSnapshot.error}', style: const TextStyle(color: Colors.red)),
                              );
                            } else if (!adicionesSnapshot.hasData || adicionesSnapshot.data!.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(left: 8.0, top: 4.0),
                                child: Text('No hay adiciones para este detalle de venta.', style: TextStyle(color: _textGrey)),
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Adiciones:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryRose, // Use rose for sub-titles
                                    ),
                                  ),
                                  const SizedBox(height: 8.0),
                                  ...adicionesSnapshot.data!.map((adicione) => FutureBuilder<Map<String, String>>(
                                        future: _fetchAdicionNames(adicione),
                                        builder: (context, namesSnapshot) {
                                          if (namesSnapshot.connectionState == ConnectionState.waiting) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                              child: Text('  Cargando nombres de adiciones...', style: TextStyle(color: _textGrey)),
                                            );
                                          } else if (namesSnapshot.hasError) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                              child: Text('  Error al cargar nombres: ${namesSnapshot.error}', style: const TextStyle(color: Colors.red)),
                                            );
                                          } else {
                                            final names = namesSnapshot.data!;
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('  • Adición: ${names['adicionNombre']}', style: const TextStyle(color: _darkGrey)),
                                                  Text('    Sabor: ${names['saborNombre']}', style: const TextStyle(color: _textGrey)),
                                                  Text('    Relleno: ${names['rellenoNombre']}', style: const TextStyle(color: _textGrey)),
                                                  Text('    Cantidad: ${adicione.cantidadAdicionada?.toStringAsFixed(2) ?? 'N/A'}', style: const TextStyle(color: _textGrey)),
                                                  Text('    Precio Unitario: \$${adicione.precioUnitario?.toStringAsFixed(2) ?? 'N/A'}', style: const TextStyle(color: _textGrey)),
                                                  Text('    Subtotal: \$${adicione.subtotal?.toStringAsFixed(2) ?? 'N/A'}', style: const TextStyle(color: _darkGrey, fontWeight: FontWeight.w500)),
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                      )),
                                ],
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<Map<String, String>> _fetchAdicionNames(DetalleAdicione adicione) async {
    String adicionNombre = 'N/A';
    String saborNombre = 'N/A';
    String rellenoNombre = 'N/A';

    if (adicione.idAdiciones != null) {
      try {
        final catalogoAdicione = await ApiService.getCatalogoAdicionesById(adicione.idAdiciones!);
        adicionNombre = catalogoAdicione.nombre ?? 'N/A';
      } catch (e) {
        print('Error fetching CatalogoAdicione: $e');
      }
    }
    if (adicione.idSabor != null) {
      try {
        final catalogoSabor = await ApiService.getCatalogoSaborById(adicione.idSabor!);
        saborNombre = catalogoSabor.nombre ?? 'N/A';
      } catch (e) {
        print('Error fetching CatalogoSabor: $e');
      }
    }
    if (adicione.idRelleno != null) {
      try {
        final catalogoRelleno = await ApiService.getCatalogoRellenoById(adicione.idRelleno!);
        rellenoNombre = catalogoRelleno.nombre ?? 'N/A';
      } catch (e) {
        print('Error fetching CatalogoRelleno: $e');
      }
    }

    return {
      'adicionNombre': adicionNombre,
      'saborNombre': saborNombre,
      'rellenoNombre': rellenoNombre,
    };
  }

  Future<Map<String, dynamic>> _fetchFullPedidoDetails(int idVenta) async {
    try {
      final Venta venta = await ApiService.getVentaById(idVenta);
      final List<DetalleVenta> detallesVenta = await ApiService.getDetalleVentaByVentaId(idVenta);

      Cliente? cliente;
      Sede? sede;

      if (venta.idCliente != null) {
        cliente = await ApiService.getClienteById(venta.idCliente!);
      }
      if (venta.idSede != null) {
        sede = await ApiService.getSedeById(venta.idSede!);
      }

      return {
        'venta': venta,
        'detallesVenta': detallesVenta,
        'cliente': cliente,
        'sede': sede,
      };
    } catch (e) {
      throw Exception('Failed to load full pedido details: $e');
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, color: _darkGrey, fontSize: 15),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: _textGrey, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGrey, // Overall background color
      appBar: AppBar(
        title: const Text('Lista de Pedidos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: _primaryRose, // Use the new primary rose
        elevation: 0, // No shadow for a flatter look
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reloadPedidos,
            tooltip: 'Recargar Pedidos',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestión de Pedidos',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _darkGrey, // Main title color
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por Nro. Pedido, Cliente o Fecha de Entrega',
                    labelStyle: const TextStyle(color: _textGrey),
                    hintText: 'Ej. 123, Juan Pérez, 30/06/2025',
                    hintStyle: const TextStyle(color: _mediumGrey),
                    prefixIcon: const Icon(Icons.search, color: _primaryRose), // Rose search icon
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: _mediumGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: _primaryRose, width: 2.0), // Rose border on focus
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: _mediumGrey),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: _textGrey),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged();
                            },
                          )
                        : null,
                  ),
                  style: const TextStyle(color: _darkGrey),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _pedidosWithClientFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: _primaryRose));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay pedidos disponibles.', style: TextStyle(color: _textGrey)));
                } else {
                  final filteredPedidos = snapshot.data!.where((pedidoData) {
                    final Pedido pedido = pedidoData['pedido'];
                    final String clientName = pedidoData['clientName'].toLowerCase();
                    final String query = _searchQuery.toLowerCase();

                    // Search by Pedido ID
                    if (pedido.idPedido != null && pedido.idPedido.toString().contains(query)) {
                      return true;
                    }
                    // Search by Client Name
                    if (clientName.contains(query)) {
                      return true;
                    }
                    // Search by Delivery Date (formatted as dd/MM/yyyy)
                    final String formattedDate = DateFormat('dd/MM/yyyy').format(pedido.fechaEntrega);
                    if (formattedDate.contains(query)) {
                      return true;
                    }

                    return false;
                  }).toList();

                  if (filteredPedidos.isEmpty) {
                    return const Center(child: Text('No se encontraron pedidos que coincidan con la búsqueda.', style: TextStyle(color: _textGrey)));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    itemCount: filteredPedidos.length,
                    itemBuilder: (context, index) {
                      final pedidoData = filteredPedidos[index];
                      final Pedido pedido = pedidoData['pedido'];
                      final String clientName = pedidoData['clientName'];
                      final bool isExpanded = _expandedPedidoId == pedido.idPedido;
                      final double opacity = _canceledPedidoIds.contains(pedido.idPedido) ? 0.6 : 1.0; // Slightly more visible for canceled

                      return Opacity(
                        opacity: opacity,
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          color: Colors.white, // White card background
                          elevation: 3, // Subtle shadow
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                                title: Text(
                                  'Pedido Nro: ${pedido.idPedido}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: _darkGrey),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Cliente: $clientName', style: const TextStyle(fontSize: 14, color: _textGrey)),
                                    Text('Entrega: ${DateFormat('dd/MM/yyyy HH:mm').format(pedido.fechaEntrega)}', style: const TextStyle(fontSize: 14, color: _textGrey)),
                                  ],
                                ),
                                trailing: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: _primaryRose), // Rose arrow icon
                                onTap: () {
                                  setState(() {
                                    if (isExpanded) {
                                      _expandedPedidoId = null;
                                    } else {
                                      _expandedPedidoId = pedido.idPedido;
                                    }
                                  });
                                },
                              ),
                              if (isExpanded) _buildExpandableDetails(pedido),
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
        ],
      ),
    );
  }
}