class Reserva {
  int id;
  int idCliente;
  int idVehiculo;
  DateTime fechaInicio;
  DateTime fechaFin;
  bool entregado;

  Reserva({
    required this.id,
    required this.idCliente,
    required this.idVehiculo,
    required this.fechaInicio,
    required this.fechaFin,
    this.entregado = false,
  });

  // Método para mostrar información básica en listas
  @override
  String toString() {
    return 'Reserva $id - Cliente: $idCliente, Vehículo: $idVehiculo';
  }
}
