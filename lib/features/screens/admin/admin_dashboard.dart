// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart'; // Importa el UserProvider
import '../../utils/routes.dart';
import '../../utils/constants.dart';
import '../../models/usuario.dart';
import '../../models/cliente.dart';
import '../../models/rol.dart'; // Importa Rol
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_text_field.dart'; // Asegúrate de que esto esté importado

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).loadUsuarios();
      Provider.of<UserProvider>(context, listen: false).loadClientes();
      Provider.of<UserProvider>(context, listen: false).loadRoles(); // Cargar roles
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.adminProfile);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Usuarios'),
            Tab(text: 'Clientes'),
          ],
        ),
      ),
      body: LoadingWidget(
        isLoading: authProvider.isLoading || userProvider.isLoading,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildUsersList(userProvider),
            _buildClientsList(userProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList(UserProvider userProvider) {
    // Manejo de errores para loadUsuarios
    if (userProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error al cargar usuarios: ${userProvider.error}'),
            ElevatedButton(
              onPressed: userProvider.loadUsuarios,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: userProvider.loadUsuarios,
      child: userProvider.usuarios.isEmpty && !userProvider.isLoading
          ? const Center(child: Text('No hay usuarios registrados.'))
          : ListView.builder(
              itemCount: userProvider.usuarios.length,
              itemBuilder: (context, index) {
                final user = userProvider.usuarios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${user.nombre} ${user.apellido}'),
                    subtitle: Text('Correo: ${user.correo}\nDocumento: ${user.documento}'),
                    trailing: Switch(
                      value: user.estado,
                      onChanged: (bool newValue) async {
                        final errorMessage = await userProvider.toggleUsuarioStatus(user.idUsuario, user.estado);
                        if (!mounted) return;
                        if (errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMessage)),
                          );
                        } else {
                           ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Estado de usuario ${newValue ? "activado" : "desactivado"}')),
                          );
                        }
                      },
                    ),
                    onTap: () => _showEditUserDialog(context, userProvider, user),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildClientsList(UserProvider userProvider) {
    // Manejo de errores para loadClientes
    if (userProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error al cargar clientes: ${userProvider.error}'),
            ElevatedButton(
              onPressed: userProvider.loadClientes,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: userProvider.loadClientes,
      child: userProvider.clientes.isEmpty && !userProvider.isLoading
          ? const Center(child: Text('No hay clientes registrados.'))
          : ListView.builder(
              itemCount: userProvider.clientes.length,
              itemBuilder: (context, index) {
                final client = userProvider.clientes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('${client.nombre} ${client.apellido}'),
                    subtitle: Text('Correo: ${client.correo}\nCelular: ${client.celular}'),
                    trailing: Switch(
                      value: client.estado,
                      onChanged: (bool newValue) async {
                        final errorMessage = await userProvider.toggleClientStatus(client.idCliente, client.estado);
                        if (!mounted) return;
                        if (errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMessage)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Estado de cliente ${newValue ? "activado" : "desactivado"}')),
                          );
                        }
                      },
                    ),
                    onTap: () => _showEditClientDialog(context, userProvider, client),
                  ),
                );
              },
            ),
    );
  }

  void _showEditUserDialog(BuildContext context, UserProvider userProvider, Usuario user) {
    final nameController = TextEditingController(text: user.nombre);
    final lastNameController = TextEditingController(text: user.apellido);
    final emailController = TextEditingController(text: user.correo);
    final docTypeController = TextEditingController(text: user.tipoDocumento);
    final docNumberController = TextEditingController(text: user.documento.toString());

    // Asegúrate de que selectedRoleId tenga un valor inicial válido.
    // Si idRolNavigation es null o idRol es 0 (o cualquier valor por defecto inválido),
    // podrías establecer un valor por defecto o manejar el caso.
    // Convertir a String para que coincida con el tipo del DropdownButtonFormField
    String? selectedRoleId = user.idRol.toString();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder( // Usa StatefulBuilder para que el Dropdown se actualice
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Editar Usuario'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(controller: nameController, labelText: 'Nombre'),
                    const SizedBox(height: 10),
                    CustomTextField(controller: lastNameController, labelText: 'Apellido'),
                    const SizedBox(height: 10),
                    CustomTextField(controller: emailController, labelText: 'Correo Electrónico', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 10),
                    CustomTextField(controller: docTypeController, labelText: 'Tipo Documento', readOnly: true),
                    const SizedBox(height: 10),
                    CustomTextField(controller: docNumberController, labelText: 'Número Documento', readOnly: true),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedRoleId,
                      decoration: const InputDecoration(
                        labelText: 'Rol',
                        border: OutlineInputBorder(),
                      ),
                      items: userProvider.roles.map((rol) {
                        return DropdownMenuItem<String>(
                          value: rol.idRol.toString(),
                          child: Text(rol.rol1),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() { // Usa setState del StatefulBuilder
                          selectedRoleId = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedRoleId == null) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Por favor, selecciona un rol.')),
                      );
                      return;
                    }

                    final updatedUser = user.copyWith(
                      nombre: nameController.text,
                      apellido: lastNameController.text,
                      correo: emailController.text,
                      idRol: int.parse(selectedRoleId!),
                      // No se modifican documento ni tipoDocumento desde aquí si son readOnly
                    );
                    final errorMessage = await userProvider.updateUsuario(updatedUser);
                    if (!mounted) return;
                    if (errorMessage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Usuario actualizado exitosamente.')),
                      );
                      Navigator.of(dialogContext).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditClientDialog(BuildContext context, UserProvider userProvider, Cliente cliente) {
    final nameController = TextEditingController(text: cliente.nombre);
    final lastNameController = TextEditingController(text: cliente.apellido);
    final emailController = TextEditingController(text: cliente.correo);
    final addressController = TextEditingController(text: cliente.direccion);
    final neighborhoodController = TextEditingController(text: cliente.barrio);
    final phoneNumberController = TextEditingController(text: cliente.celular);

    // Asigna el valor actual de la ciudad del cliente
    String? selectedCity = cliente.ciudad;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder( // Usa StatefulBuilder para que el Dropdown se actualice
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Editar Cliente'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(controller: nameController, labelText: 'Nombre'),
                    const SizedBox(height: 10),
                    CustomTextField(controller: lastNameController, labelText: 'Apellido'),
                    const SizedBox(height: 10),
                    CustomTextField(controller: emailController, labelText: 'Correo Electrónico', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 10),
                    CustomTextField(controller: addressController, labelText: 'Dirección'),
                    const SizedBox(height: 10),
                    CustomTextField(controller: neighborhoodController, labelText: 'Barrio'),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedCity,
                      decoration: const InputDecoration(
                        labelText: 'Ciudad',
                        border: OutlineInputBorder(),
                      ),
                      items: Constants.colombianCities.map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() { // Usa setState del StatefulBuilder
                          selectedCity = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    CustomTextField(controller: phoneNumberController, labelText: 'Celular', keyboardType: TextInputType.phone),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedCity == null || selectedCity!.isEmpty) {
                       ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(content: Text('Por favor, selecciona una ciudad.')),
                      );
                      return;
                    }
                    
                    final updatedCliente = cliente.copyWith(
                      nombre: nameController.text,
                      apellido: lastNameController.text,
                      correo: emailController.text,
                      direccion: addressController.text,
                      barrio: neighborhoodController.text,
                      ciudad: selectedCity,
                      celular: phoneNumberController.text,
                      // No se modifican tipoDocumento, numeroDocumento ni fechaNacimiento desde aquí si son readOnly
                    );
                    final errorMessage = await userProvider.updateCliente(updatedCliente);
                    if (!mounted) return;
                    if (errorMessage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cliente actualizado exitosamente.')),
                      );
                      Navigator.of(dialogContext).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(errorMessage)),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}