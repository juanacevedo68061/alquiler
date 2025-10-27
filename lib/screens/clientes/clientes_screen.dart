import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../data/data_store.dart';
import 'cliente_form.dart';
import 'clientes_filter.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Cliente> clientesVisibles = [];
  final GlobalKey<ClientesFilterState> filtroKey =
      GlobalKey<ClientesFilterState>();

  @override
  void initState() {
    super.initState();
    _cargarClientesVisibles();
  }

  void _cargarClientesVisibles() {
    setState(() {
      clientesVisibles = DataStore.clientes.where((c) => !c.eliminado).toList();
    });
  }

  void actualizarFiltro(List<Cliente> filtrados) {
    setState(() {
      clientesVisibles = filtrados;
    });
  }

  void _recargarTodo() {
    // Recargar el filter para limpiar filtros y opciones
    filtroKey.currentState?.recargarOpciones();
    // También recargar la lista visible
    _cargarClientesVisibles();
  }

  void _agregarCliente(Cliente c) {
    DataStore.clientes.add(c);
    _recargarTodo();
  }

  void _editarCliente(Cliente c) {
    final index = DataStore.clientes.indexWhere(
      (cliente) => cliente.id == c.id,
    );
    if (index != -1) {
      DataStore.clientes[index] = c;
      _recargarTodo();
    }
  }

  void _eliminarCliente(Cliente cliente) {
    final tieneReservasActivas = _tieneReservasActivas(cliente);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            tieneReservasActivas
                ? 'Eliminar Cliente con Reserva Activa'
                : 'Eliminar Cliente',
          ),
          content: Text(
            tieneReservasActivas
                ? 'El cliente ${cliente.nombreCompleto} tiene reservas activas. ¿Esta seguro de que desea eliminarlo? La reservas activas seran canceladas automaticamente.'
                : '¿Esta seguro de que desea eliminar a ${cliente.nombreCompleto}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _confirmarEliminacion(cliente, tieneReservasActivas);
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

  void _confirmarEliminacion(Cliente cliente, bool tieneReservasActivas) {
    final index = DataStore.clientes.indexWhere((c) => c.id == cliente.id);
    if (index != -1) {
      setState(() {
        DataStore.clientes[index].eliminado = true;
        if (tieneReservasActivas) {
          _cancelarReservasActivas(cliente.id);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente ${cliente.nombreCompleto} eliminado')),
      );
    }
    _recargarTodo();
  }

  bool _tieneReservasActivas(Cliente cliente) {
    return DataStore.reservas.any(
      (reserva) => reserva.idCliente == cliente.id && reserva.activo,
    );
  }

  void _cancelarReservasActivas(int idCliente) {
    for (final reserva in DataStore.reservas) {
      if (reserva.idCliente == idCliente && reserva.activo) {
        // Cancelar la reserva
        reserva.activo = false;

        // Volver a poner el vehículo como disponible
        final vehiculoIndex = DataStore.vehiculos.indexWhere(
          (v) => v.id == reserva.idVehiculo,
        );
        if (vehiculoIndex != -1) {
          DataStore.vehiculos[vehiculoIndex].disponible = true;
        }
      }
    }
  }

  // Detectar filtros activos usando el filter
  bool get _hayFiltrosActivos {
    final state = filtroKey.currentState;
    return state != null && state.hayFiltrosActivos;
  }

  Widget _buildMensajeVacio() {
    final mensaje = _hayFiltrosActivos
        ? 'No hay clientes que coincidan con los filtros'
        : 'No hay clientes registrados';

    final descripcion = _hayFiltrosActivos
        ? 'No se encontraron clientes con los criterios de busqueda seleccionados.'
        : 'No se han encontrado clientes en el sistema. Puede registrar un nuevo cliente usando el boton +.';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            mensaje,
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

  Widget _buildItemCliente(Cliente c) {
    final tieneReservasActivas = _tieneReservasActivas(c);

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(c.nombreCompleto),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Documento: ${c.numeroDocumento}'),
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
                final editado = await Navigator.push<Cliente>(
                  context,
                  MaterialPageRoute(builder: (_) => ClienteForm(cliente: c)),
                );
                if (editado != null) _editarCliente(editado);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _eliminarCliente(c),
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
        title: const Text('Administracion de Clientes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          ClientesFilter(key: filtroKey, onFilterChanged: actualizarFiltro),
          Expanded(
            child: clientesVisibles.isEmpty
                ? _buildMensajeVacio()
                : ListView.builder(
                    itemCount: clientesVisibles.length,
                    itemBuilder: (context, index) =>
                        _buildItemCliente(clientesVisibles[index]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nuevo = await Navigator.push<Cliente>(
            context,
            MaterialPageRoute(builder: (_) => const ClienteForm()),
          );
          if (nuevo != null) _agregarCliente(nuevo);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
