import 'package:flutter/material.dart';
import '../../models/meal.dart';
import '../../services/auth_service.dart';
import '../../services/meal_service.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final pickupTimeController = TextEditingController();
  final locationController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    pickupTimeController.dispose();
    locationController.dispose();
    notesController.dispose();
    super.dispose();
  }

  bool isPublishing = false;

  Future<void> publishMeal() async {
    if (nameController.text.trim().isEmpty ||
        quantityController.text.trim().isEmpty ||
        pickupTimeController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تعبئة جميع الحقول المطلوبة'),
        ),
      );
      return;
    }

    setState(() {
      isPublishing = true;
    });

    final meal = Meal(
      id: '',
      restaurantId: AuthService.currentUser!.id,
      name: nameController.text.trim(),
      quantity: int.tryParse(quantityController.text.trim()) ?? 0,
      pickupTime: pickupTimeController.text.trim(),
      location: locationController.text.trim(),
      notes: notesController.text.trim(),
    );

    await MealService.addMeal(meal);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نشر الوجبة بنجاح'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة وجبة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الوجبة',
                prefixIcon: Icon(Icons.restaurant),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الكمية',
                prefixIcon: Icon(Icons.numbers),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: pickupTimeController,
              decoration: const InputDecoration(
                labelText: 'وقت الاستلام',
                prefixIcon: Icon(Icons.access_time),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'موقع الاستلام',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'ملاحظات',
                prefixIcon: Icon(Icons.notes),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: isPublishing ? null : publishMeal,
              child: isPublishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'نشر الوجبة',
                      style: TextStyle(fontSize: 17),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}