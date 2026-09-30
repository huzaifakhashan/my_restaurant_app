import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/donation.dart';
import '../../services/auth_service.dart';
import '../../services/donation_service.dart';
import '../../services/donation_request_service.dart';
import '../../widgets/status_badge.dart';

class MyDonationsScreen extends StatelessWidget {
  const MyDonationsScreen({super.key});

  String statusText(DonationStatus status) {
    switch (status) {
      case DonationStatus.available:
        return 'متاح';
      case DonationStatus.reserved:
        return 'تم طلبه';
      case DonationStatus.completed:
        return 'مكتمل';
      case DonationStatus.cancelled:
        return 'ملغى';
    }
  }

  Color statusColor(DonationStatus status) {
    switch (status) {
      case DonationStatus.available:
        return AppTheme.primaryTeal;
      case DonationStatus.reserved:
        return AppTheme.accentOrange;
      case DonationStatus.completed:
        return Colors.grey;
      case DonationStatus.cancelled:
        return Colors.red;
    }
  }

  void confirmReceived(BuildContext context, Donation donation) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('تأكيد استلام التبرع'),
          content: const Text('هل تم استلام التبرع بنجاح؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await DonationService.markCompleted(donation);
                await DonationRequestService.completeRequestsForDonation(
                  donation.id,
                );
              },
              child: const Text('نعم، تم الاستلام'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final donorId = AuthService.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تبرعاتي'),
      ),
      body: StreamBuilder<List<Donation>>(
        stream: DonationService.streamMyDonations(donorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final donations = snapshot.data ?? [];

          if (donations.isEmpty) {
            return const Center(
              child: Text('لا توجد تبرعات منشورة'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final donation = donations[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'النوع: ${donation.type.label}\n'
                        'الكمية: ${donation.quantity}\n'
                        'الموقع: ${donation.location}',
                      ),
                      const SizedBox(height: 10),
                      StatusBadge(
                        text: statusText(donation.status),
                        color: statusColor(donation.status),
                      ),
                      if (donation.status == DonationStatus.reserved) ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => confirmReceived(context, donation),
                          icon: const Icon(Icons.check),
                          label: const Text('تأكيد الاستلام'),
                        ),
                      ],
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
