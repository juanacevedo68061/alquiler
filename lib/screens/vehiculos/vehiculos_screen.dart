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
  final GlobalKey<VehiculosFilterState> filtroKey =
      GlobalKey<VehiculosFilterState>();

  @override
  void initState() {
    super.initState();
    _cargarVehiculosVisibles();
  }

  void _cargarVehiculosVisibles() {
    setState(() {
      vehiculosVisibles = DataStore.vehiculos
          .where((v) => !v.eliminado)
          .toList();
    });
  }

  void actualizarFiltro(List<Vehiculo> filtrados) {
    setState(() {
      vehiculosVisibles = filtrados;
    });
  }

  void _recargarTodo() {
    // Recargar el filter para limpiar filtros y opciones
    filtroKey.currentState?.recargarOpciones();
    // También recargar la lista visible
    _cargarVehiculosVisibles();
  }

  void _agregarVehiculo(Vehiculo v) {
    DataStore.vehiculos.add(v);
    _recargarTodo();
  }

  void _editarVehiculo(Vehiculo v) {
    final index = DataStore.vehiculos.indexWhere(
      (vehiculo) => vehiculo.id == v.id,
    );
    if (index != -1) {
      DataStore.vehiculos[index] = v;
      _recargarTodo();
    }
  }

  void _eliminarVehiculo(Vehiculo vehiculo) {
    final tieneReservasActivas = _tieneReservasActivas(vehiculo);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            tieneReservasActivas
                ? 'Eliminar Vehículo con Reserva Activa'
                : 'Eliminar Vehículo',
          ),
          content: Text(
            tieneReservasActivas
                ? 'El vehículo ${vehiculo.marca} ${vehiculo.modelo} tiene una reserva activa. ¿Está seguro de que desea eliminarlo? La reserva activa será cancelada automáticamente.'
                : '¿Está seguro de que desea eliminar el vehículo ${vehiculo.marca} ${vehiculo.modelo} (${vehiculo.anio})?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _confirmarEliminacion(vehiculo, tieneReservasActivas);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmarEliminacion(Vehiculo vehiculo, bool tieneReservasActivas) {
    final index = DataStore.vehiculos.indexWhere((v) => v.id == vehiculo.id);
    if (index != -1) {
      setState(() {
        DataStore.vehiculos[index].eliminado = true;
        if (tieneReservasActivas) {
          _cancelarReservasActivas(vehiculo.id);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Vehículo ${vehiculo.marca} ${vehiculo.modelo} eliminado',
          ),
        ),
      );
    }
    _recargarTodo();
  }

  bool _tieneReservasActivas(Vehiculo vehiculo) {
    return DataStore.reservas.any(
      (reserva) => reserva.idVehiculo == vehiculo.id && reserva.activo,
    );
  }

  void _cancelarReservasActivas(int idVehiculo) {
    for (final reserva in DataStore.reservas) {
      if (reserva.idVehiculo == idVehiculo && reserva.activo) {
        reserva.activo = false;
      }
    }
  }

  // Detectar filtros activos usando el filter
  bool get _hayFiltrosActivos {
    final state = filtroKey.currentState;
    return state != null && state.hayFiltrosActivos;
  }

  String _mostrarDisponible(bool valor) => valor ? "Sí" : "No";

  Widget _buildMensajeVacio() {
    final mensaje = _hayFiltrosActivos
        ? 'No hay vehículos que coincidan con los filtros'
        : 'No hay vehículos registrados';

    final descripcion = _hayFiltrosActivos
        ? 'No se encontraron vehículos con los criterios de búsqueda seleccionados.'
        : 'No se han encontrado vehículos en el sistema. Puede registrar un nuevo vehículo usando el botón +.';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            mensaje,
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
              descripcion,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
          // ELIMINADO: Botón "Limpiar filtros" - ya está en el filter
        ],
      ),
    );
  }

  Widget _buildItemVehiculo(Vehiculo v) {
    final tieneReservasActivas = _tieneReservasActivas(v);

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text('${v.marca} ${v.modelo} (${v.anio})'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Disponible: ${_mostrarDisponible(v.disponible)}'),
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
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () async {
                final editado = await Navigator.push<Vehiculo>(
                  context,
                  MaterialPageRoute(builder: (_) => VehiculoForm(vehiculo: v)),
                );
                if (editado != null) _editarVehiculo(editado);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _eliminarVehiculo(v),
            ),
          ],
        ),
      ),
    );
  }

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
                ? _buildMensajeVacio()
                : ListView.builder(
                    itemCount: vehiculosVisibles.length,
                    itemBuilder: (context, index) =>
                        _buildItemVehiculo(vehiculosVisibles[index]),
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
          if (nuevo != null) _agregarVehiculo(nuevo);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
