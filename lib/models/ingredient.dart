import 'package:cook_n_shop/models/units.dart';
import 'package:cook_n_shop/my_shared_preferences.dart';

class Ingredient {
  final int id;
  final String name;
  final String? img;
  final Unit unit;
  final bool isNetwork;
  double? quantityEquality;
  Unit? unitEquality;

  Ingredient({
    required this.id,
    required this.name,
    required this.img,
    required this.unit,
    this.isNetwork = true,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      name: json['name'],
      img: json['img'],
      unit: Unit.fromJson(json['unite']),
      isNetwork: json['isNetwork'] ?? true,
    );
  }

  factory Ingredient.fromName(String name, {String? img, Unit? unit, bool isNetwork = true}) {
    return Ingredient(
      id: MySharedPreferences.lastIngredientId + 1,
      name: name,
      img: img,
      unit: unit ?? baseUnits[0],
      isNetwork: isNetwork,
    );
  }

  String? get image => img == null ? null : (isNetwork ? img : "assets/images/$img");

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'img': img,
    'unite': unit.toJson(),
  };
}