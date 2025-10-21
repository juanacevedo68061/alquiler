import 'package:flutter/material.dart';
import '../../models/vehiculo.dart';
import '../../data/data_store.dart';

/// Widget que maneja los filtros por marca y modelo.
/// Devuelve los vehículos filtrados en tiempo real a través de un callback.
class VehiculosFilter extends StatefulWidget {
  final Function(List<Vehiculo>) onFilterChanged;
  final Key? widgetKey;

  const VehiculosFilter({
    super.key,
    required this.onFilterChanged,
    this.widgetKey,
  });

  @override
  State<VehiculosFilter> createState() => VehiculosFilterState();
}

class VehiculosFilterState extends State<VehiculosFilter> {
  String? marcaSeleccionada;
  String? modeloSeleccionado;

  List<String> marcas = [];
  List<String> modelos = [];

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
    final vehiculos = DataStore.vehiculos;
    final marcasSet = <String>{};
    final modelosSet = <String>{};

    for (var v in vehiculos) {
      marcasSet.add(v.marca);
      modelosSet.add(v.modelo);
    }

    setState(() {
      marcas = marcasSet.toList()..sort();
      modelos = modelosSet.toList()..sort();

      // Verificar y limpiar filtros si los valores seleccionados ya no existen
      _limpiarFiltrosInvalidos();
    });
  }

  void _limpiarFiltrosInvalidos() {
    bool necesitaActualizar = false;

    // Verificar filtro de marca
    if (marcaSeleccionada != null && !marcas.contains(marcaSeleccionada)) {
      marcaSeleccionada = null;
      necesitaActualizar = true;
    }

    // Verificar filtro de modelo
    if (modeloSeleccionado != null && !modelos.contains(modeloSeleccionado)) {
      modeloSeleccionado = null;
      necesitaActualizar = true;
    }

    // Si se limpiaron filtros, aplicar cambios
    if (necesitaActualizar) {
      _aplicarFiltros();
    }
  }

  void _aplicarFiltros() {
    List<Vehiculo> filtrados = DataStore.vehiculos.where((v) {
      final coincideMarca =
          marcaSeleccionada == null || v.marca == marcaSeleccionada;
      final coincideModelo =
          modeloSeleccionado == null || v.modelo == modeloSeleccionado;
      return coincideMarca && coincideModelo;
    }).toList();

    widget.onFilterChanged(filtrados);
  }

  void _limpiarFiltros() {
    setState(() {
      marcaSeleccionada = null;
      modeloSeleccionado = null;
    });
    widget.onFilterChanged(DataStore.vehiculos);
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
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                ),
                initialValue: marcaSeleccionada,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  ...marcas.map(
                    (m) => DropdownMenuItem(value: m, child: Text(m)),
                  ),
                ],
                onChanged: (valor) {
                  setState(() => marcaSeleccionada = valor);
                  _aplicarFiltros();
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                ),
                initialValue: modeloSeleccionado,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos')),
                  ...modelos.map(
                    (m) => DropdownMenuItem(value: m, child: Text(m)),
                  ),
                ],
                onChanged: (valor) {
                  setState(() => modeloSeleccionado = valor);
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
