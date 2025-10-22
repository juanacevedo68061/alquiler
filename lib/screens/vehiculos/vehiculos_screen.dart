import 'package:flutter/material.dart';
import '../../models/vehiculo.dart';
import '../../data/data_store.dart';
import 'vehiculo_form.dart';
import 'vehiculos_filter.dart';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({super.key});

  @override
  State<VehiculosScreen> createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  List<Vehiculo> vehiculosVisibles = [];

  // Clave global para acceder al estado de VehiculosFilter
  final GlobalKey<VehiculosFilterState> filtroKey =
      GlobalKey<VehiculosFilterState>();

  @override
  void initState() {
    super.initState();
    // Inicializar con todos los vehículos al cargar
    vehiculosVisibles = List.from(DataStore.vehiculos);
  }

  void actualizarFiltro(List<Vehiculo> filtrados) {
    setState(() {
      vehiculosVisibles = filtrados;
    });
  }

  void _recargarFiltro() {
    filtroKey.currentState?.recargarOpciones();
    // También recargar la lista visible
    setState(() {
      vehiculosVisibles = List.from(DataStore.vehiculos);
    });
  }

  void agregarVehiculo(Vehiculo v) {
    setState(() {
      DataStore.vehiculos.add(v);
      vehiculosVisibles = List.from(DataStore.vehiculos);
    });
    _recargarFiltro();
  }

  void editarVehiculo(Vehiculo v) {
    // Buscar el índice en la lista original por ID
    final indexOriginal = DataStore.vehiculos.indexWhere(
      (vehiculo) => vehiculo.id == v.id,
    );
    if (indexOriginal != -1) {
      setState(() {
        DataStore.vehiculos[indexOriginal] = v;
        // Actualizar también en la lista visible
        final indexVisible = vehiculosVisibles.indexWhere(
          (vehiculo) => vehiculo.id == v.id,
        );
        if (indexVisible != -1) {
          vehiculosVisibles[indexVisible] = v;
        } else {
          // Si no está en la lista visible (por filtros), recargar todo
          vehiculosVisibles = List.from(DataStore.vehiculos);
        }
      });
    }
    _recargarFiltro();
  }

  void eliminarVehiculo(Vehiculo vehiculo) {
    // Buscar el índice en la lista original por ID
    final indexOriginal = DataStore.vehiculos.indexWhere(
      (v) => v.id == vehiculo.id,
    );
    if (indexOriginal != -1) {
      setState(() {
        DataStore.vehiculos.removeAt(indexOriginal);
        // Remover también de la lista visible
        vehiculosVisibles.removeWhere((v) => v.id == vehiculo.id);
      });
    }
    _recargarFiltro();
  }

  // NUEVO MÉTODO: Verificar si el vehículo tiene reservas activas
  bool _tieneReservasActivas(Vehiculo vehiculo) {
    return DataStore.reservas.any(
      (reserva) => reserva.idVehiculo == vehiculo.id && !reserva.entregado,
    );
  }

  String mostrarDisponible(bool valor) => valor ? "Sí" : "No";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de Vehículos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          VehiculosFilter(key: filtroKey, onFilterChanged: actualizarFiltro),
          Expanded(
            child: vehiculosVisibles.isEmpty
                ? const Center(child: Text('No hay vehículos que coincidan'))
                : ListView.builder(
                    itemCount: vehiculosVisibles.length,
                    itemBuilder: (context, index) {
                      final v = vehiculosVisibles[index];
                      final tieneReservasActivas = _tieneReservasActivas(v);

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text('${v.marca} ${v.modelo} (${v.anio})'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Disponible: ${mostrarDisponible(v.disponible)}',
                              ),
                              if (tieneReservasActivas)
                                Text(
                                  'Tiene reserva activa',
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: tieneReservasActivas
                                      ? Colors.grey
                                      : Colors.blue,
                                ),
                                onPressed: tieneReservasActivas
                                    ? null // Deshabilitar si tiene reservas activas
                                    : () async {
                                        final editado =
                                            await Navigator.push<Vehiculo>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    VehiculoForm(vehiculo: v),
                                              ),
                                            );
                                        if (editado != null) {
                                          editarVehiculo(editado);
                                        }
                                      },
                                tooltip: tieneReservasActivas
                                    ? 'No se puede editar: tiene reservas activas'
                                    : 'Editar vehículo',
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: tieneReservasActivas
                                      ? Colors.grey
                                      : Colors.red,
                                ),
                                onPressed: tieneReservasActivas
                                    ? null // Deshabilitar si tiene reservas activas
                                    : () => eliminarVehiculo(v),
                                tooltip: tieneReservasActivas
                                    ? 'No se puede eliminar: tiene reservas activas'
                                    : 'Eliminar vehículo',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nuevo = await Navigator.push<Vehiculo>(
            context,
            MaterialPageRoute(builder: (_) => const VehiculoForm()),
          );
          if (nuevo != null) agregarVehiculo(nuevo);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
