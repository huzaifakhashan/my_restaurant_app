import 'package:flutter/material.dart';

import '../../models/meal.dart';
import '../../services/auth_service.dart';
import '../../services/reservation_service.dart';

class MealDetailsScreen extends StatefulWidget {
  final Meal meal;

  const MealDetailsScreen({
    super.key,
    required this.meal,
  });

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  int selectedQuantity = 1;
  bool isReserving = false;

  Future<void> reserveMeal() async {
    setState(() {
      isReserving = true;
    });

    final reservation = await ReservationService.reserveMeal(
      meal: widget.meal,
      quantity: selectedQuantity,
      requesterId: AuthService.currentUser!.id,
    );

    if (!mounted) return;

    setState(() {
      isReserving = false;
    });

    if (reservation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الكمية المطلوبة غير متوفرة'),
        ),
      );

      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تم الحجز بنجاح 🎉'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('رمز الاستلام الخاص بك:'),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(),
                ),
                child: Text(
                  reservation.code,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'الكمية: ${reservation.quantity}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('تم'),
            ),
          ],
        );
      },
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الوجبة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.restaurant,
              size: 90,
            ),

            const SizedBox(height: 20),

            Text(
              meal.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _info(
              Icons.numbers,
              'الكمية المتوفرة',
              '${meal.quantity}',
            ),

            _info(
              Icons.access_time,
              'وقت الاستلام',
              meal.pickupTime,
            ),

            _info(
              Icons.location_on,
              'الموقع',
              meal.location,
            ),

            _info(
              Icons.notes,
              'ملاحظات',
              meal.notes.isEmpty ? 'لا يوجد' : meal.notes,
            ),

            const SizedBox(height: 25),

            const Text(
              'اختر الكمية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<int>(
              initialValue: selectedQuantity,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: List.generate(
                meal.quantity,
                (index) {
                  final quantity = index + 1;

                  return DropdownMenuItem(
                    value: quantity,
                    child: Text('$quantity'),
                  );
                },
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedQuantity = value;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: (meal.quantity > 0 && !isReserving)
                  ? reserveMeal
                  : null,
              icon: const Icon(Icons.bookmark),
              label: Text(
                isReserving ? 'جارٍ الحجز...' : 'حجز الوجبة',
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}