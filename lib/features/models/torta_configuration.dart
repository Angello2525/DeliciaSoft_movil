import './relleno_models.dart';

class TortaConfiguration {
  String sabor = '';
  String relleno = '';
  String tipoVenta = '';
  int porciones = 8;
  double libras = 1.0;
  RellenoModel? rellenoSeleccionado;
  
  TortaConfiguration();

  TortaConfiguration.withData({
    required this.sabor,
    required this.relleno,
    required this.tipoVenta,
    required this.porciones,
    required this.libras,
    this.rellenoSeleccionado,
  });

  // Método para obtener el precio adicional del relleno
  double getPrecioAdicionalRelleno() {
    return rellenoSeleccionado?.precioAdicion ?? 0.0;
  }

  // Método para verificar si la configuración está completa
  bool isComplete() {
    return sabor.isNotEmpty && tipoVenta.isNotEmpty;
  }

  // Método para obtener el nombre del relleno seleccionado
  String getNombreRelleno() {
    return rellenoSeleccionado?.nombre ?? 'Sin relleno';
  }

  // Método para copiar la configuración
  TortaConfiguration copyWith({
    String? sabor,
    String? relleno,
    String? tipoVenta,
    int? porciones,
    double? libras,
    RellenoModel? rellenoSeleccionado,
  }) {
    return TortaConfiguration.withData(
      sabor: sabor ?? this.sabor,
      relleno: relleno ?? this.relleno,
      tipoVenta: tipoVenta ?? this.tipoVenta,
      porciones: porciones ?? this.porciones,
      libras: libras ?? this.libras,
      rellenoSeleccionado: rellenoSeleccionado ?? this.rellenoSeleccionado,
    );
  }

  @override
  String toString() {
    return 'TortaConfiguration(sabor: $sabor, relleno: $relleno, tipoVenta: $tipoVenta, porciones: $porciones, libras: $libras, rellenoSeleccionado: $rellenoSeleccionado)';
  }
}