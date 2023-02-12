import 'dart:convert';

import 'package:cook_n_shop/models/ingredient.dart';
import 'package:cook_n_shop/models/recipe.dart';
import 'package:cook_n_shop/models/units.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  static late SharedPreferences _prefs;

  static late List<Ingredient> _ingredients;
  static late int _lastIngredientId;
  static late List<Recipe> _recipes;
  static late int _lastRecipeId;
  static late List<Map<String, dynamic>> _shoppingList;
  static late List<Unit> _unites;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs.getString('ingredients') == null) {
      await _prefs.setString('ingredients', '[]');
    }
    if (_prefs.getString('recipes') == null) {
      await _prefs.setString('recipes', '[]');
    }
    if (_prefs.getString('shoppingList') == null) {
      await _prefs.setString('shoppingList', '[]');
    }
    if (_prefs.getString('unites') == null) {
      await _prefs.setString('unites', '[]');
    }
    //reset all
    // await _prefs.setString('ingredients', '[]');
    // await _prefs.setString('recipes', '[]');
    // await _prefs.setString('shoppingList', '[]');

    _ingredients = List<Ingredient>.from(
        jsonDecode(_prefs.getString('ingredients')!)
            .map((model) => Ingredient.fromJson(model))
            .toList());
    // _ingredients.forEach((element) {
    //   print(element.id);
    // });
    _lastIngredientId = _ingredients.isNotEmpty ? _ingredients.last.id : 4;
    _recipes = List<Recipe>.from(
        jsonDecode(_prefs.getString('recipes')!)
            .map((model) => Recipe.fromJson(model))
            .toList());
    _lastRecipeId = _recipes.isNotEmpty ? _recipes.last.id : 0;
    _shoppingList = List<Map<String, dynamic>>.from(
        jsonDecode(_prefs.getString('shoppingList')!).toList());

    _unites = baseUnits + List<Unit>.from(
        jsonDecode(_prefs.getString('unites')!)
            .map((model) => Unit.fromJson(model))
            .toList());
  }

  static List<Ingredient> get ingredients => _ingredients;
  static int get lastIngredientId => _lastIngredientId;
  static List<Recipe> get recipes => _recipes;
  static int get lastRecipeId => _lastRecipeId;
  static List<Map<String, dynamic>> get shoppingList => _shoppingList;
  static List<Unit> get unites => _unites;

  static Future addIngredient(Ingredient ingredient) async {
    _ingredients.add(ingredient);
    _lastIngredientId++;
    await _prefs.setString('ingredients',
        jsonEncode(_ingredients.map((e) => e.toJson()).toList()));
  }

  static Future removeIngredient(Ingredient ingredient) async {
    _ingredients.remove(ingredient);
    await _prefs.setString('ingredients',
        jsonEncode(_ingredients.map((e) => e.toJson()).toList()));
  }

  static Future addRecipe(Recipe recipe) async {
    _recipes.add(recipe);
    _lastRecipeId++;
    await _prefs.setString('recipes',
        jsonEncode(_recipes.map((e) => e.toJson()).toList()));
  }

  static Future removeRecipe(Recipe recipe) async {
    _recipes.remove(recipe);
    await _prefs.setString('recipes',
        jsonEncode(_recipes.map((e) => e.toJson()).toList()));
  }

  static checkIngredientFromShoppingList(Ingredient ingredient) {
    return _shoppingList.any((element) => element["id"] == ingredient.id);
  }

  static getIngredientQuantityFromShoppingList(Ingredient ingredient) {
    return _shoppingList.firstWhere((element) => element["id"] == ingredient.id)["quantity"];
  }

  static setIngredientQuantityFromShoppingList(Ingredient ingredient, int quantity) async {
    if (checkIngredientFromShoppingList(ingredient)) {
      _shoppingList.firstWhere((element) => element["id"] == ingredient.id)["quantity"] = quantity;
    } else {
      _shoppingList.add({
        "id": ingredient.id,
        "quantity": quantity,
      });
    }
    await _prefs.setString('shoppingList', jsonEncode(_shoppingList));
  }

  static _plusIngredientQuantityFromShoppingList(Ingredient ingredient, {int quantity = 1}) {
    _shoppingList.firstWhere((element) => element["id"] == ingredient.id)["quantity"] = (_shoppingList.firstWhere((element) => element["id"] == ingredient.id)["quantity"]! + quantity);
  }

  static _minusIngredientQuantityFromShoppingList(Ingredient ingredient, {int quantity = 1}) {
    _shoppingList.firstWhere((element) => element["id"] == ingredient.id)["quantity"] = (_shoppingList.firstWhere((element) => element["id"] == ingredient.id)["quantity"]! - quantity);
    if (_shoppingList.firstWhere((element) => element["id"] == ingredient.id)["quantity"]! < 0) {
      _shoppingList.firstWhere((element) => element["id"] == ingredient.id)["quantity"] = 0;
    }
  }

  static Future clearShoppingList() async {
    _shoppingList = [];
    await _prefs.setString('shoppingList', jsonEncode(_shoppingList));
  }

  static Future addIngredientToShoppingList(Ingredient ingredient, {int quantity = 1}) async {
    if (checkIngredientFromShoppingList(ingredient)) {
      _plusIngredientQuantityFromShoppingList(ingredient, quantity: quantity);
    } else {
      _shoppingList.add({
        "id": ingredient.id,
        "quantity": quantity,
      });
    }
    await _prefs.setString('shoppingList', jsonEncode(_shoppingList));
  }

  static Future minusIngredientToShoppingList(Ingredient ingredient) async {
    if (checkIngredientFromShoppingList(ingredient)) {
      _minusIngredientQuantityFromShoppingList(ingredient);
      if (getIngredientQuantityFromShoppingList(ingredient) == 0) {
        _shoppingList.removeWhere((element) => element["id"] == ingredient.id);
      }
    }
    await _prefs.setString('shoppingList', jsonEncode(_shoppingList));
  }

  static Future removeIngredientFromShoppingList(Ingredient ingredient) async {
    if (checkIngredientFromShoppingList(ingredient)) {
      _shoppingList.removeWhere((element) => element["id"] == ingredient.id);
    }
    await _prefs.setString('shoppingList', jsonEncode(_shoppingList));
  }

  static Future addUnite(Unit unite) async {
    if (_unites.any((element) => element.toString() == unite.toString())) {
      return;
    }
    _unites.add(unite);
    await _prefs.setString('unites',
        jsonEncode(_unites.map((e) => e.toJson()).toList()));
  }
}
