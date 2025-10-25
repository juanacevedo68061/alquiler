import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../data/data_store.dart';
import 'widgets/estadistica_card.dart';
import 'widgets/cliente_top_card.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  // Método para calcular estadísticas en tiempo real (solo datos vigentes)
  Map<String, dynamic> _calcularEstadisticas() {
    // Total de reservas activas
    final reservasActivas = DataStore.reservas.where((r) => r.activo).length;

    // Cantidad de vehículos disponibles (solo no eliminados)
    final vehiculosDisponibles = DataStore.vehiculos
        .where((v) => v.disponible && !v.eliminado)
        .length;

    // Cliente con más reservas realizadas (solo clientes no eliminados)
    final Map<int, int> reservasPorCliente = {};

    // Primero obtener todos los clientes no eliminados
    final clientesVigentes = DataStore.clientes
        .where((c) => !c.eliminado)
        .toList();
    final idsClientesVigentes = clientesVigentes.map((c) => c.id).toSet();

    // Contar reservas solo de clientes vigentes
    for (final reserva in DataStore.reservas) {
      if (idsClientesVigentes.contains(reserva.idCliente)) {
        reservasPorCliente[reserva.idCliente] =
            (reservasPorCliente[reserva.idCliente] ?? 0) + 1;
      }
    }

    int? clienteTopId;
    int maxReservas = 0;

    reservasPorCliente.forEach((clienteId, cantidad) {
      if (cantidad > maxReservas) {
        maxReservas = cantidad;
        clienteTopId = clienteId;
      }
    });

    Cliente? clienteTop;
    if (clienteTopId != null) {
      clienteTop = DataStore.clientes.firstWhere(
        (c) => c.id == clienteTopId && !c.eliminado,
        orElse: () => Cliente(
          id: -1,
          nombre: 'No encontrado',
          apellido: '',
          numeroDocumento: '',
        ),
      );
    }

    return {
      'reservasActivas': reservasActivas,
      'vehiculosDisponibles': vehiculosDisponibles,
      'clienteTop': clienteTop,
      'cantidadReservasTop': maxReservas,
    };
  }

  @override
  Widget build(BuildContext context) {
    final estadisticas = _calcularEstadisticas();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta de Reservas Activas
            EstadisticaCard(
              icono: Icons.calendar_today,
              titulo: 'Reservas Activas',
              valor: estadisticas['reservasActivas'].toString(),
              color: Colors.blue,
              subtitulo: 'Reservas pendientes de entrega',
            ),

            const SizedBox(height: 16),

            // Tarjeta de Vehículos Disponibles
            EstadisticaCard(
              icono: Icons.directions_car,
              titulo: 'Vehículos Disponibles',
              valor: estadisticas['vehiculosDisponibles'].toString(),
              color: Colors.green,
              subtitulo: 'Vehículos listos para alquilar',
            ),

            const SizedBox(height: 16),

            // Tarjeta del Cliente Top
            if (estadisticas['clienteTop'] != null &&
                estadisticas['clienteTop']!.id != -1)
              ClienteTopCard(
                cliente: estadisticas['clienteTop'] as Cliente,
                cantidadReservas: estadisticas['cantidadReservasTop'] as int,
              ),

            // Mensaje cuando no hay cliente top
            if (estadisticas['clienteTop'] == null ||
                estadisticas['clienteTop']!.id == -1)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'No hay suficientes datos para mostrar cliente destacado',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
