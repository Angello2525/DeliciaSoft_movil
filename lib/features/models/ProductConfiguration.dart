class ProductConfiguration {
  String selectedSize;
  List<String> selectedToppings;
  List<String> selectedSalsas;
  List<String> selectedAdiciones;

  ProductConfiguration({
    this.selectedSize = '',
    List<String>? selectedToppings,
    List<String>? selectedSalsas,
    List<String>? selectedAdiciones,
  })  : selectedToppings = selectedToppings ?? [],
        selectedSalsas = selectedSalsas ?? [],
        selectedAdiciones = selectedAdiciones ?? [];
}