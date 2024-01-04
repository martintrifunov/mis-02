import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:lab_2/firebase_options.dart';
import 'package:lab_2/presentation/screens/main_screen.dart';
import 'package:lab_2/data/repository/clothing_products_repository.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  getIt.registerSingleton(ClothingProductsRepository());

  return runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainScreen(),
  ));
}
