class Cliente {
  int id;
  String nombre;
  String apellido;
  String numeroDocumento;

  Cliente({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.numeroDocumento,
  });

  // Método para mostrar el nombre completo en listas
  String get nombreCompleto => '$nombre $apellido';

  // Método opcional para mostrarlo fácilmente en listas
  @override
  String toString() {
    return '$nombreCompleto - $numeroDocumento';
  }
}
