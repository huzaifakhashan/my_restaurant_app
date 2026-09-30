import 'package:flutter/material.dart';

import '../../models/meal.dart';
import '../../services/meal_service.dart';
import '../../widgets/meal_card.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الوجبات المتاحة'),
      ),

      body: StreamBuilder<List<Meal>>(
        stream: MealService.streamAvailableMeals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final meals = snapshot.data ?? [];

          if (meals.isEmpty) {
            return const Center(
              child: Text('لا توجد وجبات متاحة حالياً'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              return MealCard(meal: meals[index]);
            },
          );
        },
      ),
    );
  }
}
