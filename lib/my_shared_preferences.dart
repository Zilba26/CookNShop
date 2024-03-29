import 'dart:convert';
import 'dart:ui';

import 'package:cook_n_shop/models/ingredient.dart';
import 'package:cook_n_shop/models/recipe.dart';
import 'package:cook_n_shop/models/shopping_item.dart';
import 'package:cook_n_shop/models/units.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySharedPreferences {
  static late SharedPreferences _prefs;

  static late List<Ingredient> _ingredients;
  static late int _lastIngredientId;
  static late List<Recipe> _recipes;
  static late int _lastRecipeId;
  static late List<ShoppingItem> _shoppingList;
  static late List<Unit> _unites;
  static late Color _themeColor;
  static Set<String> errorsMSG = {};
  static const baseColor = 0xAD0000FF;

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
    if (_prefs.getInt('themeColor') == null) {
      await _prefs.setInt('themeColor', baseColor);
    }
    //reset all
    // await _prefs.setString('ingredients', '[]');
    // await _prefs.setString('recipes', '[]');
    // await _prefs.setString('shoppingList', '[]');

    _ingredients = List<Ingredient>.from(
        jsonDecode(_prefs.getString('ingredients')!)
            .map((model) => Ingredient.fromJson(model))
            .toList());

    _lastIngredientId = _ingredients.isNotEmpty ? _ingredients.last.id : 4;
    _recipes = List<Recipe>.from(
        jsonDecode(_prefs.getString('recipes')!)
            .map((model) => Recipe.fromJson(model))
            .toList());
    _lastRecipeId = _recipes.isNotEmpty ? _recipes.last.id : 0;
    _shoppingList = List<ShoppingItem>.from(
        jsonDecode(_prefs.getString('shoppingList')!)
            .map((model) => ShoppingItem.fromJson(model))
            .toList());

    _unites = baseUnits + List<Unit>.from(
        jsonDecode(_prefs.getString('unites')!)
            .map((model) => Unit.fromJson(model))
            .toList());

    _themeColor = Color(_prefs.getInt('themeColor')!);
  }

  static List<Ingredient> get ingredients => _ingredients;
  static int get lastIngredientId => _lastIngredientId;
  static List<Recipe> get recipes => _recipes;
  static int get lastRecipeId => _lastRecipeId;
  static List<ShoppingItem> get shoppingList => _shoppingList;
  static List<Unit> get unites => _unites;
  static Color get themeColor => _themeColor;
  static set themeColor(Color color) {
    _themeColor = color;
    _prefs.setInt('themeColor', color.value);
  }

  static Future addIngredient(Ingredient ingredient) async {
    _ingredients.add(ingredient);
    _lastIngredientId++;
    await _prefs.setString('ingredients',
        jsonEncode(_ingredients.map((e) => e.toJson()).toList()));
  }

  static List<Recipe> checkIngredientInRecipes(Ingredient ingredient) {
    return _recipes.where((element) => element.ingredients.any((element) => element.ingredient.id == ingredient.id)).toList();
  }

  static Future removeIngredient(Ingredient ingredient) async {
    _ingredients.remove(ingredient);
    await _prefs.setString('ingredients',
        jsonEncode(_ingredients.map((e) => e.toJson()).toList()));
  }

  static Future updateIngredient(Ingredient ingredient) async {
    _ingredients[_ingredients.indexWhere((element) => element.id == ingredient.id)] = ingredient;
    await _prefs.setString('ingredients',
        jsonEncode(_ingredients.map((e) => e.toJson()).toList()));
  }

  static Future addRecipe(Recipe recipe) async {
    _recipes.add(recipe);
    _lastRecipeId++;
    await _prefs.setString('recipes',
        jsonEncode(_recipes.map((e) => e.toJson()).toList()));
  }

  static Future updateRecipe(Recipe recipe) async {
    _recipes[_recipes.indexWhere((element) => element.id == recipe.id)] = recipe;
    await _prefs.setString('recipes',
        jsonEncode(_recipes.map((e) => e.toJson()).toList()));
  }

  static Future removeRecipe(Recipe recipe) async {
    _recipes.remove(recipe);
    await _prefs.setString('recipes',
        jsonEncode(_recipes.map((e) => e.toJson()).toList()));
  }

  static checkIngredientFromShoppingList(Ingredient ingredient) {
    return _shoppingList.any((element) => element.ingredient.id == ingredient.id);
  }

  static getIngredientQuantityFromShoppingList(Ingredient ingredient) {
    return _shoppingList.firstWhere((element) => element.ingredient.id == ingredient.id).quantity;
  }

  static setIngredientQuantityFromShoppingList(Ingredient ingredient, int quantity) async {
    if (checkIngredientFromShoppingList(ingredient)) {
      _shoppingList.firstWhere((element) => element.ingredient.id == ingredient.id).quantity = quantity;
    } else {
      _shoppingList.add(ShoppingItem(ingredient: ingredient, quantity: quantity));
    }
    await _prefs.setString('shoppingList', jsonEncode(_shoppingList));
  }

  static _plusIngredientQuantityFromShoppingList(Ingredient ingredient, {int quantity = 1}) {
    _shoppingList.firstWhere((element) => element.ingredient.id == ingredient.id).quantity = (_shoppingList.firstWhere((element) => element.ingredient.id == ingredient.id).quantity+ quantity);
  }

  static _minusIngredientQuantityFromShoppingList(Ingredient ingredient, {int quantity = 1}) {
    _shoppingList.firstWhere((element) => element.ingredient.id == ingredient.id).quantity = (_shoppingList.firstWhere((element) => element.ingredient.id == ingredient.id).quantity- quantity);
    if (_shoppingList.firstWhere((element) => element.ingredient.id == ingredient.id).quantity< 0) {
      _shoppingList.firstWhere((element) => element.ingredient.id == ingredient.id).quantity = 0;
    }
  }

  static Future clearShoppingList() async {
    _shoppingList = [];
    await _prefs.setString('shoppingList', jsonEncode(_shoppingList));
  }

  static Future updateCheckedShoppingListItem(ShoppingItem shoppingItem) async {
    _shoppingList[_shoppingList.indexWhere((element) => element.ingredient.id == shoppingItem.ingredient.id)] = shoppingItem;
    await _prefs.setString('shoppingList', jsonEncode(_shoppingList));
  }

  static Future addIngredientToShoppingList(Ingredient ingredient, {int? quantity}) async {
    if (quantity == null) {
      switch (ingredient.unit.fullName) {
        case "millilitre":
        case "centilitre":
        case "décilitre":
        case "gramme":
        case "milligramme":
          quantity = 10;
          break;
        default:
          quantity = 1;
      }
    }
    if (checkIngredientFromShoppingList(ingredient)) {
      _plusIngredientQuantityFromShoppingList(ingredient, quantity: quantity);
    } else {
      _shoppingList.add(ShoppingItem(ingredient: ingredient, quantity: quantity));
    }
    await _prefs.setString('shoppingList', jsonEncode(_shoppingList));
  }

  static Future minusIngredientToShoppingList(Ingredient ingredient, {int? quantity}) async {
    if (quantity == null) {
      switch (ingredient.unit.fullName) {
        case "millilitre":
        case "centilitre":
        case "décilitre":
        case "gramme":
        case "milligramme":
          quantity = 10;
          break;
        default:
          quantity = 1;
      }
    }
    if (checkIngredientFromShoppingList(ingredient)) {
      _minusIngredientQuantityFromShoppingList(ingredient, quantity: quantity);
      if (getIngredientQuantityFromShoppingList(ingredient) <= 0) {
        _shoppingList.removeWhere((element) => element.ingredient.id == ingredient.id);
      }
    }
    await _prefs.setString('shoppingList', jsonEncode(_shoppingList));
  }

  static Future removeIngredientFromShoppingList(Ingredient ingredient) async {
    if (checkIngredientFromShoppingList(ingredient)) {
      _shoppingList.removeWhere((element) => element.ingredient.id == ingredient.id);
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

  static Future reorderShoppingListItem(int oldIndex, int newIndex) async {
    final ShoppingItem item = _shoppingList.removeAt(oldIndex);
    _shoppingList.insert(newIndex, item);
    await _prefs.setString('shoppingList', jsonEncode(_shoppingList));
  }
}
