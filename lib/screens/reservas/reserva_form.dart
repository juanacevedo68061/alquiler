import 'package:flutter/material.dart';
import '../../models/reserva.dart';
import '../../models/cliente.dart';
import '../../models/vehiculo.dart';
import '../../data/data_store.dart';

class ReservaForm extends StatefulWidget {
  const ReservaForm({super.key});

  @override
  State<ReservaForm> createState() => _ReservaFormState();
}

class _ReservaFormState extends State<ReservaForm> {
  final _formKey = GlobalKey<FormState>();

  Cliente? clienteSeleccionado;
  Vehiculo? vehiculoSeleccionado;
  DateTime? fechaInicio;
  DateTime? fechaFin;

  List<Cliente> get clientesVigentes {
    return DataStore.clientes.where((c) => !c.eliminado).toList();
  }

  List<Vehiculo> get vehiculosDisponibles {
    return DataStore.vehiculos
        .where((v) => v.disponible && !v.eliminado)
        .toList();
  }

  bool get hayClientesDisponibles => clientesVigentes.isNotEmpty;
  bool get hayVehiculosDisponibles => vehiculosDisponibles.isNotEmpty;
  bool get puedeCrearReserva =>
      hayClientesDisponibles && hayVehiculosDisponibles;

  void _guardarReserva() {
    if (_formKey.currentState!.validate()) {
      if (clienteSeleccionado == null) {
        ScaffoldMessenger.of(
          _formKey.currentContext!,
        ).showSnackBar(const SnackBar(content: Text('Seleccione un cliente')));
        return;
      }

      if (vehiculoSeleccionado == null) {
        ScaffoldMessenger.of(
          _formKey.currentContext!,
        ).showSnackBar(const SnackBar(content: Text('Seleccione un vehículo')));
        return;
      }

      if (fechaInicio == null || fechaFin == null) {
        ScaffoldMessenger.of(_formKey.currentContext!).showSnackBar(
          const SnackBar(content: Text('Seleccione ambas fechas')),
        );
        return;
      }

      // Crear la reserva
      final reserva = Reserva(
        id: DateTime.now().millisecondsSinceEpoch,
        idCliente: clienteSeleccionado!.id,
        idVehiculo: vehiculoSeleccionado!.id,
        fechaInicio: fechaInicio!,
        fechaFin: fechaFin!,
      );

      // Marcar vehículo como no disponible
      final indexVehiculo = DataStore.vehiculos.indexWhere(
        (v) => v.id == vehiculoSeleccionado!.id,
      );
      if (indexVehiculo != -1) {
        DataStore.vehiculos[indexVehiculo].disponible = false;
      }

      Navigator.pop(context, reserva);
    }
  }

  Future<void> _seleccionarFechaInicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (fecha != null) {
      setState(() {
        fechaInicio = fecha;
        // Si fechaFin es anterior a fechaInicio, resetear fechaFin
        if (fechaFin != null && fechaFin!.isBefore(fecha)) {
          fechaFin = null;
        }
      });
    }
  }

  Future<void> _seleccionarFechaFin() async {
    if (fechaInicio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero seleccione la fecha de inicio')),
      );
      return;
    }

    final fecha = await showDatePicker(
      context: context,
      initialDate: fechaInicio!.add(const Duration(days: 1)),
      firstDate: fechaInicio!.add(const Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (fecha != null) {
      setState(() {
        fechaFin = fecha;
      });
    }
  }

  Widget _buildMensajeNoDisponible() {
    String titulo = '';
    String mensaje = '';
    IconData icono = Icons.warning;

    if (!hayClientesDisponibles && !hayVehiculosDisponibles) {
      titulo = 'No hay clientes ni vehículos disponibles';
      mensaje =
          'Es necesario registrar al menos un cliente y un vehículo disponible para crear una reserva.';
      icono = Icons.people_outline;
    } else if (!hayClientesDisponibles) {
      titulo = 'No hay clientes registrados';
      mensaje =
          'No existen clientes vigentes en el sistema. Debe registrar al menos un cliente para crear una reserva.';
      icono = Icons.person_outline;
    } else {
      titulo = 'No hay vehículos disponibles';
      mensaje =
          'No existen vehículos disponibles en el sistema. Todos los vehículos están actualmente alquilados o eliminados.';
      icono = Icons.directions_car_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              mensaje,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Reserva')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: puedeCrearReserva
            ? Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Selector de Cliente (solo clientes vigentes)
                    DropdownButtonFormField<Cliente>(
                      decoration: const InputDecoration(
                        labelText: 'Cliente',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: clienteSeleccionado,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Seleccione un cliente'),
                        ),
                        ...clientesVigentes.map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.nombreCompleto),
                          ),
                        ),
                      ],
                      onChanged: (cliente) {
                        setState(() {
                          clienteSeleccionado = cliente;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Seleccione un cliente' : null,
                    ),
                    const SizedBox(height: 20),

                    // Selector de Vehículo (solo disponibles y no eliminados)
                    DropdownButtonFormField<Vehiculo>(
                      decoration: const InputDecoration(
                        labelText: 'Vehículo (Solo disponibles)',
                        border: OutlineInputBorder(),
                      ),
                      initialValue: vehiculoSeleccionado,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Seleccione un vehículo'),
                        ),
                        ...vehiculosDisponibles.map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text('${v.marca} ${v.modelo} (${v.anio})'),
                          ),
                        ),
                      ],
                      onChanged: (vehiculo) {
                        setState(() {
                          vehiculoSeleccionado = vehiculo;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Seleccione un vehículo' : null,
                    ),
                    const SizedBox(height: 20),

                    // Selector de Fecha Inicio
                    ListTile(
                      title: const Text('Fecha de Inicio'),
                      subtitle: Text(
                        fechaInicio != null
                            ? '${fechaInicio!.day}/${fechaInicio!.month}/${fechaInicio!.year}'
                            : 'Seleccione fecha',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _seleccionarFechaInicio,
                    ),
                    const SizedBox(height: 10),

                    // Selector de Fecha Fin
                    ListTile(
                      title: const Text('Fecha de Fin'),
                      subtitle: Text(
                        fechaFin != null
                            ? '${fechaFin!.day}/${fechaFin!.month}/${fechaFin!.year}'
                            : 'Seleccione fecha',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _seleccionarFechaFin,
                    ),
                    const SizedBox(height: 20),

                    // Botón Guardar
                    ElevatedButton.icon(
                      onPressed: _guardarReserva,
                      icon: const Icon(Icons.save),
                      label: const Text('Crear Reserva'),
                    ),
                  ],
                ),
              )
            : _buildMensajeNoDisponible(),
      ),
    );
  }
}
