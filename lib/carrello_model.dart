class CarrelloModel {
  final String name;
  final String image;
  final String description;
  final double price;
  int quantity;

  CarrelloModel({
    required this.name,
    required this.image,
    required this.description,
    required this.price,
    this.quantity = 0, // Quantità predefinita a 0
  });

  
}