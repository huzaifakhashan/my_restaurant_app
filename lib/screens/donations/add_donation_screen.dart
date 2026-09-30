import 'package:flutter/material.dart';
import '../../models/donation.dart';
import '../../services/auth_service.dart';
import '../../services/donation_service.dart';

class AddDonationScreen extends StatefulWidget {
  const AddDonationScreen({super.key});

  @override
  State<AddDonationScreen> createState() => _AddDonationScreenState();
}

class _AddDonationScreenState extends State<AddDonationScreen> {
  final titleController = TextEditingController();
  final quantityController = TextEditingController();
  final pickupTimeController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();

  DonationType selectedType = DonationType.packagedFood;

  @override
  void dispose() {
    titleController.dispose();
    quantityController.dispose();
    pickupTimeController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  bool isPublishing = false;

  Future<void> publishDonation() async {
    if (titleController.text.trim().isEmpty ||
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

    final donation = Donation(
      id: '',
      donorId: AuthService.currentUser!.id,
      title: titleController.text.trim(),
      type: selectedType,
      quantity: int.tryParse(quantityController.text.trim()) ?? 0,
      location: locationController.text.trim(),
      pickupTime: pickupTimeController.text.trim(),
      description: descriptionController.text.trim(),
    );

    await DonationService.addDonation(donation);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نشر تبرعك بنجاح'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة تبرع'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان التبرع',
                prefixIcon: Icon(Icons.title),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<DonationType>(
              initialValue: selectedType,
              decoration: const InputDecoration(
                labelText: 'نوع التبرع',
                prefixIcon: Icon(Icons.category),
              ),
              items: DonationType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedType = value;
                  });
                }
              },
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
              controller: descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'وصف التبرع',
                prefixIcon: Icon(Icons.notes),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: isPublishing ? null : publishDonation,
              child: isPublishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'نشر التبرع',
                      style: TextStyle(fontSize: 17),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
