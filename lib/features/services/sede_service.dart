import '../models/venta/sede.dart';

class SedeService {
  static List<Sede> getSedes() {
    return [
      Sede(
        idSede: 1,
        nombre: "San pablo",
        telefono: "3124567890",
        direccion: "Cra. 38 #98c-2",
        estado: true,
      ),
      Sede(
        idSede: 2,
        nombre: "San benito",
        telefono: "3124567890",
        direccion: "Cra 43A #18-60",
        estado: true,
      ),
    ];
  }
}