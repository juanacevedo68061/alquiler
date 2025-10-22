import 'package:flutter/material.dart';
import '../../models/reserva.dart';
import '../../models/cliente.dart';
import '../../models/vehiculo.dart';
import '../../data/data_store.dart';
import 'reserva_form.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  State<ReservasScreen> createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  List<Reserva> reservasVisibles = [];

  @override
  void initState() {
    super.initState();
    reservasVisibles = List.from(DataStore.reservas);
  }

  void agregarReserva(Reserva r) {
    setState(() {
      DataStore.reservas.add(r);
      reservasVisibles = List.from(DataStore.reservas);
    });
  }

  // Método para obtener información del cliente
  String _obtenerNombreCliente(int idCliente) {
    final cliente = DataStore.clientes.firstWhere(
      (c) => c.id == idCliente,
      orElse: () => Cliente(
        id: -1,
        nombre: 'No encontrado',
        apellido: '',
        numeroDocumento: '',
      ),
    );
    return cliente.nombreCompleto;
  }

  // Método para obtener información del vehículo
  String _obtenerInfoVehiculo(int idVehiculo) {
    final vehiculo = DataStore.vehiculos.firstWhere(
      (v) => v.id == idVehiculo,
      orElse: () => Vehiculo(
        id: -1,
        marca: 'No encontrado',
        modelo: '',
        anio: 0,
        disponible: true,
      ),
    );
    return '${vehiculo.marca} ${vehiculo.modelo}';
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  // Método para obtener el estado de la reserva
  String _obtenerEstadoReserva(Reserva reserva) {
    return reserva.entregado ? 'Inactivo' : 'Activo';
  }

  // Método para obtener el color del estado
  Color _obtenerColorEstado(Reserva reserva) {
    return reserva.entregado ? Colors.orange : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Reservas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: reservasVisibles.isEmpty
          ? const Center(child: Text('No hay reservas registradas'))
          : ListView.builder(
              itemCount: reservasVisibles.length,
              itemBuilder: (context, index) {
                final r = reservasVisibles[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Row(
                      children: [
                        Text('Reserva #${r.id}'),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _obtenerColorEstado(r),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _obtenerEstadoReserva(r),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cliente: ${_obtenerNombreCliente(r.idCliente)}'),
                        Text('Vehículo: ${_obtenerInfoVehiculo(r.idVehiculo)}'),
                        Text(
                          '${_formatearFecha(r.fechaInicio)} - ${_formatearFecha(r.fechaFin)}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nueva = await Navigator.push<Reserva>(
            context,
            MaterialPageRoute(builder: (_) => const ReservaForm()),
          );
          if (nueva != null) agregarReserva(nueva);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
