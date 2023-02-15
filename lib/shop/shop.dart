import 'package:cook_n_shop/models/ingredient.dart';
import 'package:cook_n_shop/models/shopping_item.dart';
import 'package:cook_n_shop/my_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class Shop extends StatefulWidget {
  const Shop({Key? key}) : super(key: key);

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {

  late List<ShoppingItem> _shoppingList;

  @override
  void initState() {
    setShoppingList();
    super.initState();
  }

  void setShoppingList() {
    setState(() {
      _shoppingList = MySharedPreferences.shoppingList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: _shoppingList.map((elt) {
            return Dismissible(
              key: ValueKey<int>(elt.ingredient.id),
              background: Container(
                color: Colors.red,
              ),
              onDismissed: (direction) async {
                await MySharedPreferences.removeIngredientFromShoppingList(elt.ingredient);
                setState(() {});
              },
              child: ListTile(
                leading: Checkbox(
                  value: elt.isChecked,
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() {
                        elt.isChecked = value;
                      });
                      await MySharedPreferences.updateCheckedShoppingListItem(elt);
                    }
                  },
                ),
                title: Text(elt.ingredient.name),
                trailing: Text(elt.quantity.toString() + elt.ingredient.unit.unit),
              ),
            );
          }).toList()
        ),
      ),
      floatingActionButton: SpeedDial(
        spacing: 8,
        spaceBetweenChildren: 8,
        icon: Icons.more_vert,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.delete),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
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
                          setState(() {
                            setShoppingList();
                          });
                        },
                        child: const Text("Supprimer"),
                      ),
                    ],
                  );
                }
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.checklist),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
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
                          for (int i = _shoppingList.length - 1; i >= 0; i--) {
                            if (_shoppingList[i].isChecked) {
                              MySharedPreferences.removeIngredientFromShoppingList(MySharedPreferences.ingredients.where((element) => element.id == _shoppingList[i].ingredient.id).first);
                            }
                          }
                          Navigator.of(context).pop();
                          setState(() {
                            setShoppingList();
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
            child: const Icon(Icons.add),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: "Ajouter un ingrédient",
            onTap: () {
              GlobalKey<FormState> formKey = GlobalKey<FormState>();
              Ingredient? ingredientToAdd;
              TextEditingController quantityController = TextEditingController();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return AlertDialog(
                        title: const Text("Ajouter un ingrédient"),
                        content: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Autocomplete<Ingredient>(
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text == "") {
                                    return const Iterable<Ingredient>.empty();
                                  }
                                  return MySharedPreferences.ingredients.where((Ingredient ingredient) {
                                    return ingredient.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                                  });
                                },
                                onSelected: (Ingredient ingredient) {
                                  setStateDialog(() {
                                    ingredientToAdd = ingredient;
                                  });
                                },
                                displayStringForOption: (Ingredient ingredient) => ingredient.name,
                                fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                                  return TextFormField(
                                    controller: textEditingController,
                                    focusNode: focusNode,
                                    onFieldSubmitted: (String value) {
                                      onFieldSubmitted();
                                    },
                                    validator: (String? value) {
                                      if (value == null || value == "") {
                                        return "Veuillez sélectionner un ingrédient";
                                      }
                                      if (ingredientToAdd == null || ingredientToAdd!.name != value) {
                                        return "Ingrédient invalide";
                                      }
                                      return null;
                                    },
                                    onChanged: (String value) {
                                      setStateDialog(() {
                                        ingredientToAdd = null;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      labelText: "Ingrédient",
                                    ),
                                  );
                                },
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: quantityController,
                                      decoration: const InputDecoration(
                                        labelText: "Quantité",
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      validator: (String? value) {
                                        if (value == null || value == "") {
                                          return "Veuillez saisir une quantité";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(width: 20, child: Text(ingredientToAdd?.unit.unit ?? "")),
                                ],
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Annuler"),
                          ),
                          TextButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                MySharedPreferences.addIngredientToShoppingList(ingredientToAdd!, quantity: int.parse(quantityController.text));
                                Navigator.pop(context);
                                setState(() {
                                  setShoppingList();
                                });
                              }
                            },
                            child: const Text("Ajouter"),
                          ),
                        ],
                      );
                    }
                  );
                }
              );
            }
          )
        ],
      )
    );
  }
}