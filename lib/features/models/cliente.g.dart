// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cliente _$ClienteFromJson(Map<String, dynamic> json) => Cliente(
  idCliente: (json['idCliente'] as num?)?.toInt() ?? 0,
  tipoDocumento: json['tipoDocumento'] as String,
  numeroDocumento: json['numeroDocumento'] as String,
  nombre: json['nombre'] as String,
  apellido: json['apellido'] as String,
  correo: json['correo'] as String,
  contrasena: json['contrasena'] as String?,
  direccion: json['direccion'] as String,
  barrio: json['barrio'] as String,
  ciudad: json['ciudad'] as String,
  fechaNacimiento: Cliente._fromJsonFecha(json['fechaNacimiento'] as String),
  celular: json['celular'] as String,
  estado: json['estado'] as bool,
);

Map<String, dynamic> _$ClienteToJson(Cliente instance) => <String, dynamic>{
  'idCliente': instance.idCliente,
  'tipoDocumento': instance.tipoDocumento,
  'numeroDocumento': instance.numeroDocumento,
  'nombre': instance.nombre,
  'apellido': instance.apellido,
  'correo': instance.correo,
  'contrasena': instance.contrasena,
  'direccion': instance.direccion,
  'barrio': instance.barrio,
  'ciudad': instance.ciudad,
  'fechaNacimiento': Cliente._toJsonFecha(instance.fechaNacimiento),
  'celular': instance.celular,
  'estado': instance.estado,
};
