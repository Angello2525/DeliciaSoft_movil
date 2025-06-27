import 'rol.dart';

class Permiso {
  final int idPermiso;
  final String modulo;
  final String descripcion;
  final bool estado;

  Permiso({
    required this.idPermiso,
    required this.modulo,
    required this.descripcion,
    required this.estado,
  });

  factory Permiso.fromJson(Map<String, dynamic> json) {
    return Permiso(
      idPermiso: json['idPermiso'] ?? 0,
      modulo: json['modulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      estado: json['estado'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPermiso': idPermiso,
      'modulo': modulo,
      'descripcion': descripcion,
      'estado': estado,
    };
  }
}

class RolPermiso {
  final int idRolPermiso;
  final int idRol;
  final int idPermiso;
  final bool estado;
  final Permiso? idPermisoNavigation;
  final Rol? idRolNavigation;

  RolPermiso({
    required this.idRolPermiso,
    required this.idRol,
    required this.idPermiso,
    required this.estado,
    this.idPermisoNavigation,
    this.idRolNavigation,
  });

  factory RolPermiso.fromJson(Map<String, dynamic> json) {
    return RolPermiso(
      idRolPermiso: json['idRolPermiso'] ?? 0,
      idRol: json['idRol'] ?? 0,
      idPermiso: json['idPermiso'] ?? 0,
      estado: json['estado'] ?? true,
      idPermisoNavigation: json['idPermisoNavigation'] != null 
          ? Permiso.fromJson(json['idPermisoNavigation'])
          : null,
      idRolNavigation: json['idRolNavigation'] != null 
          ? Rol.fromJson(json['idRolNavigation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRolPermiso': idRolPermiso,
      'idRol': idRol,
      'idPermiso': idPermiso,
      'estado': estado,
      'idPermisoNavigation': idPermisoNavigation?.toJson(),
      'idRolNavigation': idRolNavigation?.toJson(),
    };
  }
}