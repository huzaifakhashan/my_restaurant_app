import 'package:flutter/material.dart';

import '../../models/reservation.dart';
import '../../services/reservation_service.dart';

class VerifyReservationScreen
    extends StatefulWidget {
  const VerifyReservationScreen({
    super.key,
  });

  @override
  State<VerifyReservationScreen> createState() =>
      _VerifyReservationScreenState();
}

class _VerifyReservationScreenState
    extends State<VerifyReservationScreen> {

  final codeController =
      TextEditingController();

  Reservation? reservation;
  String? errorMessage;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> verify() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        errorMessage = 'يرجى إدخال رمز الاستلام';
        reservation = null;
      });

      return;
    }

    final result = await ReservationService.findByCode(code);

    if (!mounted) return;

    setState(() {
      reservation = result;

      if (result == null) {
        errorMessage = 'رمز الاستلام غير صحيح';
      } else {
        errorMessage = null;
      }
    });
  }

  Future<void> completeReservation() async {
    if (reservation == null) {
      return;
    }

    final success = await ReservationService.completeReservation(
      reservation!,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        reservation!.status = ReservationStatus.completed;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تأكيد الاستلام بنجاح ✓',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'التحقق من الحجز',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 90,
            ),

            const SizedBox(height: 20),

            const Text(
              'أدخل رمز الاستلام للتحقق من الحجز',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: codeController,

              textCapitalization:
                  TextCapitalization.characters,

              decoration:
                  const InputDecoration(
                labelText: 'رمز الاستلام',
                prefixIcon:
                    Icon(Icons.qr_code),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: verify,

              icon: const Icon(
                Icons.search,
              ),

              label: const Text(
                'تحقق',
              ),
            ),

            const SizedBox(height: 25),

            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (reservation != null)
              _reservationResult(),
          ],
        ),
      ),
    );
  }

  Widget _reservationResult() {
    final currentReservation =
        reservation!;

    final isCompleted =
        currentReservation.status ==
        ReservationStatus.completed;

    return Card(
      margin: const EdgeInsets.only(top: 20),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              'تم العثور على الحجز ✓',

              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'الوجبة: '
              '${currentReservation.mealName}',
            ),

            const SizedBox(height: 8),

            Text(
              'الكمية: '
              '${currentReservation.quantity}',
            ),

            const SizedBox(height: 8),

            Text(
              'الموقع: '
              '${currentReservation.mealLocation}',
            ),

            const SizedBox(height: 8),

            Text(
              'الرمز: '
              '${currentReservation.code}',
            ),

            const SizedBox(height: 20),

            if (isCompleted)
              const Text(
                'تم استلام هذه الوجبة مسبقاً ✓',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed:
                    completeReservation,

                icon: const Icon(
                  Icons.check,
                ),

                label: const Text(
                  'تأكيد الاستلام',
                ),
              ),
          ],
        ),
      ),
    );
  }
}