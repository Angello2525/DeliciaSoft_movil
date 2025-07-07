import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/routes.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_button.dart';

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
      backgroundColor: Colors.grey[50],
      body: LoadingWidget(
        isLoading: authProvider.isLoading,
        child: client == null
            ? const Center(child: Text('Cargando información del cliente...'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header compacto con avatar y bienvenida
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.pink[400]!, Colors.pink[600]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.pink.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child: Text(
                              client.nombre.isNotEmpty ? client.nombre[0].toUpperCase() : 'C',
                              style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Información del cliente
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¡Bienvenido!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${client.nombre} ${client.apellido}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                                  ),
                                  child: const Text(
                                    'CLIENTE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Grid de información compacta
                    _buildInfoGrid(client),

                    const SizedBox(height: 24),

                    // Botón de perfil
                    _buildGradientButton(
                      text: 'Ver Mi Perfil',
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.clientProfile);
                      },
                      icon: Icons.person_outline,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoGrid(client) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: [
        _buildInfoCard(
          icon: Icons.email_outlined,
          title: 'Correo',
          subtitle: client.correo,
        ),
        _buildInfoCard(
          icon: Icons.badge_outlined,
          title: 'Documento',
          subtitle: '${client.tipoDocumento}\n${client.numeroDocumento}',
        ),
        _buildInfoCard(
          icon: Icons.location_on_outlined,
          title: 'Dirección',
          subtitle: '${client.direccion}\n${client.barrio}\n${client.ciudad}',
        ),
        _buildInfoCard(
          icon: Icons.phone_outlined,
          title: 'Celular',
          subtitle: client.celular,
        ),
        _buildInfoCard(
          icon: Icons.cake_outlined,
          title: 'Fecha Nac.',
          subtitle: Constants.formatDate(client.fechaNacimiento),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono con color rosa
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.pink[600],
              ),
            ),
            const SizedBox(height: 12),
            // Título
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            // Contenido
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.2,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink[400]!, Colors.pink[600]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}