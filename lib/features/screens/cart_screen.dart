import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_services.dart';
import '../models/cart_models.dart';
import '../models/General_models.dart'; 
import 'products/Detail/ObleaDetailScreen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Carrito'),
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartService.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Tu carrito está vacío.',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // O navega a tu pantalla de productos
                    },
                    child: const Text('Comenzar a comprar'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartService.items.length,
                  itemBuilder: (context, index) {
                    final item = cartService.items[index];
                    return CartItemWidget(item: item);
                  },
                ),
              ),
              _buildCartSummary(context, cartService),
              _buildCheckoutButton(context, cartService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartService cartService) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:', style: TextStyle(fontSize: 16)),
              Text('\$${cartService.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('IVA (19%):', style: TextStyle(fontSize: 16)),
              Text('\$${cartService.iva.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('\$${cartService.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, CartService cartService) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: cartService.isEmpty
            ? null
            : () {
                // TODO: Navegar a la pantalla de checkout
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Procediendo al pago... (Funcionalidad en desarrollo)')),
                );
              },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50), // Botón de ancho completo
        ),
        child: const Text('Proceder al Pago', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                // Imagen del producto (si existe)
                if (item.producto.urlImg != null && item.producto.urlImg!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      item.producto.urlImg!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80),
                    ),
                  )
                else
                  const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.producto.nombreProducto,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text('Precio Unitario: \$${item.precioUnitario.toStringAsFixed(2)}'),
                      Text('Subtotal Item: \$${item.subtotal.toStringAsFixed(2)}'),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              cartService.updateQuantity(item.id, item.cantidad - 1);
                            },
                          ),
                          Text('${item.cantidad}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              cartService.updateQuantity(item.id, item.cantidad + 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
               TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ObleaDetailScreen(
                          product: item.producto,
                          existingCartItem: item,
                        ),
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Ver Detalles'),
                  onPressed: () {
                    _showItemDetails(context, item);
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    _confirmRemoval(context, item, cartService);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(BuildContext context, CartItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de ${item.producto.nombreProducto}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Cantidad: ${item.cantidad}'),
                Text('Precio Unitario: \$${item.precioUnitario.toStringAsFixed(2)}'),
                Text('Subtotal: \$${item.subtotal.toStringAsFixed(2)}'),
                const Divider(),
                const Text('Configuraciones de Oblea:', style: TextStyle(fontWeight: FontWeight.bold)),
                if (item.configuraciones.isEmpty)
                  const Text('Ninguna configuración aplicada.')
                else
                  ...item.configuraciones.map((config) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('  Tipo de Oblea: ${config.tipoOblea}'),
                          Text('  Precio Configuración: \$${config.precio.toStringAsFixed(2)}'),
                          if (config.ingredientesPersonalizados.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('  Ingredientes Personalizados:'),
                                ...config.ingredientesPersonalizados.entries.map((entry) =>
                                    Text('    ${entry.key}: ${entry.value}')),
                              ],
                            ),
                          const SizedBox(height: 5),
                        ],
                      )),
                const Divider(),
                const Text('Detalles de Personalización Adicional:', style: TextStyle(fontWeight: FontWeight.bold)),
                if (item.detallesPersonalizacion.isEmpty)
                  const Text('Ningún detalle de personalización adicional.')
                else
                  ...item.detallesPersonalizacion.entries.map((entry) =>
                      Text('  ${entry.key}: ${entry.value}')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmRemoval(BuildContext context, CartItem item, CartService cartService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar del Carrito'),
          content: Text('¿Estás seguro de que quieres eliminar "${item.producto.nombreProducto}" del carrito?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                cartService.removeFromCart(item.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.producto.nombreProducto} eliminado del carrito.')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}