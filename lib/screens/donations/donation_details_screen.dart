import 'package:flutter/material.dart';

import '../../models/donation.dart';
import '../../services/auth_service.dart';
import '../../services/donation_request_service.dart';

class DonationDetailsScreen extends StatefulWidget {
  final Donation donation;

  const DonationDetailsScreen({
    super.key,
    required this.donation,
  });

  @override
  State<DonationDetailsScreen> createState() =>
      _DonationDetailsScreenState();
}

class _DonationDetailsScreenState
    extends State<DonationDetailsScreen> {

  int selectedQuantity = 1;
  bool isRequesting = false;

  Future<void> requestDonation() async {
    setState(() {
      isRequesting = true;
    });

    final request = await DonationRequestService.requestDonation(
      donation: widget.donation,
      quantity: selectedQuantity,
      requesterId: AuthService.currentUser!.id,
    );

    if (!mounted) return;

    setState(() {
      isRequesting = false;
    });

    if (request == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الكمية المطلوبة غير متوفرة',
          ),
        ),
      );

      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'تم الطلب بنجاح 🎉',
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'رمز الاستلام الخاص بك:',
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(),
                ),

                child: Text(
                  request.code,
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'الكمية: ${request.quantity}',
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
    final donation = widget.donation;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفاصيل التبرع',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Center(
              child: Icon(
                Icons.volunteer_activism,
                size: 100,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              donation.title,

              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            _info(
              Icons.category,
              'نوع التبرع',
              donation.type.label,
            ),

            _info(
              Icons.numbers,
              'الكمية المتوفرة',
              '${donation.quantity}',
            ),

            _info(
              Icons.location_on,
              'الموقع',
              donation.location,
            ),

            _info(
              Icons.access_time,
              'وقت الاستلام',
              donation.pickupTime,
            ),

            _info(
              Icons.description,
              'الوصف',
              donation.description,
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

              decoration:
                  const InputDecoration(
                border: OutlineInputBorder(),
              ),

              items: List.generate(
                donation.quantity,
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
              onPressed:
                  (donation.quantity > 0 && !isRequesting)
                      ? requestDonation
                      : null,

              icon: const Icon(
                Icons.check,
              ),

              label: Text(
                isRequesting ? 'جارٍ الطلب...' : 'طلب التبرع',
                style: const TextStyle(
                  fontSize: 17,
                ),
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
      padding:
          const EdgeInsets.only(bottom: 18),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(icon),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}