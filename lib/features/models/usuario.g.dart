// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Usuario _$UsuarioFromJson(Map<String, dynamic> json) => Usuario(
  idUsuario: (json['idUsuario'] as num).toInt(),
  tipoDocumento: json['tipoDocumento'] as String,
  documento: (json['documento'] as num).toInt(),
  nombre: json['nombre'] as String,
  apellido: json['apellido'] as String,
  correo: json['correo'] as String,
  hashContrasena: json['hashContraseña'] as String?,
  idRol: (json['idRol'] as num).toInt(),
  estado: json['estado'] as bool,
  idRolNavigation:
      json['idRolNavigation'] == null
          ? null
          : Rol.fromJson(json['idRolNavigation'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UsuarioToJson(Usuario instance) => <String, dynamic>{
  'idUsuario': instance.idUsuario,
  'tipoDocumento': instance.tipoDocumento,
  'documento': instance.documento,
  'nombre': instance.nombre,
  'apellido': instance.apellido,
  'correo': instance.correo,
  'hashContraseña': instance.hashContrasena,
  'idRol': instance.idRol,
  'estado': instance.estado,
  'idRolNavigation': instance.idRolNavigation,
};
