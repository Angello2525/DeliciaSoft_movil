class CategoriaMapper {
  static String? getNombre(int? id) {
    switch (id) {
      case 1:
        return 'Obleas';
      case 2:
        return 'Cholados';
      case 3:
        return 'Fresas con crema';
      case 4:
        return 'Malteadas';
      default:
        return null; // o 'Sin categoría'
    }
  }
}