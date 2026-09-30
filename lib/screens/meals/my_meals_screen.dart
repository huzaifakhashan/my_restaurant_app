import 'package:flutter/material.dart';
import '../../models/meal.dart';
import '../../services/auth_service.dart';
import '../../services/meal_service.dart';

class MyMealsScreen extends StatelessWidget {
  const MyMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final restaurantId = AuthService.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('وجباتي'),
      ),
      body: StreamBuilder<List<Meal>>(
        stream: MealService.streamMyMeals(restaurantId),
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
              child: Text('لا توجد وجبات منشورة'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.restaurant),
                  ),
                  title: Text(meal.name),
                  subtitle: Text(
                    'الكمية: ${meal.quantity}\n'
                    'وقت الاستلام: ${meal.pickupTime}\n'
                    'الموقع: ${meal.location}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        MealService.deleteMeal(meal.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('حذف'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
