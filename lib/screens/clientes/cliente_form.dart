import 'package:flutter/material.dart';
import '../../models/cliente.dart';

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
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Ingrese el apellido'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: documentoController,
                decoration: const InputDecoration(
                  labelText: 'Número de Documento',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese el número de documento';
                  }
                  return null;
                },
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
