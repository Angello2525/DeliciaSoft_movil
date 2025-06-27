import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/routes.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart'; // IMPORTACIÓN AGREGADA

class ClientDashboard extends StatefulWidget {
  const ClientDashboard({super.key});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final client = authProvider.currentClient;

    return Scaffold(
      body: LoadingWidget(
        isLoading: authProvider.isLoading,
        child: client == null
            ? const Center(child: Text('Cargando información del cliente...'))
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
                          client.nombre.isNotEmpty ? client.nombre[0].toUpperCase() : 'C',
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        '¡Bienvenido, ${client.nombre} ${client.apellido}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildInfoCard(
                      icon: Icons.email,
                      title: 'Correo Electrónico',
                      subtitle: client.correo,
                    ),
                    _buildInfoCard(
                      icon: Icons.badge,
                      title: 'Documento',
                      subtitle: '${client.tipoDocumento}: ${client.numeroDocumento}',
                    ),
                    _buildInfoCard(
                      icon: Icons.location_on,
                      title: 'Dirección',
                      subtitle: '${client.direccion}, ${client.barrio}, ${client.ciudad}',
                    ),
                    _buildInfoCard(
                      icon: Icons.phone,
                      title: 'Celular',
                      subtitle: client.celular,
                    ),
                    _buildInfoCard(
                      icon: Icons.calendar_today,
                      title: 'Fecha de Nacimiento',
                      subtitle: Constants.formatDate(client.fechaNacimiento),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: CustomButton(
                        text: 'Ver Mi Perfil',
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.clientProfile);
                        },
                      ),
                    ),
                   
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String title, required String subtitle}) {
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
                  Text(
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