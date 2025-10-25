import 'package:flutter/material.dart';
import '../../models/vehiculo.dart';
import '../../data/data_store.dart';

class VehiculosFilter extends StatefulWidget {
  final Function(List<Vehiculo>) onFilterChanged;
  final Key? widgetKey;

  const VehiculosFilter({
    super.key,
    required this.onFilterChanged,
    this.widgetKey,
  });

  @override
  VehiculosFilterState createState() => VehiculosFilterState();
}

class VehiculosFilterState extends State<VehiculosFilter> {
  String? marcaSeleccionada;
  String? modeloSeleccionado;

  List<String> marcas = [];
  List<String> modelos = [];

  bool get hayFiltrosActivos =>
      marcaSeleccionada != null || modeloSeleccionado != null;

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
    final vehiculos = DataStore.vehiculos.where((v) => !v.eliminado).toList();
    final marcasSet = <String>{};
    final modelosSet = <String>{};

    for (var v in vehiculos) {
      marcasSet.add(_normalizarTexto(v.marca));
      modelosSet.add(_normalizarTexto(v.modelo));
    }

    setState(() {
      marcas = marcasSet.toList()..sort();
      modelos = modelosSet.toList()..sort();
    });
  }

  void _aplicarFiltros() {
    final filtrados = DataStore.vehiculos.where((v) {
      if (v.eliminado) return false;

      final coincideMarca =
          marcaSeleccionada == null ||
          _normalizarTexto(v.marca).toLowerCase() ==
              marcaSeleccionada!.toLowerCase();

      final coincideModelo =
          modeloSeleccionado == null ||
          _normalizarTexto(v.modelo).toLowerCase() ==
              modeloSeleccionado!.toLowerCase();

      return coincideMarca && coincideModelo;
    }).toList();

    widget.onFilterChanged(filtrados);
  }

  void limpiarFiltros() {
    setState(() {
      marcaSeleccionada = null;
      modeloSeleccionado = null;
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
              _buildDropdownMarca(),
              const SizedBox(height: 10),
              _buildDropdownModelo(),
              const SizedBox(height: 10),
              _buildBotonLimpiar(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownMarca() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Marca',
        border: OutlineInputBorder(),
      ),
      initialValue: marcaSeleccionada, // CAMBIADO: value → initialValue
      items: [
        const DropdownMenuItem(value: null, child: Text('Todas')),
        ...marcas.map((m) => DropdownMenuItem(value: m, child: Text(m))),
      ],
      onChanged: (valor) {
        setState(() => marcaSeleccionada = valor);
        _aplicarFiltros();
      },
    );
  }

  Widget _buildDropdownModelo() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Modelo',
        border: OutlineInputBorder(),
      ),
      initialValue: modeloSeleccionado, // CAMBIADO: value → initialValue
      items: [
        const DropdownMenuItem(value: null, child: Text('Todos')),
        ...modelos.map((m) => DropdownMenuItem(value: m, child: Text(m))),
      ],
      onChanged: (valor) {
        setState(() => modeloSeleccionado = valor);
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
