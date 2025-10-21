import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../data/data_store.dart';

/// Widget que maneja los filtros por nombre o documento.
/// Devuelve los clientes filtrados en tiempo real a través de un callback.
class ClientesFilter extends StatefulWidget {
  final Function(List<Cliente>) onFilterChanged;
  final Key? widgetKey;

  const ClientesFilter({
    super.key,
    required this.onFilterChanged,
    this.widgetKey,
  });

  @override
  State<ClientesFilter> createState() => ClientesFilterState();
}

class ClientesFilterState extends State<ClientesFilter> {
  String? nombreSeleccionado;
  String? documentoSeleccionado;

  List<String> nombres = [];
  List<String> documentos = [];

  @override
  void initState() {
    super.initState();
    _cargarOpciones();
  }

  /// Este método se podrá llamar desde el exterior (por ejemplo, luego de un CRUD)
  void recargarOpciones() {
    _cargarOpciones();
    _aplicarFiltros();
  }

  void _cargarOpciones() {
    final clientes = DataStore.clientes;
    final nombresSet = <String>{};
    final documentosSet = <String>{};

    for (var c in clientes) {
      nombresSet.add(c.nombre);
      documentosSet.add(c.numeroDocumento);
    }

    setState(() {
      nombres = nombresSet.toList()..sort();
      documentos = documentosSet.toList()..sort();

      // Verificar y limpiar filtros si los valores seleccionados ya no existen
      _limpiarFiltrosInvalidos();
    });
  }

  void _limpiarFiltrosInvalidos() {
    bool necesitaActualizar = false;

    // Verificar filtro de nombre
    if (nombreSeleccionado != null && !nombres.contains(nombreSeleccionado)) {
      nombreSeleccionado = null;
      necesitaActualizar = true;
    }

    // Verificar filtro de documento
    if (documentoSeleccionado != null &&
        !documentos.contains(documentoSeleccionado)) {
      documentoSeleccionado = null;
      necesitaActualizar = true;
    }

    // Si se limpiaron filtros, aplicar cambios
    if (necesitaActualizar) {
      _aplicarFiltros();
    }
  }

  void _aplicarFiltros() {
    List<Cliente> filtrados = DataStore.clientes.where((c) {
      final coincideNombre =
          nombreSeleccionado == null || c.nombre == nombreSeleccionado;
      final coincideDocumento =
          documentoSeleccionado == null ||
          c.numeroDocumento == documentoSeleccionado;
      return coincideNombre && coincideDocumento;
    }).toList();

    widget.onFilterChanged(filtrados);
  }

  void _limpiarFiltros() {
    setState(() {
      nombreSeleccionado = null;
      documentoSeleccionado = null;
    });
    widget.onFilterChanged(DataStore.clientes);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: widget.widgetKey,
      title: const Text('Filtros'),
      leading: const Icon(Icons.filter_alt),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos')),
                  ...nombres.map(
                    (n) => DropdownMenuItem(value: n, child: Text(n)),
                  ),
                ],
                onChanged: (valor) {
                  setState(() => nombreSeleccionado = valor);
                  _aplicarFiltros();
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Documento',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos')),
                  ...documentos.map(
                    (d) => DropdownMenuItem(value: d, child: Text(d)),
                  ),
                ],
                onChanged: (valor) {
                  setState(() => documentoSeleccionado = valor);
                  _aplicarFiltros();
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _limpiarFiltros,
                  icon: const Icon(Icons.clear),
                  label: const Text('Limpiar filtros'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
