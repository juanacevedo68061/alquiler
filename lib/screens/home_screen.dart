import 'package:flutter/material.dart';
import '../utils/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Alquiler de Autos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildMenuCard(
              context,
              'Vehículos',
              Icons.directions_car,
              Colors.blue,
              AppRoutes.vehiculos,
            ),
            _buildMenuCard(
              context,
              'Clientes',
              Icons.people,
              Colors.green,
              AppRoutes.clientes,
            ),
            _buildMenuCard(
              context,
              'Reservas',
              Icons.calendar_today,
              Colors.orange,
              AppRoutes.reservas,
            ),
            _buildMenuCard(
              context,
              'Entregas',
              Icons.check_circle,
              Colors.purple,
              AppRoutes.entregas,
            ),
            _buildMenuCard(
              context,
              'Estadísticas',
              Icons.bar_chart,
              Colors.red,
              AppRoutes.estadisticas,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String route,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
