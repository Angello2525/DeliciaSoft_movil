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
          title: const Text('Confirmar Anulación'),
          content: Text('¿Está seguro que desea anular el pedido Nro $pedidoId?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _canceledPedidoIds.add(pedidoId); // Add to canceled set
                });
                Navigator.of(context).pop(); // Dismiss dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pedido Nro $pedidoId anulado.')),
                );
              },
              child: const Text('Sí'),
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

  Widget _buildExpandableDetails(Pedido pedido) {
    if (pedido.idVenta == null) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Este pedido no tiene una venta asociada.'),
      );
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchFullPedidoDetails(pedido.idVenta!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Error al cargar detalles adicionales: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No se encontraron detalles adicionales.'),
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
                const Divider(height: 20, thickness: 1),
                const Text(
                  'Detalles de Venta:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                if (detallesVenta.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, top: 4.0),
                    child: Text('No hay detalles de venta para esta venta.'),
                  ),
                ...detallesVenta.map((detalle) => _buildDetalleVentaExpansionTile(detalle)),
                const Divider(),
                _buildInfoRow('Observaciones del Pedido', pedido.observaciones.isEmpty ? 'N/A' : pedido.observaciones),
                _buildInfoRow('Mensaje Personalizado', pedido.mensajePersonalizado.isEmpty ? 'N/A' : pedido.mensajePersonalizado),
                _buildInfoRow('Fecha de Entrega del Pedido', DateFormat('dd/MM/yyyy HH:mm').format(pedido.fechaEntrega)),
                const SizedBox(height: 10),
                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Abonos Button
                    if (pedido.idPedido != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ElevatedButton.icon(
                          onPressed: () => _showAbonosModal(pedido.idPedido!),
                          icon: const Icon(Icons.account_balance_wallet),
                          label: const Text('Abonos'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Abonos button color
                            foregroundColor: Colors.white, // Text color
                          ),
                        ),
                      ),
                    // "Anular Pedido" button
                    if (!_canceledPedidoIds.contains(pedido.idPedido))
                      ElevatedButton.icon(
                        onPressed: () => _cancelPedido(pedido.idPedido!),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Anular Pedido'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, // Button color
                          foregroundColor: Colors.white, // Text color
                        ),
                      ),
                  ],
                ),
                if (_canceledPedidoIds.contains(pedido.idPedido))
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Pedido Anulado',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
          return const ListTile(title: Text('Cargando producto...'));
        } else if (productSnapshot.hasError) {
          return ListTile(title: Text('Error al cargar producto: ${productSnapshot.error}'));
        } else {
          final productoGeneral = productSnapshot.data;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            elevation: 0.5,
            color: Colors.blueGrey[50],
            child: ExpansionTile(
              title: Text(
                'Producto: ${productoGeneral?.nombreProducto ?? 'N/A'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Cantidad', detalle.cantidad?.toString() ?? 'N/A'),
                      _buildInfoRow('Subtotal', detalle.subtotal?.toStringAsFixed(2) ?? 'N/A'),
                      _buildInfoRow('IVA', detalle.iva?.toStringAsFixed(2) ?? 'N/A'),
                      _buildInfoRow('Total', detalle.total?.toStringAsFixed(2) ?? 'N/A'),
                      const SizedBox(height: 8.0),
                      if (detalle.idDetalleVenta != null)
                        FutureBuilder<List<DetalleAdicione>>(
                          future: ApiService.getDetalleAdicionesByDetalleVentaId(detalle.idDetalleVenta!),
                          builder: (context, adicionesSnapshot) {
                            if (adicionesSnapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.only(left: 8.0, top: 4.0),
                                child: Text('Cargando adiciones...'),
                              );
                            } else if (adicionesSnapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                                child: Text('Error al cargar adiciones: ${adicionesSnapshot.error}'),
                              );
                            } else if (!adicionesSnapshot.hasData || adicionesSnapshot.data!.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(left: 8.0, top: 4.0),
                                child: Text('No hay adiciones para este detalle de venta.'),
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Adiciones:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  ...adicionesSnapshot.data!.map((adicione) => FutureBuilder<Map<String, String>>(
                                        future: _fetchAdicionNames(adicione),
                                        builder: (context, namesSnapshot) {
                                          if (namesSnapshot.connectionState == ConnectionState.waiting) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                                              child: Text('  Cargando nombres de adiciones...'),
                                            );
                                          } else if (namesSnapshot.hasError) {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                                              child: Text('  Error al cargar nombres: ${namesSnapshot.error}'),
                                            );
                                          } else {
                                            final names = namesSnapshot.data!;
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('  - Adición: ${names['adicionNombre']}'),
                                                  Text('    Sabor: ${names['saborNombre']}'),
                                                  Text('    Relleno: ${names['rellenoNombre']}'),
                                                  Text('    Cantidad: ${adicione.cantidadAdicionada?.toStringAsFixed(2) ?? 'N/A'}'),
                                                  Text('    Precio Unitario: ${adicione.precioUnitario?.toStringAsFixed(2) ?? 'N/A'}'),
                                                  Text('    Subtotal: ${adicione.subtotal?.toStringAsFixed(2) ?? 'N/A'}'),
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
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pedidos'),
        backgroundColor: const Color.fromARGB(255, 255, 68, 236),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadPedidos,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pedidos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 68, 236),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por Nro. Pedido, Cliente o Fecha de Entrega',
                    hintText: 'Ej. 123, Juan Pérez, 30/06/2025',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged();
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _pedidosWithClientFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay pedidos disponibles.'));
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
                    return const Center(child: Text('No se encontraron pedidos que coincidan con la búsqueda.'));
                  }

                  return ListView.builder(
                    itemCount: filteredPedidos.length,
                    itemBuilder: (context, index) {
                      final pedidoData = filteredPedidos[index];
                      final Pedido pedido = pedidoData['pedido'];
                      final String clientName = pedidoData['clientName'];
                      final bool isExpanded = _expandedPedidoId == pedido.idPedido;
                      final double opacity = _canceledPedidoIds.contains(pedido.idPedido) ? 0.5 : 1.0;

                      return Opacity(
                        opacity: opacity,
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          color: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  'Pedido Nro: ${pedido.idPedido} - Cliente: $clientName - Entrega: ${DateFormat('dd/MM/yyyy HH:mm').format(pedido.fechaEntrega)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                trailing: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
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