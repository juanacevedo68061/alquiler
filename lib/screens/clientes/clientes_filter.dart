import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../data/data_store.dart';

class ClientesFilter extends StatefulWidget {
  final Function(List<Cliente>) onFilterChanged;
  final Key? widgetKey;

  const ClientesFilter({
    super.key,
    required this.onFilterChanged,
    this.widgetKey,
  });

  @override
  ClientesFilterState createState() => ClientesFilterState();
}

class ClientesFilterState extends State<ClientesFilter> {
  String? nombreSeleccionado;
  String? documentoSeleccionado;

  List<String> nombres = [];
  List<String> documentos = [];

  bool get hayFiltrosActivos =>
      nombreSeleccionado != null || documentoSeleccionado != null;

  @override
  void initState() {
    super.initState();
    _cargarOpciones();
  }

  /// Recarga opciones y limpia filtros después de operaciones CRUD
  void recargarOpciones() {
    _cargarOpciones();
    limpiarFiltros();
  }

  String _normalizarTexto(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  void _cargarOpciones() {
    final clientes = DataStore.clientes.where((c) => !c.eliminado).toList();
    final nombresSet = <String>{};
    final documentosSet = <String>{};

    for (var c in clientes) {
      nombresSet.add(_normalizarTexto(c.nombre));
      documentosSet.add(c.numeroDocumento);
    }

    setState(() {
      nombres = nombresSet.toList()..sort();
      documentos = documentosSet.toList()..sort();
    });
  }

  void _aplicarFiltros() {
    final filtrados = DataStore.clientes.where((c) {
      if (c.eliminado) return false;

      final coincideNombre =
          nombreSeleccionado == null ||
          _normalizarTexto(c.nombre).toLowerCase() ==
              nombreSeleccionado!.toLowerCase();

      final coincideDocumento =
          documentoSeleccionado == null ||
          c.numeroDocumento == documentoSeleccionado;

      return coincideNombre && coincideDocumento;
    }).toList();

    widget.onFilterChanged(filtrados);
  }

  void limpiarFiltros() {
    setState(() {
      nombreSeleccionado = null;
      documentoSeleccionado = null;
    });
    _aplicarFiltros();
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
              _buildDropdownNombre(),
              const SizedBox(height: 10),
              _buildDropdownDocumento(),
              const SizedBox(height: 10),
              _buildBotonLimpiar(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownNombre() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Nombre',
        border: OutlineInputBorder(),
      ),
      initialValue: nombreSeleccionado, // CAMBIADO: value → initialValue
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos')),
        ...nombres.map((n) => DropdownMenuItem(value: n, child: Text(n))),
      ],
      onChanged: (valor) {
        setState(() => nombreSeleccionado = valor);
        _aplicarFiltros();
      },
    );
  }

  Widget _buildDropdownDocumento() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Documento',
        border: OutlineInputBorder(),
      ),
      initialValue: documentoSeleccionado, // CAMBIADO: value → initialValue
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos')),
        ...documentos.map((d) => DropdownMenuItem(value: d, child: Text(d))),
      ],
      onChanged: (valor) {
        setState(() => documentoSeleccionado = valor);
        _aplicarFiltros();
      },
    );
  }

  Widget _buildBotonLimpiar() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: limpiarFiltros,
        icon: const Icon(Icons.clear),
        label: const Text('Limpiar filtros'),
      ),
    );
  }
}
