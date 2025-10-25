import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../data/data_store.dart';

class ClienteForm extends StatefulWidget {
  final Cliente? cliente;

  const ClienteForm({super.key, this.cliente});

  @override
  State<ClienteForm> createState() => _ClienteFormState();
}

class _ClienteFormState extends State<ClienteForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController documentoController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(
      text: widget.cliente?.nombre ?? '',
    );
    apellidoController = TextEditingController(
      text: widget.cliente?.apellido ?? '',
    );
    documentoController = TextEditingController(
      text: widget.cliente?.numeroDocumento ?? '',
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    documentoController.dispose();
    super.dispose();
  }

  // Método para validar formato y unicidad del documento
  String? _validarDocumento(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese el número de documento';
    }

    final documento = value.trim();

    // Validar longitud (4-15 dígitos - cubre la mayoría de países)
    if (documento.length < 4) {
      return 'El documento debe tener al menos 4 dígitos';
    }
    if (documento.length > 15) {
      return 'El documento no puede tener más de 15 dígitos';
    }

    // Validar que solo contenga números
    if (!RegExp(r'^[0-9]+$').hasMatch(documento)) {
      return 'El documento solo puede contener números';
    }

    // Validar que no sea solo ceros
    if (documento == '0' * documento.length) {
      return 'El documento no puede ser solo ceros';
    }

    // Validar unicidad (solo contra clientes activos)
    final clienteExistente = DataStore.clientes.firstWhere(
      (c) =>
          !c.eliminado &&
          c.numeroDocumento == documento &&
          c.id != widget.cliente?.id,
      orElse: () =>
          Cliente(id: -1, nombre: '', apellido: '', numeroDocumento: ''),
    );

    if (clienteExistente.id != -1) {
      return 'Ya existe un cliente activo con este número de documento';
    }

    return null;
  }

  // Validar que el nombre solo contenga letras (sin espacios)
  String? _validarNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese el nombre';
    }

    // Solo letras, sin espacios
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ]+$').hasMatch(value)) {
      return 'El nombre solo puede contener letras (sin espacios)';
    }

    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }

    return null;
  }

  // Validar que el apellido solo contenga letras (sin espacios)
  String? _validarApellido(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese el apellido';
    }

    // Solo letras, sin espacios
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ]+$').hasMatch(value)) {
      return 'El apellido solo puede contener letras (sin espacios)';
    }

    if (value.length < 2) {
      return 'El apellido debe tener al menos 2 caracteres';
    }

    return null;
  }

  void guardarCliente() {
    if (_formKey.currentState!.validate()) {
      final cliente = Cliente(
        id: widget.cliente?.id ?? DateTime.now().millisecondsSinceEpoch,
        nombre: nombreController.text.trim(),
        apellido: apellidoController.text.trim(),
        numeroDocumento: documentoController.text.trim(),
      );

      Navigator.pop(context, cliente);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.cliente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar Cliente' : 'Nuevo Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Solo letras, sin espacios',
                ),
                validator: _validarNombre,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: apellidoController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  hintText: 'Solo letras, sin espacios',
                ),
                validator: _validarApellido,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: documentoController,
                decoration: const InputDecoration(
                  labelText: 'Número de Documento',
                  hintText: 'Solo números (4-15 dígitos)',
                ),
                keyboardType: TextInputType.number,
                validator: _validarDocumento,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: guardarCliente,
                icon: const Icon(Icons.save),
                label: Text(editando ? 'Guardar Cambios' : 'Agregar Cliente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
