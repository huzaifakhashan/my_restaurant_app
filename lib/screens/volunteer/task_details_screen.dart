import 'package:flutter/material.dart';

import '../../models/volunteer_task.dart';
import '../../services/auth_service.dart';
import '../../services/volunteer_service.dart';

class TaskDetailsScreen extends StatefulWidget {
  final VolunteerTask task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailsScreen> createState() =>
      _TaskDetailsScreenState();
}

class _TaskDetailsScreenState
    extends State<TaskDetailsScreen> {

  bool isAccepting = false;

  Future<void> acceptTask() async {
    setState(() {
      isAccepting = true;
    });

    await VolunteerService.acceptTask(
      widget.task,
      AuthService.currentUser!.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم قبول المهمة بنجاح',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المهمة'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Icon(
              Icons.volunteer_activism,
              size: 90,
            ),

            const SizedBox(height: 20),

            Text(
              task.title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            _info(
              Icons.location_on,
              'مكان الاستلام',
              task.pickupLocation,
            ),

            _info(
              Icons.location_on_outlined,
              'مكان التوصيل',
              task.deliveryLocation,
            ),

            _info(
              Icons.access_time,
              'وقت المهمة',
              task.pickupTime,
            ),

            _info(
              Icons.inventory_2,
              'الكمية',
              '${task.quantity}',
            ),

            _info(
              Icons.notes,
              'ملاحظات',
              task.notes.isEmpty
                  ? 'لا توجد ملاحظات'
                  : task.notes,
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: isAccepting ? null : acceptTask,
              icon: const Icon(Icons.check),
              label: Text(
                isAccepting ? 'جارٍ القبول...' : 'قبول المهمة',
                style: const TextStyle(fontSize: 17),
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
                    fontWeight: FontWeight.bold,
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