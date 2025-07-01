import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/routes.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
       appBar: AppBar(
        title: const Text('Panel de Administrador'),
        automaticallyImplyLeading: false, 
      ),
      body: LoadingWidget(
        isLoading: authProvider.isLoading,
        child: user == null
            ? const Center(child: Text('Cargando información del administrador...'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(
                          user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : 'A',
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        '¡Bienvenido, ${user.nombre} ${user.apellido}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: const Text(
                          'ADMINISTRADOR',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildInfoCard(
                      icon: Icons.email,
                      title: 'Correo Electrónico',
                      subtitle: user.correo,
                    ),
                    _buildInfoCard(
                      icon: Icons.badge,
                      title: 'Documento',
                      subtitle: '${user.tipoDocumento}: ${user.documento}',
                    ),
                    _buildInfoCard(
                      icon: Icons.admin_panel_settings,
                      title: 'Rol',
                      subtitle: 'Administrador del Sistema',
                    ),
                    _buildInfoCard(
                      icon: Icons.verified_user,
                      title: 'Estado',
                      subtitle: user.estado ? 'Activo' : 'Inactivo',
                      isStatus: true,
                      isActive: user.estado,
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: CustomButton(
                        text: 'Editar Mi Perfil',
                        onPressed: () async {
                          final result = await Navigator.of(context).pushNamed(AppRoutes.adminProfile);
                          // Si regresa de editar perfil, refrescar los datos
                          if (result == true && mounted) {
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            await authProvider.loadProfileFromApi();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon, 
    required String title, 
    required String subtitle,
    bool isStatus = false,
    bool isActive = false,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Theme.of(context).primaryColor),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  isStatus 
                    ? Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}