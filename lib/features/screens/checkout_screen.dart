import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/cart_services.dart'; 
import '../services/api_service.dart';
import '../services/sede_service.dart';
import '../models/venta/pedido.dart';
import '../models/venta/abono.dart';
import '../models/venta/venta.dart';
import '../models/venta/detalle_venta.dart';
import '../models/venta/sede.dart';

class CheckoutScreen extends StatefulWidget {
  final int clientId;
  
  const CheckoutScreen({
    super.key,
    required this.clientId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _observaciones;
  DateTime? _fechaEntrega;
  String? _mensajePersonalizado;
  String _metodoPago = 'Efectivo';
  XFile? _imagenArchivo;
  bool _estaCargando = false;
  int? _sedeSeleccionada;
  List<Sede> _sedes = [];

  // Colores del tema rosa
  static const Color _primaryPink = Color(0xFFE91E63);
  static const Color _lightPink = Color(0xFFF8BBD9);
  static const Color _mediumPink = Color(0xFFEC407A);
  static const Color _darkPink = Color(0xFFC2185B);
  static const Color _accentPink = Color(0xFFFF4081);
  static const Color _backgroundPink = Color(0xFFFCE4EC);

  @override
  void initState() {
    super.initState();
    _cargarSedes();
    _establecerFechaMinima();
  }

  void _cargarSedes() {
    _sedes = SedeService.getSedes();
    if (_sedes.isNotEmpty) {
      setState(() {
        _sedeSeleccionada = _sedes.first.idSede;
      });
    }
  }

  void _establecerFechaMinima() {
    final fechaMinima = DateTime.now().add(const Duration(days: 15));
    setState(() {
      _fechaEntrega = fechaMinima;
    });
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (mounted) {
      setState(() {
        _imagenArchivo = pickedFile;
      });
    }
  }

  Future<void> _seleccionarFechaEntrega() async {
    final fechaMinima = DateTime.now().add(const Duration(days: 15));
    final fechaMaxima = DateTime.now().add(const Duration(days: 30));
    
    final fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaEntrega ?? fechaMinima,
      firstDate: fechaMinima,
      lastDate: fechaMaxima,
      helpText: 'Seleccionar fecha de entrega',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primaryPink,
              onPrimary: Colors.white,
              secondary: _accentPink,
              onSecondary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (fechaSeleccionada != null && mounted) {
      setState(() {
        _fechaEntrega = fechaSeleccionada;
      });
    }
  }

  String _validarFechaEntrega() {
    if (_fechaEntrega == null) {
      return 'Debe seleccionar una fecha de entrega';
    }
    
    final ahora = DateTime.now();
    final fechaMinima = ahora.add(const Duration(days: 15));
    final fechaMaxima = ahora.add(const Duration(days: 30));
    
    if (_fechaEntrega!.isBefore(fechaMinima)) {
      return 'La fecha de entrega debe ser mínimo 15 días desde hoy';
    }
    
    if (_fechaEntrega!.isAfter(fechaMaxima)) {
      return 'La fecha de entrega debe ser máximo 30 días desde hoy';
    }
    
    return '';
  }

  Future<void> _enviarPedido() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validar fecha de entrega
    final errorFecha = _validarFechaEntrega();
    if (errorFecha.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorFecha),
            backgroundColor: _darkPink,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }

    // Validar sede seleccionada
    if (_sedeSeleccionada == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe seleccionar una sede'),
            backgroundColor: _darkPink,
          ),
        );
      }
      return;
    }

    // Validar comprobante para transferencia
    if (_metodoPago == 'Transferencia' && _imagenArchivo == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, sube el comprobante de pago'),
            backgroundColor: _darkPink,
          ),
        );
      }
      return;
    }

    _formKey.currentState!.save();

    if (mounted) {
      setState(() { _estaCargando = true; });
    }

    final cartService = Provider.of<CartService>(context, listen: false);
    final totalPedido = cartService.total;
    final montoAPagar = totalPedido * 0.5;

    try {
      // 1. Crear la Venta
      final venta = Venta(
        idVenta: 0,
        idCliente: widget.clientId,
        idSede: _sedeSeleccionada!,
        fechaVenta: DateTime.now(),
        metodoPago: _metodoPago,
        tipoVenta: 'Normal',    
        estadoVenta: true,     
      );
      final ventaCreada = await ApiService.createVenta(venta);

      // 2. Crear los Detalles de la Venta
      for (final item in cartService.items) {
        final precioUnitario = item.precioUnitario;
        final cantidad = item.cantidad;
        final subtotal = precioUnitario * cantidad;
        final iva = subtotal * 0.19;
        final total = subtotal + iva;
        
        final detalleVenta = DetalleVenta(
          idDetalleVenta: 0,
          idVenta: ventaCreada.idVenta,
          idProductoGeneral: item.producto.idProductoGeneral,
          cantidad: cantidad,
          precioUnitario: precioUnitario,
          subtotal: subtotal,
          iva: iva,
          total: total,
        );
        await ApiService.createDetalleVenta(detalleVenta);
      }

      // 3. Crear el Pedido
      final pedido = Pedido(
        idPedido: 0,
        idVenta: ventaCreada.idVenta,
        observaciones: _observaciones ?? '',
        fechaEntrega: _fechaEntrega!,
        mensajePersonalizado: _mensajePersonalizado ?? '',
      );
      final pedidoCreado = await ApiService.createPedido(pedido);

      // 4. Procesar el Abono
      int? idImagen;
      if (_metodoPago == 'Transferencia' && _imagenArchivo != null) {
        final imagenSubida = await ApiService.uploadImage(_imagenArchivo!);
        idImagen = imagenSubida.idImagen;
      }

      final abono = Abono(
        idPedido: pedidoCreado.idPedido,
        metodoPago: _metodoPago,
        idImagen: idImagen,
        cantidadPagar: montoAPagar,
      );
      await ApiService.createAbono(abono);

      // 5. Limpiar carrito y mostrar éxito
      cartService.clearCart();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('¡Pedido realizado con éxito!'),
              ],
            ),
            backgroundColor: _mediumPink,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

    } catch (e) {
      print('Error detallado: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar el pedido: $e'),
            backgroundColor: _darkPink,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _estaCargando = false; });
      }
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _lightPink.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        final totalPedido = cartService.total;
        final montoAPagar = totalPedido * 0.5;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Finalizar Compra',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            backgroundColor: _primaryPink,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: true,
          ),
          body: _estaCargando
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_backgroundPink, Colors.white],
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(_primaryPink),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_backgroundPink, Colors.white],
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Información del Pedido
                          _buildCard(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _lightPink,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.info_outline,
                                          color: _primaryPink,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Información del Pedido',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: _primaryPink,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Selección de Sede
                                  const Text(
                                    'Sede para recoger:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _darkPink,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: _lightPink, width: 2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: _sedes.map((sede) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: _sedeSeleccionada == sede.idSede 
                                                ? _lightPink.withOpacity(0.5)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: RadioListTile<int>(
                                            title: Text(
                                              sede.nombre,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: _darkPink,
                                              ),
                                            ),
                                            subtitle: Text(
                                              '${sede.direccion}\nTel: ${sede.telefono}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            value: sede.idSede,
                                            groupValue: _sedeSeleccionada,
                                            activeColor: _primaryPink,
                                            onChanged: (value) {
                                              setState(() {
                                                _sedeSeleccionada = value;
                                              });
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Fecha de Entrega
                                  const Text(
                                    'Fecha de entrega:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _darkPink,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: _lightPink, width: 2),
                                      borderRadius: BorderRadius.circular(12),
                                      color: _backgroundPink.withOpacity(0.3),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _primaryPink,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_today,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        _fechaEntrega != null
                                            ? DateFormat('dd/MM/yyyy').format(_fechaEntrega!)
                                            : 'Seleccionar fecha',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _darkPink,
                                        ),
                                      ),
                                      subtitle: const Text(
                                        'Mínimo 15 días, máximo 30 días',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: _primaryPink,
                                      ),
                                      onTap: _seleccionarFechaEntrega,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Observaciones
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Observaciones (opcional)',
                                      labelStyle: const TextStyle(color: _primaryPink),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: _lightPink),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: _lightPink, width: 2),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: _primaryPink, width: 2),
                                      ),
                                      hintText: 'Detalles adicionales sobre el pedido',
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      filled: true,
                                      fillColor: _backgroundPink.withOpacity(0.2),
                                    ),
                                    maxLines: 3,
                                    onSaved: (value) => _observaciones = value,
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Mensaje Personalizado
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Mensaje personalizado (opcional)',
                                      labelStyle: const TextStyle(color: _primaryPink),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: _lightPink),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: _lightPink, width: 2),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: _primaryPink, width: 2),
                                      ),
                                      hintText: 'Mensaje que aparecerá en el producto',
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      filled: true,
                                      fillColor: _backgroundPink.withOpacity(0.2),
                                    ),
                                    maxLines: 2,
                                    onSaved: (value) => _mensajePersonalizado = value,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          // Resumen de Pago
                          _buildCard(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _lightPink,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.payment,
                                          color: _primaryPink,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Resumen de Pago',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: _primaryPink,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [_lightPink.withOpacity(0.3), _backgroundPink.withOpacity(0.2)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Total del Pedido:',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: _darkPink,
                                              ),
                                            ),
                                            Text(
                                              '\$${totalPedido.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: _darkPink,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        const Divider(color: _lightPink),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Monto a Pagar (50%):',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: _primaryPink,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: _primaryPink,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '\$${montoAPagar.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'El 50% restante se paga al recoger el pedido',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Método de Pago
                          _buildCard(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _lightPink,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.credit_card,
                                          color: _primaryPink,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Método de Pago',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: _primaryPink,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: _lightPink, width: 2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: _metodoPago == 'Efectivo' 
                                                ? _lightPink.withOpacity(0.5)
                                                : Colors.transparent,
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: RadioListTile<String>(
                                            title: const Text(
                                              'Efectivo',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: _darkPink,
                                              ),
                                            ),
                                            subtitle: const Text(
                                              'Pagar en la sede al recoger el pedido',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                            value: 'Efectivo',
                                            groupValue: _metodoPago,
                                            activeColor: _primaryPink,
                                            onChanged: (value) {
                                              if (mounted) {
                                                setState(() => _metodoPago = value!);
                                              }
                                            },
                                          ),
                                        ),
                                        const Divider(height: 1, color: _lightPink),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: _metodoPago == 'Transferencia' 
                                                ? _lightPink.withOpacity(0.5)
                                                : Colors.transparent,
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: RadioListTile<String>(
                                            title: const Text(
                                              'Transferencia Bancaria',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: _darkPink,
                                              ),
                                            ),
                                            subtitle: const Text(
                                              'Sube el comprobante de pago',
                                              style: TextStyle(color: Colors.grey),
                                            ),
                                            value: 'Transferencia',
                                            groupValue: _metodoPago,
                                            activeColor: _primaryPink,
                                            onChanged: (value) {
                                              if (mounted) {
                                                setState(() => _metodoPago = value!);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Comprobante de Pago
                          if (_metodoPago == 'Transferencia')
                            _buildCard(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: _lightPink,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.upload_file,
                                            color: _primaryPink,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Comprobante de Pago',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: _primaryPink,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [_lightPink.withOpacity(0.3), _backgroundPink.withOpacity(0.2)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: _lightPink, width: 2),
                                      ),
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Comprobante de Pago',
                                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton.icon(
                                            onPressed: _seleccionarImagen,
                                            icon: const Icon(Icons.upload_file),
                                            label: const Text('Subir Comprobante'),
                                            style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white, 
                                              backgroundColor: Colors.teal,
                                              minimumSize: const Size(200, 45),
                                            ),
                                          ),
                                          if (_imagenArchivo != null)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Archivo: ${_imagenArchivo!.name}',
                                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 30),

                          // --- Botón de Confirmación ---
                          ElevatedButton(
                            onPressed: _enviarPedido,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: _primaryPink,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Confirmar Pedido',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
              ),
            );
           },
        );
      }
  }
