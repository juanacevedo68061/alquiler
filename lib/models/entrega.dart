class Entrega {
  int id;
  int idReserva;
  DateTime fechaEntregaReal;
  String? observaciones;

  Entrega({
    required this.id,
    required this.idReserva,
    required this.fechaEntregaReal,
    this.observaciones,
  });

  // Método para mostrar información básica en listas
  @override
  String toString() {
    return 'Entrega $id - Reserva: $idReserva, Fecha: $fechaEntregaReal';
  }
}
