class Cliente {
  final int idCliente;
  final String? tipoDocumento;
  final String? numeroDocumento;
  final String? nombre; // Keep lowercase 'n'
  final String? apellido;
  final String? correo;
  final String? contrasena;
  final String? direccion;
  final String? barrio;
  final String? ciudad;
  final DateTime? fechaNacimiento;
  final String? celular;
  final bool? estado;

  Cliente({
    required this.idCliente,
    this.tipoDocumento,
    this.numeroDocumento,
    this.nombre, // Keep lowercase 'n'
    this.apellido,
    this.correo,
    this.contrasena,
    this.direccion,
    this.barrio,
    this.ciudad,
    this.fechaNacimiento,
    this.celular,
    this.estado,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    DateTime? parsedFechaNacimiento;
    if (json['FechaNacimiento'] != null) {
      try {
        parsedFechaNacimiento = DateTime.parse(json['FechaNacimiento']);
      } catch (e) {
        parsedFechaNacimiento = null;
      }
    }

    return Cliente(
      idCliente: json['idCliente'],
      tipoDocumento: json['TipoDocumento'],
      numeroDocumento: json['NumeroDocumento'],
      nombre: json['nombre'], // Change to lowercase 'n' here
      apellido: json['Apellido'],
      correo: json['Correo'],
      contrasena: json['Contrasena'],
      direccion: json['Direccion'],
      barrio: json['Barrio'],
      ciudad: json['Ciudad'],
      fechaNacimiento: parsedFechaNacimiento,
      celular: json['Celular'],
      estado: json['Estado'],
    );
  }
}