import 'package:cook_n_shop/models/ingredient.dart';

class ShoppingItem {
  Ingredient ingredient;
  int quantity;
  bool isChecked;

  ShoppingItem({required this.ingredient, required this.quantity, this.isChecked = false});

  Map<String, dynamic> toJson() => {
    'ingredient': ingredient.toJson(),
    'quantity': quantity,
    'isChecked': isChecked
  };

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      ingredient: Ingredient.fromJson(json['ingredient']),
      quantity: json['quantity'],
      isChecked: json['isChecked'] ?? false,
    );
  }
}