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
        activo: false,
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
      appBar: AppBar(
        title: const Text('Gestión de Entregas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: entregasVisibles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'No hay entregas registradas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'No se han registrado entregas en el sistema. Puede registrar una nueva entrega usando el botón +.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ),
                ],
              ),
            )
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
