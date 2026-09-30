import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/reservation.dart';

class ReservationQrScreen extends StatelessWidget {
  final Reservation reservation;

  const ReservationQrScreen({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رمز الاستلام'),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              const Icon(
                Icons.qr_code_2,
                size: 60,
              ),

              const SizedBox(height: 20),

              Text(
                reservation.mealName,
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'الكمية: ${reservation.quantity}',
              ),

              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(),
                ),

                child: QrImageView(
                  data: reservation.code,
                  version: QrVersions.auto,
                  size: 250,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'اعرض هذا الرمز عند الاستلام',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(),
                ),

                child: Text(
                  reservation.code,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}