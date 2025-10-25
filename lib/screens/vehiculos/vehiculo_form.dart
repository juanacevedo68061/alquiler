import 'package:flutter/material.dart';
import '../../models/vehiculo.dart';
import '../../data/data_store.dart';

class VehiculoForm extends StatefulWidget {
  final Vehiculo? vehiculo;

  const VehiculoForm({super.key, this.vehiculo});

  @override
  State<VehiculoForm> createState() => _VehiculoFormState();
}

class _VehiculoFormState extends State<VehiculoForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController marcaController;
  late TextEditingController modeloController;
  late TextEditingController anioController;
  bool disponible = true;

  @override
  void initState() {
    super.initState();
    marcaController = TextEditingController(text: widget.vehiculo?.marca ?? '');
    modeloController = TextEditingController(
      text: widget.vehiculo?.modelo ?? '',
    );
    anioController = TextEditingController(
      text: widget.vehiculo?.anio != null
          ? widget.vehiculo!.anio.toString()
          : '',
    );
    disponible = widget.vehiculo?.disponible ?? true;
  }

  @override
  void dispose() {
    marcaController.dispose();
    modeloController.dispose();
    anioController.dispose();
    super.dispose();
  }

  // Validar marca (solo letras, sin espacios, máximo 10 caracteres)
  String? _validarMarca(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese la marca del vehículo';
    }

    final marca = value.trim();

    if (marca.isEmpty) {
      return 'Ingrese la marca del vehículo';
    }

    if (marca.length < 2) {
      return 'La marca debe tener al menos 2 caracteres';
    }

    if (marca.length > 10) {
      return 'La marca no puede tener más de 10 caracteres';
    }

    // Solo letras, sin espacios ni caracteres especiales
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ]+$').hasMatch(marca)) {
      return 'La marca solo puede contener letras (sin espacios ni números)';
    }

    return null;
  }

  // Validar modelo (letras y números, sin espacios, empieza con letra, máximo 10 caracteres)
  String? _validarModelo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese el modelo del vehículo';
    }

    final modelo = value.trim();

    if (modelo.isEmpty) {
      return 'Ingrese el modelo del vehículo';
    }

    // Esta validación ya no es necesaria porque isEmpty cubre el caso de 0 caracteres
    // if (modelo.length < 1) se elimina

    if (modelo.length > 10) {
      return 'El modelo no puede tener más de 10 caracteres';
    }

    // Debe empezar con letra
    if (!RegExp(r'^[a-zA-Z]').hasMatch(modelo)) {
      return 'El modelo debe empezar con una letra';
    }

    // Letras y números, sin espacios ni caracteres especiales
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(modelo)) {
      return 'El modelo solo puede contener letras y números (sin espacios)';
    }

    return null;
  }

  // Validar año (rango realista: 1900 hasta año actual+1)
  String? _validarAnio(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese el año del vehículo';
    }

    final anio = value.trim();
    final actual = DateTime.now().year;
    const anioMinimo = 1900;

    // Validar que sea número
    final parsed = int.tryParse(anio);
    if (parsed == null) {
      return 'El año debe ser un número válido';
    }

    // Validar rango realista
    if (parsed < anioMinimo) {
      return 'El año no puede ser menor a $anioMinimo';
    }

    if (parsed > actual + 1) {
      return 'El año no puede ser mayor a ${actual + 1}';
    }

    return null;
  }

  // Validar unicidad (misma marca, modelo y año) - excluyendo el actual si está editando
  String? _validarUnicidad() {
    final marca = marcaController.text.trim();
    final modelo = modeloController.text.trim();
    final anio = anioController.text.trim();

    // Solo validar si todos los campos tienen datos válidos
    if (marca.isEmpty || modelo.isEmpty || anio.isEmpty) {
      return null;
    }

    final anioParsed = int.tryParse(anio);
    if (anioParsed == null) {
      return null; // Ya se validará en _validarAnio
    }

    // Buscar vehículo duplicado (solo entre vehículos activos)
    final vehiculoExistente = DataStore.vehiculos.firstWhere(
      (v) =>
          !v.eliminado &&
          _normalizarTexto(v.marca) == _normalizarTexto(marca) &&
          _normalizarTexto(v.modelo) == _normalizarTexto(modelo) &&
          v.anio == anioParsed &&
          v.id != widget.vehiculo?.id, // Excluir el actual si está editando
      orElse: () => Vehiculo(id: -1, marca: '', modelo: '', anio: 0),
    );

    if (vehiculoExistente.id != -1) {
      return 'Ya existe un vehículo activo con esta marca, modelo y año';
    }

    return null;
  }

  String _normalizarTexto(String texto) {
    return texto.trim().toLowerCase();
  }

  void guardarVehiculo() {
    // Validar unicidad antes de guardar
    final errorUnicidad = _validarUnicidad();
    if (errorUnicidad != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorUnicidad), backgroundColor: Colors.red),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final vehiculo = Vehiculo(
        id: widget.vehiculo?.id ?? DateTime.now().millisecondsSinceEpoch,
        marca: marcaController.text.trim(),
        modelo: modeloController.text.trim(),
        anio: int.parse(anioController.text),
        disponible: disponible,
      );

      Navigator.pop(context, vehiculo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.vehiculo != null;
    final anioActual = DateTime.now().year;
    final anioMaximo = anioActual + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar Vehículo' : 'Nuevo Vehículo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: marcaController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  hintText: 'Solo letras, 2-10 caracteres, sin espacios',
                ),
                validator: _validarMarca,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: modeloController,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  hintText:
                      'Letras y números, empieza con letra, 1-10 caracteres',
                ),
                validator: _validarModelo,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: anioController,
                decoration: InputDecoration(
                  labelText: 'Año',
                  hintText: '1900-$anioMaximo',
                ),
                keyboardType: TextInputType.number,
                validator: _validarAnio,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Disponible'),
                subtitle: Text(disponible ? 'Sí' : 'No'),
                value: disponible,
                onChanged: (value) {
                  setState(() {
                    disponible = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: guardarVehiculo,
                icon: const Icon(Icons.save),
                label: Text(editando ? 'Guardar Cambios' : 'Agregar Vehículo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
