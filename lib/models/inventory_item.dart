class InventoryItem {
  final String id;
  final String name;
  int quantity;
  final double price;
  final String description;

  InventoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.description,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "quantity": quantity,
      "price": price,
      "description": description,
    };
  }
}
