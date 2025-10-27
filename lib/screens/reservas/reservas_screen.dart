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
        eliminado: true,
      ),
    );

    // Si el cliente está eliminado, indicarlo
    if (cliente.eliminado) {
      return '${cliente.nombreCompleto} (Eliminado)';
    }

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
        eliminado: true,
      ),
    );

    // Si el vehículo está eliminado, indicarlo
    if (vehiculo.eliminado) {
      return '${vehiculo.marca} ${vehiculo.modelo} (Eliminado)';
    }

    return '${vehiculo.marca} ${vehiculo.modelo}';
  }

  // Método para obtener el motivo de inactividad
  String _obtenerMotivoInactividad(Reserva reserva) {
    final cliente = DataStore.clientes.firstWhere(
      (c) => c.id == reserva.idCliente,
      orElse: () => Cliente(
        id: -1,
        nombre: '',
        apellido: '',
        numeroDocumento: '',
        eliminado: true,
      ),
    );

    final vehiculo = DataStore.vehiculos.firstWhere(
      (v) => v.id == reserva.idVehiculo,
      orElse: () => Vehiculo(
        id: -1,
        marca: '',
        modelo: '',
        anio: 0,
        disponible: true,
        eliminado: true,
      ),
    );

    if (cliente.eliminado) return 'Cliente eliminado';
    if (vehiculo.eliminado) return 'Vehículo eliminado';
    return 'Entrega registrada';
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  // Método para obtener el estado de la reserva
  String _obtenerEstadoReserva(Reserva reserva) {
    return reserva.activo ? 'Activo' : 'Inactivo';
  }

  // Método para obtener el color del estado
  Color _obtenerColorEstado(Reserva reserva) {
    return reserva.activo ? Colors.green : Colors.orange;
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'No hay reservas registradas',
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
                      'No se han encontrado reservas en el sistema. Puede crear una nueva reserva usando el botón +.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ),
                ],
              ),
            )
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
                        if (!r.activo)
                          Text(
                            'Motivo: ${_obtenerMotivoInactividad(r)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
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
