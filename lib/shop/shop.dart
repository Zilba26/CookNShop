import 'package:cook_n_shop/models/ingredient.dart';
import 'package:cook_n_shop/my_shared_preferences.dart';
import 'package:flutter/material.dart';

class Shop extends StatefulWidget {
  const Shop({Key? key}) : super(key: key);

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: MySharedPreferences.shoppingList.map((elt) {
            Ingredient ingredient = MySharedPreferences.ingredients.where((element) => element.id == elt["id"]).first;
            return Dismissible(
              key: ValueKey<int>(ingredient.id),
              background: Container(
                color: Colors.red,
              ),
              onDismissed: (direction) async {
                await MySharedPreferences.removeIngredientFromShoppingList(ingredient);
                setState(() {});
              },
              child: ListTile(
                title: Text(ingredient.name),
                trailing: Text(elt["quantity"].toString() + ingredient.unit.unit),
              ),
            );
          }).toList()
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Supprimer la liste de courses"),
                content: const Text("Êtes-vous sûr de vouloir supprimer la liste de courses ?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Annuler"),
                  ),
                  TextButton(
                    onPressed: () {
                      MySharedPreferences.clearShoppingList();
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    child: const Text("Supprimer"),
                  ),
                ],
              );
            }
          );
        },
        child: const Icon(Icons.delete),
      )
    );
  }
}