import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/reservation_service.dart';
import '../../models/reservation.dart';
import '../../widgets/status_badge.dart';
import 'reservation_qr_screen.dart';

class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({super.key});

  String _statusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return 'بانتظار التأكيد';
      case ReservationStatus.confirmed:
        return 'تم تأكيد الحجز';
      case ReservationStatus.completed:
        return 'مكتمل';
      case ReservationStatus.cancelled:
        return 'ملغي';
    }
  }

  Color _statusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return AppTheme.accentOrange;
      case ReservationStatus.confirmed:
        return AppTheme.primaryTeal;
      case ReservationStatus.completed:
        return Colors.grey;
      case ReservationStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser!;
    final stream = user.role == UserRole.restaurant
        ? ReservationService.streamRestaurantReservations(user.id)
        : ReservationService.streamMyReservations(user.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user.role == UserRole.restaurant ? 'الحجوزات' : 'حجوزاتي',
        ),
      ),

      body: StreamBuilder<List<Reservation>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final reservations = snapshot.data ?? [];

          if (reservations.isEmpty) {
            return const Center(
              child: Text(
                'لا يوجد حجوزات حالياً',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.mealName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('الكمية: ${reservation.quantity}'),
                      Text('الموقع: ${reservation.mealLocation}'),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'رمز الاستلام:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            reservation.code,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      StatusBadge(
                        text: _statusText(reservation.status),
                        color: _statusColor(reservation.status),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReservationQrScreen(
                                reservation: reservation,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('عرض QR Code'),
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
