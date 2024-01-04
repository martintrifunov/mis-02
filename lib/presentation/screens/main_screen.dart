import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lab_2/data/models/clothing_item.dart';
import 'package:lab_2/data/repository/clothing_products_repository.dart';

final getIt = GetIt.instance;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Iterable<ClothingItem> clothingItems = const Iterable.empty();

  @override
  void initState() {
    super.initState();
    fetchAndUpdateClothingItems();
  }

  void fetchAndUpdateClothingItems() {
    getIt<ClothingProductsRepository>()
        .getClothingItems()
        .then((result) => setState(() => clothingItems = result));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            '201117',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black87,
        ),
        body: ListView.builder(
            itemCount: clothingItems.length,
            itemBuilder: (BuildContext context, int index) {
              final currentClothingItem = clothingItems.elementAt(index);
              return Padding(
                  padding: const EdgeInsets.all(5),
                  child: ListTile(
                    tileColor: Colors.black87,
                    title: Text(
                      clothingItems.elementAt(index).name,
                      style: const TextStyle(
                          color: Colors.lightBlue,
                          fontWeight: FontWeight.w500,
                          fontSize: 17),
                    ),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: Colors.green),
                          onPressed: () {
                            presentEditClothingItemDialog(
                                    context, currentClothingItem)
                                .then((value) => fetchAndUpdateClothingItems());
                          }),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.green),
                        onPressed: () {
                          presentDeleteClothingItemDialog(
                                  context, currentClothingItem)
                              .then((value) =>
                                  {if (value) fetchAndUpdateClothingItems()});
                        },
                      )
                    ]),
                    subtitle: Text(
                      '${currentClothingItem.description} - ${currentClothingItem.price} МКД',
                      style: const TextStyle(color: Colors.lightBlue),
                    ),
                  ));
            }),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              presentAddClothingItemDialog(context)
                  .then((value) => fetchAndUpdateClothingItems());
            },
            child: const Icon(Icons.add)));
  }
}

Future<void> presentEditClothingItemDialog(
    BuildContext context, ClothingItem clothingItem) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return editClothingItemDialog(context, clothingItem);
      });
}

Widget editClothingItemDialog(BuildContext context, ClothingItem clothingItem) {
  final GlobalKey<FormState> editClothingItemFormKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  return SimpleDialog(
    contentPadding: const EdgeInsets.all(20),
    title: const Text('Измени парче облека'),
    children: [
      Form(
        key: editClothingItemFormKey,
        child: Column(
          children: [
            TextFormField(
              autofocus: true,
              controller: nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Името е задолжително поле!';
                }
                return null;
              },
              decoration: InputDecoration(hintText: clothingItem.name),
            ),
            TextFormField(
              controller: descriptionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Описот е задолжително поле!';
                }
                return null;
              },
              decoration: InputDecoration(hintText: clothingItem.description),
            ),
            TextFormField(
              controller: priceController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Цената е задолжително поле!';
                }
                final numberRegex = RegExp(r'^\d*\.?\d+$');
                if (!numberRegex.hasMatch(value)) {
                  return 'Please enter a valid number';
                }
                return null;
              },
              decoration:
                  InputDecoration(hintText: clothingItem.price.toString()),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
            )
          ],
        ),
      ),
      ElevatedButton(
          onPressed: () {
            if (editClothingItemFormKey.currentState!.validate()) {
              getIt<ClothingProductsRepository>()
                  .editClothingItem(
                      clothingItem.itemId,
                      nameController.text,
                      descriptionController.text,
                      int.parse(priceController.text))
                  .then((val) => Navigator.of(context).pop());
            }
          },
          child: const Text('Зачувај измени'))
    ],
  );
}

Future<bool> presentDeleteClothingItemDialog(
    BuildContext context, ClothingItem clothingItem) {
  final Completer<bool> dialogCompleter = Completer();

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Потврда.'),
          content: Text('Дали сакате да го избришете ${clothingItem.name}'),
          actions: [
            TextButton(
                onPressed: () {
                  dialogCompleter.complete(false);
                  Navigator.of(context).pop();
                },
                child: const Text('Не')),
            TextButton(
                onPressed: () {
                  getIt
                      .get<ClothingProductsRepository>()
                      .deleteClothingItem(clothingItem.itemId);
                  dialogCompleter.complete(true);
                  Navigator.of(context).pop();
                },
                child: const Text('Да'))
          ],
        );
      });

  return dialogCompleter.future;
}

Future<void> presentAddClothingItemDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return addClothingItemDialog(context);
      });
}

Widget addClothingItemDialog(BuildContext context) {
  final GlobalKey<FormState> addClothingItemFormKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  return SimpleDialog(
    contentPadding: const EdgeInsets.all(20),
    title: const Text('Додади парче облека'),
    children: [
      Form(
        key: addClothingItemFormKey,
        child: Column(
          children: [
            TextFormField(
              autofocus: true,
              controller: nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Името е задолжително поле!';
                }
                return null;
              },
              decoration: const InputDecoration(hintText: 'Име на производ'),
            ),
            TextFormField(
              controller: descriptionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Описот е задолжително поле!';
                }
                return null;
              },
              decoration: const InputDecoration(hintText: 'Опис на производ'),
            ),
            TextFormField(
              controller: priceController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Цената е задолжително поле!';
                }
                return null;
              },
              decoration: const InputDecoration(hintText: 'Цена на производ'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false),
            )
          ],
        ),
      ),
      ElevatedButton(
          onPressed: () {
            if (addClothingItemFormKey.currentState!.validate()) {
              getIt<ClothingProductsRepository>()
                  .addClothingItem(
                      nameController.text,
                      descriptionController.text,
                      int.parse(priceController.text))
                  .then((val) => Navigator.of(context).pop());
            }
          },
          child: const Text('Зачувај производ'))
    ],
  );
}
