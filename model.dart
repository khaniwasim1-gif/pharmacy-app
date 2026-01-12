class Medicine {
  String name;
  int quantity;
  double price;
  String expiry;
  String category;

  Medicine({
    required this.name,
    required this.quantity,
    required this.price,
    required this.expiry,
    required this.category,

  });
  double get totalPrice => quantity * price;
  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'price': price,
    'expiry': expiry,
    'category': category,
  };

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      name: json['name'],
      quantity: json['quantity'],
      price: json['price'],
      expiry: json['expiry'],
      category: json['category'],
    );
  }
}
