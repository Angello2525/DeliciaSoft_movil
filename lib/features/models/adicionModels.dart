class AdicionModel {
  final int idAdiciones;
  final int idInsumos;
  final String nombre;
  final int precioAdicion;
  final bool estado;

  AdicionModel({
    required this.idAdiciones,
    required this.idInsumos,
    required this.nombre,
    required this.precioAdicion,
    required this.estado,
  });

  factory AdicionModel.fromJson(Map<String, dynamic> json) {
    return AdicionModel(
      idAdiciones: json['idAdiciones'],
      idInsumos: json['idInsumos'],
      nombre: json['nombre'],
      precioAdicion: json['precioAdicion'],
      estado: json['estado'],
    );
  }

  /// 💡 Tipo calculado en base al idInsumos
  String get tipo {
    if ([2, 3, 4].contains(idInsumos)) return 'Topping';
    if ([5, 6].contains(idInsumos)) return 'Salsa';
    return 'Adición';
  }
}