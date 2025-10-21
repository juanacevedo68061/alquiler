import 'package:flutter/material.dart';
import '../../models/vehiculo.dart';

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

  void guardarVehiculo() {
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
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese la marca' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: modeloController,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese el modelo' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: anioController,
                decoration: const InputDecoration(labelText: 'Año'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese el año';
                  final num? parsed = int.tryParse(value);
                  if (parsed == null) return 'Debe ser un número';
                  return null;
                },
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
