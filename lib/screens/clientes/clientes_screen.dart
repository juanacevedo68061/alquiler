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

  // Clave global para acceder al estado de ClientesFilter
  final GlobalKey<ClientesFilterState> filtroKey =
      GlobalKey<ClientesFilterState>();

  @override
  void initState() {
    super.initState();
    // Inicializar con todos los clientes al cargar
    clientesVisibles = List.from(DataStore.clientes);
  }

  void actualizarFiltro(List<Cliente> filtrados) {
    setState(() {
      clientesVisibles = filtrados;
    });
  }

  void _recargarFiltro() {
    filtroKey.currentState?.recargarOpciones();
    // También recargar la lista visible
    setState(() {
      clientesVisibles = List.from(DataStore.clientes);
    });
  }

  void agregarCliente(Cliente c) {
    setState(() {
      DataStore.clientes.add(c);
      clientesVisibles = List.from(DataStore.clientes);
    });
    _recargarFiltro();
  }

  void editarCliente(Cliente c) {
    // Buscar el índice en la lista original por ID
    final indexOriginal = DataStore.clientes.indexWhere(
      (cliente) => cliente.id == c.id,
    );
    if (indexOriginal != -1) {
      setState(() {
        DataStore.clientes[indexOriginal] = c;
        // Actualizar también en la lista visible
        final indexVisible = clientesVisibles.indexWhere(
          (cliente) => cliente.id == c.id,
        );
        if (indexVisible != -1) {
          clientesVisibles[indexVisible] = c;
        } else {
          // Si no está en la lista visible (por filtros), recargar todo
          clientesVisibles = List.from(DataStore.clientes);
        }
      });
    }
    _recargarFiltro();
  }

  void eliminarCliente(Cliente cliente) {
    // Buscar el índice en la lista original por ID
    final indexOriginal = DataStore.clientes.indexWhere(
      (c) => c.id == cliente.id,
    );
    if (indexOriginal != -1) {
      setState(() {
        DataStore.clientes.removeAt(indexOriginal);
        // Remover también de la lista visible
        clientesVisibles.removeWhere((c) => c.id == cliente.id);
      });
    }
    _recargarFiltro();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de Clientes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          ClientesFilter(key: filtroKey, onFilterChanged: actualizarFiltro),
          Expanded(
            child: clientesVisibles.isEmpty
                ? const Center(child: Text('No hay clientes que coincidan'))
                : ListView.builder(
                    itemCount: clientesVisibles.length,
                    itemBuilder: (context, index) {
                      final c = clientesVisibles[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(c.nombreCompleto),
                          subtitle: Text('Documento: ${c.numeroDocumento}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  final editado = await Navigator.push<Cliente>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ClienteForm(cliente: c),
                                    ),
                                  );
                                  if (editado != null) editarCliente(editado);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => eliminarCliente(c),
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
          final nuevo = await Navigator.push<Cliente>(
            context,
            MaterialPageRoute(builder: (_) => const ClienteForm()),
          );
          if (nuevo != null) agregarCliente(nuevo);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
