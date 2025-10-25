class Cliente {
  int id;
  String nombre;
  String apellido;
  String numeroDocumento;
  bool eliminado;

  Cliente({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.numeroDocumento,
    this.eliminado = false,
  });

  // Método para mostrar el nombre completo en listas
  String get nombreCompleto => '$nombre $apellido';

  // Método opcional para mostrarlo fácilmente en listas
  @override
  String toString() {
    return '$nombreCompleto - $numeroDocumento';
  }
}
