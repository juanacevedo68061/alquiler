import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/vehiculos/vehiculos_screen.dart';
import 'screens/clientes/clientes_screen.dart';
import 'screens/reservas/reservas_screen.dart';
import 'screens/entregas/entregas_screen.dart';
import 'screens/estadisticas/estadisticas_screen.dart';
import 'utils/app_routes.dart';

void main() {
  runApp(const AlquilerAutosApp());
}

class AlquilerAutosApp extends StatelessWidget {
  const AlquilerAutosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Alquiler de Autos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Pantalla inicial
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.vehiculos: (context) => const VehiculosScreen(),
        AppRoutes.clientes: (context) => const ClientesScreen(),
        AppRoutes.reservas: (context) => const ReservasScreen(),
        AppRoutes.entregas: (context) => const EntregasScreen(),
        AppRoutes.estadisticas: (context) => const EstadisticasScreen(),
      },
    );
  }
}
