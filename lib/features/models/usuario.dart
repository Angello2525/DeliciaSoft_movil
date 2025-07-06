import 'package:json_annotation/json_annotation.dart';
import 'rol.dart';

part 'usuario.g.dart';

@JsonSerializable()
class Usuario {
  @JsonKey(name: 'idUsuario')
  final int idUsuario;

  @JsonKey(name: 'tipoDocumento')
  final String tipoDocumento;

  @JsonKey(name: 'documento')
  final int documento;

  @JsonKey(name: 'nombre')
  final String nombre;

  @JsonKey(name: 'apellido')
  final String apellido;

  @JsonKey(name: 'correo')
  final String correo;

  @JsonKey(name: 'hashContraseña')
  final String? hashContrasena;

  @JsonKey(name: 'idRol')
  final int idRol;

  @JsonKey(name: 'estado')
  final bool estado;

  @JsonKey(name: 'idRolNavigation')
  final Rol? idRolNavigation;

  Usuario({
    this.idUsuario = 0,
    this.tipoDocumento = '',
    this.documento = 0,
    this.nombre = '',
    this.apellido = '',
    this.correo = '',
    this.hashContrasena,
    this.idRol = 2,            // ✅ idRol real por defecto (2)
    this.estado = true,
    this.idRolNavigation,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
  return Usuario(
    idUsuario: json['idUsuario'] as int? ?? 0,
    tipoDocumento: json['tipoDocumento']?.toString() ?? '',
    documento: json['documento'] is int
        ? json['documento'] as int
        : int.tryParse(json['documento']?.toString() ?? '') ?? 0,
    nombre: json['nombre']?.toString() ?? '',
    apellido: json['apellido']?.toString() ?? '',
    correo: json['correo']?.toString() ?? '',
    hashContrasena: json['hashContraseña']?.toString(),
    idRol: json['idRol'] is int
        ? json['idRol'] as int
        : int.tryParse(json['idRol']?.toString() ?? '') ?? 2,
    estado: json['estado'] is bool
        ? json['estado'] as bool
        : json['estado']?.toString() == 'true',
    idRolNavigation: json['idRolNavigation'] != null
        ? Rol.fromJson(json['idRolNavigation'] as Map<String, dynamic>)
        : null,
  );
}

  Map<String, dynamic> toJson() => _$UsuarioToJson(this);

  /// Para PUT: envía siempre idUsuario, idRol real (2) y hashContraseña no nulo
  Map<String, dynamic> toJsonWithoutId() {
    return {
      'idUsuario': idUsuario,
      'tipoDocumento': tipoDocumento,
      'documento': documento,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'hashContraseña': hashContrasena ?? "",
      'idRol': idRol != 0 ? idRol : 2,   // asegura idRol válido
      'estado': estado,
    };
  }

  Usuario copyWith({
    int? idUsuario,
    String? tipoDocumento,
    int? documento,
    String? nombre,
    String? apellido,
    String? correo,
    String? hashContrasena,
    int? idRol,
    bool? estado,
    Rol? idRolNavigation,
  }) {
    return Usuario(
      idUsuario: idUsuario ?? this.idUsuario,
      tipoDocumento: tipoDocumento ?? this.tipoDocumento,
      documento: documento ?? this.documento,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      hashContrasena: hashContrasena ?? this.hashContrasena,
      idRol: idRol ?? this.idRol,
      estado: estado ?? this.estado,
      idRolNavigation: idRolNavigation ?? this.idRolNavigation,
    );
  }

  String get fullName => '$nombre $apellido'.trim();
  String get roleName => idRolNavigation?.rol1 ?? '';
  bool get isAdmin => roleName.toLowerCase().contains('admin');
}
