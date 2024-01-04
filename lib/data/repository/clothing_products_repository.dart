import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lab_2/data/models/clothing_item.dart';

class ClothingProductsRepository {
  CollectionReference clothingItems =
      FirebaseFirestore.instance.collection('clothes');

  Future<Iterable<ClothingItem>> getClothingItems() async {
    QuerySnapshot querySnapshot = await clothingItems.get();

    return querySnapshot.docs.map((clothingItem) => ClothingItem(
        itemId: clothingItems.doc(clothingItem.id).id,
        name: clothingItem['name'],
        description: clothingItem['description'],
        price: clothingItem['price']));
  }

  Future<void> addClothingItem(
      String name, String description, int price) async {
    await clothingItems
        .add({'name': name, 'description': description, 'price': price});
  }

  void deleteClothingItem(String itemId) {
    clothingItems.doc(itemId).delete();
  }

  Future<void> editClothingItem(
      String itemId, String name, String description, int price) async {
    await clothingItems
        .doc(itemId)
        .update({'name': name, 'description': description, 'price': price});
  }
}
