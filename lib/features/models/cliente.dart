import 'package:json_annotation/json_annotation.dart';

part 'cliente.g.dart';

@JsonSerializable()
class Cliente {
  @JsonKey(name: 'idCliente')
  final int idCliente; // Cambiar a int no nullable, usar 0 para nuevos registros
  
  @JsonKey(name: 'tipoDocumento')
  final String tipoDocumento;
  
  @JsonKey(name: 'numeroDocumento')
  final String numeroDocumento;
  
  @JsonKey(name: 'nombre')
  final String nombre;
  
  @JsonKey(name: 'apellido')
  final String apellido;
  
  @JsonKey(name: 'correo')
  final String correo;
  
  @JsonKey(name: 'hashContraseña')
  final String? contrasena;
  
  @JsonKey(name: 'direccion')
  final String direccion;
  
  @JsonKey(name: 'barrio')
  final String barrio;
  
  @JsonKey(name: 'ciudad')
  final String ciudad;
  
  @JsonKey(
    name: 'fechaNacimiento',
    fromJson: _fromJsonFecha,
    toJson: _toJsonFecha,
  )
  final DateTime fechaNacimiento;
  
  @JsonKey(name: 'celular')
  final String celular;
  
  @JsonKey(name: 'estado')
  final bool estado;

  Cliente({
    this.idCliente = 0, // Valor por defecto 0 para nuevos registros
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.nombre,   
    required this.apellido, 
    required this.correo,
    this.contrasena,
    required this.direccion,
    required this.barrio,
    required this.ciudad,
    required this.fechaNacimiento,
    required this.celular,
    required this.estado,
  });

factory Cliente.fromJson(Map<String, dynamic> json) {
  return Cliente(
    idCliente: json['idCliente'] as int? ?? 0,
    tipoDocumento: json['tipoDocumento']?.toString() ?? 'CC', // ✅ Valor por defecto
    numeroDocumento: json['numeroDocumento']?.toString() ?? '', // ✅ Asegurar que no sea null
    nombre: json['nombre']?.toString() ?? '',
    apellido: json['apellido']?.toString() ?? '',
    correo: json['correo']?.toString() ?? '',
    contrasena: json['contrasena']?.toString(),
    direccion: json['direccion']?.toString() ?? '',
    barrio: json['barrio']?.toString() ?? '',
    ciudad: json['ciudad']?.toString() ?? '',
    fechaNacimiento: json['fechaNacimiento'] != null 
        ? _fromJsonFecha(json['fechaNacimiento'].toString())
        : DateTime.now(),
    celular: json['celular']?.toString() ?? '',
    estado: json['estado'] as bool? ?? true,
  );
}
  
  Map<String, dynamic> toJson() {
    final json = _$ClienteToJson(this);
    // Siempre incluir idCliente, la API manejará el autoincremento
    return json;
  }

  Cliente copyWith({
    int? idCliente,
    String? tipoDocumento,
    String? numeroDocumento,
    String? nombre,
    String? apellido,
    String? correo,
    String? contrasena,
    String? direccion,
    String? barrio,
    String? ciudad,
    DateTime? fechaNacimiento,
    String? celular,
    bool? estado,
  }) {
    return Cliente(
      idCliente: idCliente ?? this.idCliente,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      numeroDocumento: numeroDocumento ?? this.numeroDocumento,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      contrasena: contrasena ?? this.contrasena,
      direccion: direccion ?? this.direccion,
      barrio: barrio ?? this.barrio,
      ciudad: ciudad ?? this.ciudad,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      celular: celular ?? this.celular,
      estado: estado ?? this.estado,
    );
  }

 String get fullName => '$nombre $apellido'.trim();

  // Método para crear una instancia para registro (con idCliente = 0)
  static Cliente forRegistration({
    required String tipoDocumento,
    required String numeroDocumento,
    required String nombre,   
    required String apellido, 
    required String correo,
    String? contrasena,
    required String direccion,
    required String barrio,
    required String ciudad,
    required DateTime fechaNacimiento,
    required String celular,
    bool estado = true,
  }) {
    return Cliente(
      idCliente: 0, // Siempre 0 para nuevos registros
      tipoDocumento: tipoDocumento,
      numeroDocumento: numeroDocumento,
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      contrasena: contrasena,
      direccion: direccion,
      barrio: barrio,
      ciudad: ciudad,
      fechaNacimiento: fechaNacimiento,
      celular: celular,
      estado: estado,
    );
  }

  static DateTime _fromJsonFecha(String date) {
  try {
    return DateTime.parse(date);
  } catch (e) {
    print('Error parsing date: $date, using current date');
    return DateTime.now();
  }
}

  // Conversión personalizada para fecha
  static String _toJsonFecha(DateTime date) => date.toIso8601String().split('T')[0];
}