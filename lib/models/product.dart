class Product {
  final String uuid;
  final String name;
  final String description;
  final double price;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.uuid,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      uuid: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] is int) 
        ? (json['price'] as int).toDouble() 
        : (json['price'] ?? 0.0),
      image: json['image'] ?? '',
      createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
      updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image': image,
    };
  }

  Product copyWith({
    String? uuid,
    String? name,
    String? description,
    double? price,
    String? image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
