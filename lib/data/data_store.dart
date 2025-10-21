import '../models/vehiculo.dart';
import '../models/cliente.dart';
import '../models/reserva.dart';
import '../models/entrega.dart';

class DataStore {
  // Lista local de vehículos (persistencia en memoria)
  static List<Vehiculo> vehiculos = [
    Vehiculo(
      id: 1,
      marca: 'Toyota',
      modelo: 'Corolla',
      anio: 2019,
      disponible: true, // ← Cambiado a true porque fue entregado
    ),
    Vehiculo(
      id: 2,
      marca: 'Ford',
      modelo: 'Focus',
      anio: 2017,
      disponible: true,
    ),
    Vehiculo(
      id: 3,
      marca: 'Chevrolet',
      modelo: 'Onix',
      anio: 2021,
      disponible: true,
    ),
    Vehiculo(
      id: 4,
      marca: 'Honda',
      modelo: 'Civic',
      anio: 2020,
      disponible: false, // ← Sigue false porque reserva #2 sigue activa
    ),
  ];

  // Lista local de clientes (persistencia en memoria)
  static List<Cliente> clientes = [
    Cliente(
      id: 1,
      nombre: 'María',
      apellido: 'González',
      numeroDocumento: '12345678',
    ),
    Cliente(
      id: 2,
      nombre: 'Carlos',
      apellido: 'López',
      numeroDocumento: '87654321',
    ),
    Cliente(
      id: 3,
      nombre: 'Ana',
      apellido: 'Martínez',
      numeroDocumento: '11223344',
    ),
    Cliente(
      id: 4,
      nombre: 'Juan',
      apellido: 'Rodríguez',
      numeroDocumento: '44332211',
    ),
    Cliente(
      id: 5,
      nombre: 'Laura',
      apellido: 'Pérez',
      numeroDocumento: '55667788',
    ),
  ];

  // Lista local de reservas (persistencia en memoria)
  static List<Reserva> reservas = [
    Reserva(
      id: 1,
      idCliente: 2, // Carlos López
      idVehiculo: 1, // Toyota Corolla
      fechaInicio: DateTime(2025, 10, 27),
      fechaFin: DateTime(2025, 10, 30),
      entregado: true,
    ),
    Reserva(
      id: 2,
      idCliente: 4, // Juan Rodríguez
      idVehiculo: 4, // Honda Civic
      fechaInicio: DateTime(2025, 11, 2),
      fechaFin: DateTime(2025, 11, 6),
      entregado: false,
    ),
  ];

  // Lista local de entregas (persistencia en memoria)
  static List<Entrega> entregas = [
    Entrega(
      id: 1,
      idReserva: 1, // Reserva de Carlos López - Toyota Corolla
      fechaEntregaReal: DateTime(2025, 10, 29), // ← Entre medio (27-30 Oct)
      observaciones:
          'Vehículo en perfecto estado. Kilometraje final: 45,200 km',
    ),
  ];
}
