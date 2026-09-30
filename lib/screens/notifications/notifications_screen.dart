import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../models/donation_request.dart';
import '../../models/reservation.dart';
import '../../models/user.dart';
import '../../models/volunteer_task.dart';
import '../../services/auth_service.dart';
import '../../services/donation_request_service.dart';
import '../../services/reservation_service.dart';
import '../../services/volunteer_service.dart';

/// إشعار واحد بالقائمة، مع الشاشة يلي بتنفتح لما نضغط عليه.
class _Notice {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String route;

  const _Notice({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.route,
  });
}

/// الإشعارات مبنية من بيانات Firestore الموجودة (حجوزات، طلبات، مهام)
/// حسب دور المستخدم، فبتتحدث مباشرة لما تتغير البيانات.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: StreamBuilder<List<_Notice>>(
        stream: _combine(_streamsFor(user)),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notices = snapshot.data!;

          if (notices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('لا توجد إشعارات حالياً'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notice.color.withValues(alpha: 0.15),
                    child: Icon(notice.icon, color: notice.color),
                  ),
                  title: Text(
                    notice.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(notice.subtitle),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.pushNamed(context, notice.route),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Stream<List<_Notice>>> _streamsFor(AppUser user) {
    switch (user.role) {
      case UserRole.restaurant:
        return [
          ReservationService.streamRestaurantReservations(
            user.id,
          ).map((list) => list.map(_restaurantReservationNotice).toList()),
        ];
      case UserRole.beneficiary:
        return [
          ReservationService.streamMyReservations(
            user.id,
          ).map((list) => list.map(_myReservationNotice).toList()),
          DonationRequestService.streamMyRequests(
            user.id,
          ).map((list) => list.map(_myRequestNotice).toList()),
        ];
      case UserRole.donor:
        return [
          DonationRequestService.streamRequestsForDonor(
            user.id,
          ).map((list) => list.map(_donorRequestNotice).toList()),
        ];
      case UserRole.volunteer:
        return [
          VolunteerService.streamAvailableTasks().map(
            (list) => list.map(_availableTaskNotice).toList(),
          ),
          VolunteerService.streamMyTasks(
            user.id,
          ).map((list) => list.map(_myTaskNotice).toList()),
        ];
    }
  }

  /// يدمج أكتر من stream بقائمة وحدة، ويبعت النتيجة كل ما تغيّر أي واحد منهم.
  Stream<List<_Notice>> _combine(List<Stream<List<_Notice>>> streams) {
    final latest = List<List<_Notice>?>.filled(streams.length, null);
    final subscriptions = <StreamSubscription<List<_Notice>>>[];
    late final StreamController<List<_Notice>> controller;

    controller = StreamController<List<_Notice>>(
      onListen: () {
        for (var i = 0; i < streams.length; i++) {
          subscriptions.add(
            streams[i].listen((value) {
              latest[i] = value;
              if (latest.every((l) => l != null)) {
                controller.add([for (final l in latest) ...l!]);
              }
            }, onError: controller.addError),
          );
        }
      },
      onCancel: () async {
        for (final s in subscriptions) {
          await s.cancel();
        }
      },
    );

    return controller.stream;
  }

  _Notice _restaurantReservationNotice(Reservation r) {
    final done = r.status == ReservationStatus.completed;
    return _Notice(
      icon: done ? Icons.check_circle : Icons.bookmark_added,
      color: done ? Colors.grey : AppTheme.primaryTeal,
      title: done ? 'تم تسليم حجز' : 'حجز جديد على وجبة ${r.mealName}',
      subtitle: '${r.quantity} وجبة • كود ${r.code}',
      route: AppRoutes.reservations,
    );
  }

  _Notice _myReservationNotice(Reservation r) {
    final done = r.status == ReservationStatus.completed;
    return _Notice(
      icon: done ? Icons.check_circle : Icons.restaurant,
      color: done ? Colors.grey : AppTheme.primaryTeal,
      title: done ? 'تم استلام ${r.mealName}' : 'تم تأكيد حجزك: ${r.mealName}',
      subtitle: '${r.mealLocation} • ${r.mealPickupTime}',
      route: AppRoutes.reservations,
    );
  }

  _Notice _myRequestNotice(DonationRequest r) {
    final done = r.status == DonationRequestStatus.completed;
    return _Notice(
      icon: done ? Icons.check_circle : Icons.volunteer_activism,
      color: done ? Colors.grey : AppTheme.accentOrange,
      title: done
          ? 'تم استلام ${r.donationTitle}'
          : 'تم تأكيد طلبك: ${r.donationTitle}',
      subtitle: '${r.donationLocation} • ${r.donationPickupTime}',
      route: AppRoutes.myDonationRequests,
    );
  }

  _Notice _donorRequestNotice(DonationRequest r) {
    final done = r.status == DonationRequestStatus.completed;
    return _Notice(
      icon: done ? Icons.check_circle : Icons.inventory,
      color: done ? Colors.grey : AppTheme.accentOrange,
      title: done
          ? 'تم تسليم ${r.donationTitle}'
          : 'طلب جديد على تبرعك: ${r.donationTitle}',
      subtitle: 'الكمية: ${r.quantity} • كود ${r.code}',
      route: AppRoutes.myDonations,
    );
  }

  _Notice _availableTaskNotice(VolunteerTask t) {
    return _Notice(
      icon: Icons.local_shipping,
      color: AppTheme.primaryTeal,
      title: 'مهمة تطوع متاحة: ${t.title}',
      subtitle: '${t.pickupLocation} ← ${t.deliveryLocation}',
      route: AppRoutes.volunteer,
    );
  }

  _Notice _myTaskNotice(VolunteerTask t) {
    final done = t.status == VolunteerTaskStatus.completed;
    return _Notice(
      icon: done ? Icons.check_circle : Icons.assignment,
      color: done ? Colors.grey : AppTheme.accentOrange,
      title: done ? 'أكملت مهمة: ${t.title}' : 'مهمة قيد التنفيذ: ${t.title}',
      subtitle: t.pickupTime,
      route: done ? AppRoutes.completedTasks : AppRoutes.tasks,
    );
  }
}
