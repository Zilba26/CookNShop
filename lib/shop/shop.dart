import 'package:cook_n_shop/models/ingredient.dart';
import 'package:cook_n_shop/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class Shop extends StatefulWidget {
  const Shop({Key? key}) : super(key: key);

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {

  List<bool> _checked = List<bool>.filled(MySharedPreferences.shoppingList.length, false);

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
                leading: Checkbox(
                  value: _checked[MySharedPreferences.shoppingList.indexOf(elt)],
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() {
                        _checked[MySharedPreferences.shoppingList.indexOf(elt)] = value;
                      });
                    }
                  },
                ),
                title: Text(ingredient.name),
                trailing: Text(elt["quantity"].toString() + ingredient.unit.unit),
              ),
            );
          }).toList()
        ),
      ),
      floatingActionButton: SpeedDial(
        spacing: 8,
        spaceBetweenChildren: 8,
        icon: Icons.delete,
        backgroundColor: Colors.red,
        children: [
          SpeedDialChild(
            child: Icon(Icons.delete),
            label: "Supprimer les éléments cochés",
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Supprimer les éléments cochés"),
                    content: const Text("Êtes-vous sûr de vouloir supprimer les éléments cochés ?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Annuler"),
                      ),
                      TextButton(
                        onPressed: () {
                          for (int i = _checked.length - 1; i >= 0; i--) {
                            if (_checked[i]) {
                              MySharedPreferences.removeIngredientFromShoppingList(MySharedPreferences.ingredients.where((element) => element.id == MySharedPreferences.shoppingList[i]["id"]).first);
                            }
                          }
                          Navigator.of(context).pop();
                          setState(() {
                            _checked = List<bool>.filled(MySharedPreferences.shoppingList.length, false);
                          });
                        },
                        child: const Text("Supprimer"),
                      ),
                    ],
                  );
                }
              );
            }
          ),
          SpeedDialChild(
            child: Icon(Icons.delete),
            label: "Supprimer la liste de courses",
            onTap: () {
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
          )
        ],
      )
                // showDialog(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         title: const Text("Supprimer la liste de courses"),
                //         content: const Text("Êtes-vous sûr de vouloir supprimer la liste de courses ?"),
                //         actions: [
                //           TextButton(
                //             onPressed: () {
                //               Navigator.of(context).pop();
                //             },
                //             child: const Text("Annuler"),
                //           ),
                //           TextButton(
                //             onPressed: () {
                //               MySharedPreferences.clearShoppingList();
                //               Navigator.of(context).pop();
                //               setState(() {});
                //             },
                //             child: const Text("Supprimer"),
                //           ),
                //         ],
                //       );
                //     }
                // );
    );
  }
}