class Product {
  int? id;
  String name;
  String category;
  int quantity;
  double price;
  String description;
  String? imagePath;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.description,
    this.imagePath,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      description: map['description'] as String,
      imagePath: map['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'category': category,
      'quantity': quantity,
      'price': price,
      'description': description,
      'imagePath': imagePath,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
