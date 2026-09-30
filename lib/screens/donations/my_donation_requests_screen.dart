import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/donation_request.dart';
import '../../services/auth_service.dart';
import '../../services/donation_request_service.dart';
import '../../widgets/status_badge.dart';

class MyDonationRequestsScreen extends StatelessWidget {
  const MyDonationRequestsScreen({super.key});

  String statusText(DonationRequestStatus status) {
    switch (status) {
      case DonationRequestStatus.pending:
        return 'قيد الانتظار';
      case DonationRequestStatus.confirmed:
        return 'تم التأكيد';
      case DonationRequestStatus.completed:
        return 'مكتمل';
      case DonationRequestStatus.cancelled:
        return 'ملغى';
    }
  }

  Color statusColor(DonationRequestStatus status) {
    switch (status) {
      case DonationRequestStatus.pending:
        return AppTheme.accentOrange;
      case DonationRequestStatus.confirmed:
        return AppTheme.primaryTeal;
      case DonationRequestStatus.completed:
        return Colors.grey;
      case DonationRequestStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final requesterId = AuthService.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
      ),

      body: StreamBuilder<List<DonationRequest>>(
        stream: DonationRequestService.streamMyRequests(requesterId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Text('لا توجد طلبات'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.donationTitle,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('الكمية: ${request.quantity}'),
                      Text('الموقع: ${request.donationLocation}'),
                      Text('وقت الاستلام: ${request.donationPickupTime}'),
                      const SizedBox(height: 15),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(),
                        ),
                        child: Column(
                          children: [
                            const Text('رمز الاستلام'),
                            const SizedBox(height: 5),
                            Text(
                              request.code,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      StatusBadge(
                        text: statusText(request.status),
                        color: statusColor(request.status),
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
