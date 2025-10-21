class Vehiculo {
  int id;
  String marca;
  String modelo;
  int anio;
  bool disponible;

  Vehiculo({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.anio,
    this.disponible = true,
  });

  // Método opcional para mostrarlo fácilmente en listas
  @override
  String toString() {
    return '$marca $modelo ($anio)';
  }
}
