import 'package:flutter/material.dart';
import '../../models/entrega.dart';
import '../../models/reserva.dart';
import '../../data/data_store.dart';
import 'entrega_form.dart';

class EntregasScreen extends StatefulWidget {
  const EntregasScreen({super.key});

  @override
  State<EntregasScreen> createState() => _EntregasScreenState();
}

class _EntregasScreenState extends State<EntregasScreen> {
  List<Entrega> entregasVisibles = [];

  @override
  void initState() {
    super.initState();
    entregasVisibles = List.from(DataStore.entregas);
  }

  void agregarEntrega(Entrega e) {
    setState(() {
      DataStore.entregas.add(e);
      entregasVisibles = List.from(DataStore.entregas);
    });
  }

  // Método para obtener información de la reserva
  String _obtenerInfoReserva(int idReserva) {
    final reserva = DataStore.reservas.firstWhere(
      (r) => r.id == idReserva,
      orElse: () => Reserva(
        id: -1,
        idCliente: -1,
        idVehiculo: -1,
        fechaInicio: DateTime.now(),
        fechaFin: DateTime.now(),
        entregado: false,
      ),
    );

    // Obtener información del cliente
    final cliente = DataStore.clientes.firstWhere(
      (c) => c.id == reserva.idCliente,
      orElse: () => DataStore.clientes.first,
    );

    // Obtener información del vehículo
    final vehiculo = DataStore.vehiculos.firstWhere(
      (v) => v.id == reserva.idVehiculo,
      orElse: () => DataStore.vehiculos.first,
    );

    return 'Reserva #${reserva.id} - ${cliente.nombreCompleto} - ${vehiculo.marca} ${vehiculo.modelo}';
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Entregas')),
      body: entregasVisibles.isEmpty
          ? const Center(child: Text('No hay entregas registradas'))
          : ListView.builder(
              itemCount: entregasVisibles.length,
              itemBuilder: (context, index) {
                final e = entregasVisibles[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Entrega #${e.id}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_obtenerInfoReserva(e.idReserva)),
                        Text(
                          'Fecha de entrega: ${_formatearFecha(e.fechaEntregaReal)}',
                        ),
                        if (e.observaciones != null &&
                            e.observaciones!.isNotEmpty)
                          Text('Observaciones: ${e.observaciones}'),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nueva = await Navigator.push<Entrega>(
            context,
            MaterialPageRoute(builder: (_) => const EntregaForm()),
          );
          if (nueva != null) agregarEntrega(nueva);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
