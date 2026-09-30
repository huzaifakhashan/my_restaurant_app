import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/meal.dart';

class MealService {
  static final CollectionReference<Map<String, dynamic>> _mealsRef =
      FirebaseFirestore.instance.collection('meals');

  static Stream<List<Meal>> streamAvailableMeals() {
    return _mealsRef
        .where('status', isEqualTo: MealStatus.available.name)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Meal.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  static Stream<List<Meal>> streamMyMeals(String restaurantId) {
    return _mealsRef
        .where('restaurantId', isEqualTo: restaurantId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Meal.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  static Future<void> addMeal(Meal meal) {
    return _mealsRef.add(meal.toMap());
  }

  static Future<void> deleteMeal(String id) {
    return _mealsRef.doc(id).delete();
  }
}
