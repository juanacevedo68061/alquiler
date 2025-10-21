import 'package:flutter/material.dart';
import '../../models/entrega.dart';
import '../../models/reserva.dart';
import '../../models/cliente.dart';
import '../../models/vehiculo.dart';
import '../../data/data_store.dart';

class EntregaForm extends StatefulWidget {
  const EntregaForm({super.key});

  @override
  State<EntregaForm> createState() => _EntregaFormState();
}

class _EntregaFormState extends State<EntregaForm> {
  final _formKey = GlobalKey<FormState>();
  final _observacionesController = TextEditingController();

  Reserva? reservaSeleccionada;
  DateTime? fechaEntregaReal;

  List<Reserva> get reservasActivas {
    return DataStore.reservas
        .where(
          (r) =>
              !r.entregado &&
              r.fechaInicio.isBefore(
                DateTime.now().add(const Duration(days: 1)),
              ),
        )
        .toList();
  }

  void _guardarEntrega() {
    if (_formKey.currentState!.validate()) {
      if (reservaSeleccionada == null) {
        ScaffoldMessenger.of(
          _formKey.currentContext!,
        ).showSnackBar(const SnackBar(content: Text('Seleccione una reserva')));
        return;
      }

      if (fechaEntregaReal == null) {
        ScaffoldMessenger.of(_formKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('Seleccione la fecha de entrega')),
        );
        return;
      }

      final entrega = Entrega(
        id: DateTime.now().millisecondsSinceEpoch,
        idReserva: reservaSeleccionada!.id,
        fechaEntregaReal: fechaEntregaReal!,
        observaciones: _observacionesController.text.isNotEmpty
            ? _observacionesController.text
            : null,
      );

      final indexReserva = DataStore.reservas.indexWhere(
        (r) => r.id == reservaSeleccionada!.id,
      );
      if (indexReserva != -1) {
        DataStore.reservas[indexReserva].entregado = true;
      }

      final indexVehiculo = DataStore.vehiculos.indexWhere(
        (v) => v.id == reservaSeleccionada!.idVehiculo,
      );
      if (indexVehiculo != -1) {
        DataStore.vehiculos[indexVehiculo].disponible = true;
      }

      Navigator.pop(context, entrega);
    }
  }

  Future<void> _seleccionarFechaEntrega() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (fecha != null) {
      setState(() {
        fechaEntregaReal = fecha;
      });
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hayReservasDisponibles = reservasActivas.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Entrega')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: hayReservasDisponibles
            ? Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<Reserva>(
                      decoration: const InputDecoration(
                        labelText: 'Reserva a Entregar',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem<Reserva>(
                          value: null,
                          child: Text('Seleccione una reserva'),
                        ),
                        ...reservasActivas.map((Reserva r) {
                          final cliente = DataStore.clientes.firstWhere(
                            (c) => c.id == r.idCliente,
                            orElse: () => Cliente(
                              id: -1,
                              nombre: 'No encontrado',
                              apellido: '',
                              numeroDocumento: '',
                            ),
                          );
                          final vehiculo = DataStore.vehiculos.firstWhere(
                            (v) => v.id == r.idVehiculo,
                            orElse: () => Vehiculo(
                              id: -1,
                              marca: 'No encontrado',
                              modelo: '',
                              anio: 0,
                              disponible: true,
                            ),
                          );

                          return DropdownMenuItem<Reserva>(
                            value: r,
                            child: Text(
                              'Reserva ${r.id} - ${cliente.nombre.split(' ').first} - ${vehiculo.marca} ${vehiculo.modelo}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (Reserva? reserva) {
                        setState(() {
                          reservaSeleccionada = reserva;
                          fechaEntregaReal = null;
                        });
                      },
                      validator: (Reserva? value) =>
                          value == null ? 'Seleccione una reserva' : null,
                    ),
                    const SizedBox(height: 20),

                    // Selector de Fecha de Entrega Real
                    ListTile(
                      title: const Text('Fecha de Entrega Real'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fechaEntregaReal != null
                                ? _formatearFecha(fechaEntregaReal!)
                                : 'Seleccione fecha',
                          ),
                          if (reservaSeleccionada != null)
                            Text(
                              'Período de reserva: ${_formatearFecha(reservaSeleccionada!.fechaInicio)} - ${_formatearFecha(reservaSeleccionada!.fechaFin)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _seleccionarFechaEntrega,
                    ),
                    const SizedBox(height: 20),

                    // Campo de observaciones
                    TextFormField(
                      controller: _observacionesController,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones (opcional)',
                        border: OutlineInputBorder(),
                        hintText:
                            'Kilometraje final, estado del vehículo, etc.',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),

                    // Botón Guardar
                    ElevatedButton.icon(
                      onPressed: _guardarEntrega,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Registrar Entrega'),
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.car_rental, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 20),
                    Text(
                      'No hay reservas disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'No existen reservas pendientes de entrega que hayan iniciado su período de alquiler.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
