import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/volunteer_task.dart';
import '../../services/auth_service.dart';
import '../../services/volunteer_service.dart';
import '../../widgets/status_badge.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key, this.completedOnly = false});

  /// لما تكون true بتعرض المهام المكتملة بس (زر "المهام المكتملة" بالرئيسية).
  final bool completedOnly;

  String statusText(VolunteerTaskStatus status) {
    switch (status) {
      case VolunteerTaskStatus.available:
        return 'متاحة';
      case VolunteerTaskStatus.accepted:
        return 'تم القبول';
      case VolunteerTaskStatus.pickedUp:
        return 'تم الاستلام';
      case VolunteerTaskStatus.delivered:
        return 'تم التوصيل';
      case VolunteerTaskStatus.completed:
        return 'مكتملة';
      case VolunteerTaskStatus.cancelled:
        return 'ملغاة';
    }
  }

  Color statusColor(VolunteerTaskStatus status) {
    switch (status) {
      case VolunteerTaskStatus.available:
        return AppTheme.primaryTeal;
      case VolunteerTaskStatus.accepted:
      case VolunteerTaskStatus.pickedUp:
      case VolunteerTaskStatus.delivered:
        return AppTheme.accentOrange;
      case VolunteerTaskStatus.completed:
        return Colors.grey;
      case VolunteerTaskStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final volunteerId = AuthService.currentUser!.id;

    return Scaffold(
      appBar: AppBar(title: Text(completedOnly ? 'المهام المكتملة' : 'مهامي')),

      body: StreamBuilder<List<VolunteerTask>>(
        stream: VolunteerService.streamMyTasks(volunteerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final tasks = (snapshot.data ?? [])
              .where(
                (task) =>
                    !completedOnly ||
                    task.status == VolunteerTaskStatus.completed,
              )
              .toList();

          if (tasks.isEmpty) {
            return Center(
              child: Text(
                completedOnly ? 'لا توجد مهام مكتملة بعد' : 'لا توجد لديك مهام',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('من: ${task.pickupLocation}'),
                      Text('إلى: ${task.deliveryLocation}'),
                      const SizedBox(height: 10),
                      StatusBadge(
                        text: statusText(task.status),
                        color: statusColor(task.status),
                      ),
                      const SizedBox(height: 15),
                      _buildAction(task),
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

  Widget _buildAction(VolunteerTask task) {
    switch (task.status) {
      case VolunteerTaskStatus.accepted:
        return ElevatedButton(
          onPressed: () => VolunteerService.markPickedUp(task),
          child: const Text('تأكيد استلام الوجبات'),
        );

      case VolunteerTaskStatus.pickedUp:
        return ElevatedButton(
          onPressed: () => VolunteerService.markDelivered(task),
          child: const Text('تأكيد التوصيل'),
        );

      case VolunteerTaskStatus.delivered:
        return ElevatedButton(
          onPressed: () => VolunteerService.completeTask(task),
          child: const Text('إكمال المهمة'),
        );

      case VolunteerTaskStatus.completed:
        return const Text('تم إكمال المهمة ✓');

      default:
        return const SizedBox();
    }
  }
}
