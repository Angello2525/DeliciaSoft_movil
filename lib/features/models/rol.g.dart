// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rol.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Rol _$RolFromJson(Map<String, dynamic> json) => Rol(
  idRol: (json['idRol'] as num).toInt(),
  rol1: json['rol1'] as String,
  descripcion: json['descripcion'] as String,
  estado: json['estado'] as bool,
);

Map<String, dynamic> _$RolToJson(Rol instance) => <String, dynamic>{
  'idRol': instance.idRol,
  'rol1': instance.rol1,
  'descripcion': instance.descripcion,
  'estado': instance.estado,
};
