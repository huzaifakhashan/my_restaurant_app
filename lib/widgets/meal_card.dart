import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../screens/meals/meal_details_screen.dart';

class MealCard extends StatelessWidget {
  final Meal meal;

  const MealCard({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant,
                  size: 35,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text('الكمية: ${meal.quantity} وجبة'),

            const SizedBox(height: 6),

            Text('📍 ${meal.location}'),

            const SizedBox(height: 6),

            Text('⏰ ${meal.pickupTime}'),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MealDetailsScreen(
                        meal: meal,
                      ),
                    ),
                  );
                },
                child: const Text('عرض التفاصيل'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 