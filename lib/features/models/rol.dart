import 'package:json_annotation/json_annotation.dart';

part 'rol.g.dart';

@JsonSerializable()
class Rol {
  @JsonKey(name: 'idRol')
  final int idRol;
  
  @JsonKey(name: 'rol1')
  final String rol1;
  
  @JsonKey(name: 'descripcion')
  final String descripcion;
  
  @JsonKey(name: 'estado')
  final bool estado;

  Rol({
    required this.idRol,
    required this.rol1,
    required this.descripcion,
    required this.estado,
  });

  factory Rol.fromJson(Map<String, dynamic> json) => _$RolFromJson(json);
  Map<String, dynamic> toJson() => _$RolToJson(this);

  Rol copyWith({
    int? idRol,
    String? rol1,
    String? descripcion,
    bool? estado,
  }) {
    return Rol(
      idRol: idRol ?? this.idRol,
      rol1: rol1 ?? this.rol1,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
    );
  }
}